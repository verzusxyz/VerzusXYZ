import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/firestore/firestore_data_schema.dart';
import 'package:verzus/models/match_model.dart';
import 'package:verzus/services/wallet_service.dart';

final resultTrackerProvider = Provider<ResultTracker>((ref) => ResultTracker());

class ResultTracker {
  final FirebaseFirestore _fs = FirebaseFirestore.instance;

  /// Submit numeric results for a 1v1 match. Determines winner and settles funds.
  /// If demo mode, no wallet side-effects.
  Future<void> submitResult({
    required String matchId,
    required String reporterUserId,
    required int reporterScore,
    required int opponentScore,
    bool isDemo = false,
  }) async {
    await _fs.runTransaction((txn) async {
      final matchRef = _fs.collection(FirestoreSchema.matches).doc(matchId);
      final snap = await txn.get(matchRef);
      if (!snap.exists) throw Exception('Match not found');
      final match = MatchModel.fromFirestore(snap);
      if (match.status == MatchStatus.completed) return; // already done

      // Determine who is reporter (creator or opponent)
      final isCreator = reporterUserId == match.creatorId;
      final creatorScore = isCreator ? reporterScore : opponentScore;
      final oppScore = isCreator ? opponentScore : reporterScore;

      String? winnerId;
      String? loserId;
      if (creatorScore > oppScore) {
        winnerId = match.creatorId;
        loserId = match.opponentId;
      } else if (creatorScore < oppScore) {
        winnerId = match.opponentId;
        loserId = match.creatorId;
      } else {
        // Tie: refund both players and mark completed with no winner
        await _refundLocked(txn, match: match);
        txn.update(matchRef, {
          MatchDocument.status: FirestoreConstants.matchStatusCompleted,
          MatchDocument.creatorScore: creatorScore,
          MatchDocument.opponentScore: oppScore,
          MatchDocument.updatedAt: FieldValue.serverTimestamp(),
          MatchDocument.endTime: FieldValue.serverTimestamp(),
        });
        return;
      }

      // Update match with scores and winner
      txn.update(matchRef, {
        MatchDocument.status: FirestoreConstants.matchStatusCompleted,
        MatchDocument.winnerId: winnerId,
        MatchDocument.loserId: loserId,
        MatchDocument.creatorScore: creatorScore,
        MatchDocument.opponentScore: oppScore,
        MatchDocument.endTime: FieldValue.serverTimestamp(),
        MatchDocument.updatedAt: FieldValue.serverTimestamp(),
      });

      final isDemoMatch = isDemo || match.gameMode == 'demo' || (match.gameData?['mode'] == 'demo');
      if (isDemoMatch) return; // Skip live-money settlement for demo

      // Settle wallets: move pending from both players to winner, minus platform fee (20%)
      final wager = match.wagerAmount;
      final totalPot = (match.opponentId != null) ? (wager * 2) : wager;
      if (winnerId != null) {
        // Record platform fee on match for transparency
        final platformCut = double.parse((totalPot * 0.20).toStringAsFixed(2));
        txn.update(matchRef, {MatchDocument.platformFee: platformCut});

        await _awardWinner(txn,
            winnerId: winnerId,
            loserId: loserId,
            amountPerPlayer: wager,
            totalPot: totalPot,
            matchId: match.id,
            isDemo: false);
      }
    });
  }

  /// Resolve a disputed match by selecting a winner. If demo, no live-money side-effects.
  Future<void> resolveDispute({
    required String matchId,
    required String winnerUserId,
    bool isDemo = false,
  }) async {
    await _fs.runTransaction((txn) async {
      final matchRef = _fs.collection(FirestoreSchema.matches).doc(matchId);
      final snap = await txn.get(matchRef);
      if (!snap.exists) throw Exception('Match not found');
      final match = MatchModel.fromFirestore(snap);

      // Determine loser
      String? loserId;
      if (winnerUserId == match.creatorId) {
        loserId = match.opponentId;
      } else if (winnerUserId == match.opponentId) {
        loserId = match.creatorId;
      } else {
        throw Exception('Winner must be a participant');
      }

      // Update match status and set winner
      txn.update(matchRef, {
        MatchDocument.status: FirestoreConstants.matchStatusCompleted,
        MatchDocument.winnerId: winnerUserId,
        MatchDocument.loserId: loserId,
        MatchDocument.endTime: FieldValue.serverTimestamp(),
        MatchDocument.updatedAt: FieldValue.serverTimestamp(),
      });

      final isDemoMatch = isDemo || match.gameMode == 'demo' || (match.gameData?['mode'] == 'demo');
      if (isDemoMatch) return;

      final wager = match.wagerAmount;
      final totalPot = (match.opponentId != null) ? (wager * 2) : wager;
      final platformCut = double.parse((totalPot * 0.20).toStringAsFixed(2));
      txn.update(matchRef, {MatchDocument.platformFee: platformCut});

      await _awardWinner(
        txn,
        winnerId: winnerUserId,
        loserId: loserId,
        amountPerPlayer: wager,
        totalPot: totalPot,
        matchId: match.id,
        isDemo: false,
      );
    });
  }

  /// Resolve a disputed match as a tie; refund both parties and complete the match.
  Future<void> refundDispute({
    required String matchId,
  }) async {
    await _fs.runTransaction((txn) async {
      final matchRef = _fs.collection(FirestoreSchema.matches).doc(matchId);
      final snap = await txn.get(matchRef);
      if (!snap.exists) throw Exception('Match not found');
      final match = MatchModel.fromFirestore(snap);

      await _refundLocked(txn, match: match);

      txn.update(matchRef, {
        MatchDocument.status: FirestoreConstants.matchStatusCompleted,
        MatchDocument.updatedAt: FieldValue.serverTimestamp(),
        MatchDocument.endTime: FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> _refundLocked(Transaction txn, {required MatchModel match}) async {
    final wallets = FirebaseFirestore.instance.collection(FirestoreSchema.wallets);
    final String creatorId = match.creatorId;
    final String? oppId = match.opponentId;

    final creatorRef = wallets.doc(creatorId);
    final oppRef = oppId != null ? wallets.doc(oppId) : null;

    final isDemo = match.gameMode == 'demo' || (match.gameData?['mode'] == 'demo');

    final creatorSnap = await txn.get(creatorRef);
    if (creatorSnap.exists) {
      final data = creatorSnap.data() as Map<String, dynamic>;
      if (isDemo) {
        final bal = (data['demo_balance'] ?? 0.0).toDouble();
        final pend = (data['demo_pending_balance'] ?? 0.0).toDouble();
        txn.update(creatorRef, {
          'demo_balance': bal + match.wagerAmount,
          'demo_pending_balance': pend - match.wagerAmount,
          WalletDocument.updatedAt: FieldValue.serverTimestamp(),
        });
      } else {
        final bal = (data[WalletDocument.balance] ?? 0.0).toDouble();
        final pend = (data[WalletDocument.pendingBalance] ?? 0.0).toDouble();
        txn.update(creatorRef, {
          WalletDocument.balance: bal + match.wagerAmount,
          WalletDocument.pendingBalance: pend - match.wagerAmount,
          WalletDocument.updatedAt: FieldValue.serverTimestamp(),
        });
      }
    }

    if (oppRef != null) {
      final oppSnap = await txn.get(oppRef);
      if (oppSnap.exists) {
        final data = oppSnap.data() as Map<String, dynamic>;
        if (isDemo) {
          final bal = (data['demo_balance'] ?? 0.0).toDouble();
          final pend = (data['demo_pending_balance'] ?? 0.0).toDouble();
          txn.update(oppRef, {
            'demo_balance': bal + match.wagerAmount,
            'demo_pending_balance': pend - match.wagerAmount,
            WalletDocument.updatedAt: FieldValue.serverTimestamp(),
          });
        } else {
          final bal = (data[WalletDocument.balance] ?? 0.0).toDouble();
          final pend = (data[WalletDocument.pendingBalance] ?? 0.0).toDouble();
          txn.update(oppRef, {
            WalletDocument.balance: bal + match.wagerAmount,
            WalletDocument.pendingBalance: pend - match.wagerAmount,
            WalletDocument.updatedAt: FieldValue.serverTimestamp(),
          });
        }
      }
    }
  }

  Future<void> _awardWinner(Transaction txn, {
    required String winnerId,
    required String? loserId,
    required double amountPerPlayer,
    required double totalPot,
    required String matchId,
    bool isDemo = false,
  }) async {
    final wallets = FirebaseFirestore.instance.collection(FirestoreSchema.wallets);

    // Calculate platform cut and winner payout for live matches
    final double platformRate = 0.20;
    final double platformCut = isDemo ? 0.0 : double.parse((totalPot * platformRate).toStringAsFixed(2));
    final double winnerPayout = isDemo ? totalPot : double.parse((totalPot - platformCut).toStringAsFixed(2));

    // Deduct pending from participants and pay winner
    final winnerRef = wallets.doc(winnerId);
    final winnerSnap = await txn.get(winnerRef);
    if (winnerSnap.exists) {
      final data = winnerSnap.data() as Map<String, dynamic>;
      if (isDemo) {
        final bal = (data['demo_balance'] ?? 0.0).toDouble();
        final pend = (data['demo_pending_balance'] ?? 0.0).toDouble();
        txn.update(winnerRef, {
          'demo_balance': bal + winnerPayout,
          'demo_pending_balance': pend - amountPerPlayer,
          WalletDocument.updatedAt: FieldValue.serverTimestamp(),
        });
      } else {
        final bal = (data[WalletDocument.balance] ?? 0.0).toDouble();
        final pend = (data[WalletDocument.pendingBalance] ?? 0.0).toDouble();
        txn.update(winnerRef, {
          WalletDocument.balance: bal + winnerPayout,
          WalletDocument.pendingBalance: pend - amountPerPlayer,
          WalletDocument.totalWon: FieldValue.increment(winnerPayout - amountPerPlayer),
          WalletDocument.updatedAt: FieldValue.serverTimestamp(),
        });
      }
    }

    if (loserId != null) {
      final loserRef = wallets.doc(loserId);
      final loserSnap = await txn.get(loserRef);
      if (loserSnap.exists) {
        final data = loserSnap.data() as Map<String, dynamic>;
        if (isDemo) {
          final pend = (data['demo_pending_balance'] ?? 0.0).toDouble();
          txn.update(loserRef, {
            'demo_pending_balance': pend - amountPerPlayer,
            WalletDocument.updatedAt: FieldValue.serverTimestamp(),
          });
        } else {
          final pend = (data[WalletDocument.pendingBalance] ?? 0.0).toDouble();
          txn.update(loserRef, {
            WalletDocument.pendingBalance: pend - amountPerPlayer,
            WalletDocument.totalLost: FieldValue.increment(amountPerPlayer),
            WalletDocument.updatedAt: FieldValue.serverTimestamp(),
          });
        }
      }
    }

    // Credit platform/admin wallet for live matches
    if (!isDemo && platformCut > 0) {
      final adminRef = wallets.doc('admin_platform');
      final adminSnap = await txn.get(adminRef);
      if (!adminSnap.exists) {
        txn.set(adminRef, {
          WalletDocument.userId: 'admin_platform',
          WalletDocument.balance: 0.0,
          WalletDocument.pendingBalance: 0.0,
          WalletDocument.totalDeposited: 0.0,
          WalletDocument.totalWithdrawn: 0.0,
          WalletDocument.totalWon: 0.0,
          WalletDocument.totalLost: 0.0,
          'demo_balance': 0.0,
          'demo_pending_balance': 0.0,
          WalletDocument.createdAt: FieldValue.serverTimestamp(),
          WalletDocument.updatedAt: FieldValue.serverTimestamp(),
        });
      }
      txn.update(adminRef, {
        WalletDocument.balance: FieldValue.increment(platformCut),
        WalletDocument.updatedAt: FieldValue.serverTimestamp(),
      });
    }

    // Best-effort wallet transactions (outside txn)
    try {
      if (!isDemo) {
        await WalletService().addWalletTransaction(
          userId: winnerId,
          type: FirestoreConstants.transactionTypeWin,
          amount: winnerPayout,
          status: FirestoreConstants.transactionStatusCompleted,
          description: 'Match $matchId win payout (after 20% fee)',
          relatedMatchId: matchId,
        );
        if (loserId != null) {
          await WalletService().addWalletTransaction(
            userId: loserId,
            type: FirestoreConstants.transactionTypeWager,
            amount: amountPerPlayer,
            status: FirestoreConstants.transactionStatusCompleted,
            description: 'Match $matchId stake settled',
            relatedMatchId: matchId,
          );
        }
        await WalletService().addWalletTransaction(
          userId: 'admin_platform',
          type: FirestoreConstants.transactionTypeFee,
          amount: platformCut,
          status: FirestoreConstants.transactionStatusCompleted,
          description: 'Platform fee (20%) from match $matchId',
          relatedMatchId: matchId,
        );
      }
    } catch (_) {}
  }
}