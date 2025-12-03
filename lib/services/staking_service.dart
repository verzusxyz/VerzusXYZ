import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/features/wallet/data/models/wallet_model.dart';
import 'package:verzus/firestore/firestore_data_schema.dart';

/// Provider for the StakingService.
final stakingServiceProvider = Provider<StakingService>((ref) {
  return StakingService(firestore: FirebaseFirestore.instance);
});

/// A service dedicated to handling the escrow-like operations of staking,
/// locking, and distributing funds for matches and tournaments.
class StakingService {
  final FirebaseFirestore _firestore;

  StakingService({required FirebaseFirestore firestore}) : _firestore = firestore;

  /// Moves a specified amount from a user's available balance to their pending
  /// balance within an atomic transaction. This is used to "stake" or "escrow"
  /// funds for a match or tournament entry.
  Future<void> lockFunds(String userId, double amount,
      {WalletKind kind = WalletKind.live}) async {
    try {
      await _firestore.runTransaction((txn) async {
        final ref = _firestore.collection(FirestoreSchema.wallets).doc(userId);
        final snap = await txn.get(ref);
        if (!snap.exists) {
          throw Exception('Wallet not found');
        }
        final data = snap.data() as Map<String, dynamic>;
        if (kind == WalletKind.live) {
          final currentBalance =
              (data[WalletDocument.balance] ?? 0.0).toDouble();
          final currentPending =
              (data[WalletDocument.pendingBalance] ?? 0.0).toDouble();
          if (currentBalance < amount) {
            throw Exception('Insufficient funds');
          }
          txn.update(ref, {
            WalletDocument.balance: currentBalance - amount,
            WalletDocument.pendingBalance: currentPending + amount,
            WalletDocument.updatedAt: FieldValue.serverTimestamp(),
          });
        } else {
          final currentBalance = (data['demo_balance'] ?? 0.0).toDouble();
          final currentPending =
              (data['demo_pending_balance'] ?? 0.0).toDouble();
          if (currentBalance < amount) {
            throw Exception('Insufficient demo funds');
          }
          txn.update(ref, {
            'demo_balance': currentBalance - amount,
            'demo_pending_balance': currentPending + amount,
            WalletDocument.updatedAt: FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (e) {
      // ignore: avoid_print
      print('Error locking funds: $e');
      throw Exception('Failed to lock funds');
    }
  }

  /// Moves a specified amount from a user's pending balance back to their
  /// available balance. This is used when a match is cancelled or a user
  /// leaves a tournament before it starts.
  Future<void> unlockFunds(String userId, double amount,
      {WalletKind kind = WalletKind.live}) async {
    try {
      await _firestore.runTransaction((txn) async {
        final ref = _firestore.collection(FirestoreSchema.wallets).doc(userId);
        final snap = await txn.get(ref);
        if (!snap.exists) {
          throw Exception('Wallet not found');
        }
        final data = snap.data() as Map<String, dynamic>;
        if (kind == WalletKind.live) {
          final currentBalance =
              (data[WalletDocument.balance] ?? 0.0).toDouble();
          final currentPending =
              (data[WalletDocument.pendingBalance] ?? 0.0).toDouble();
          if (currentPending < amount) {
            throw Exception('Insufficient locked funds');
          }
          txn.update(ref, {
            WalletDocument.balance: currentBalance + amount,
            WalletDocument.pendingBalance: currentPending - amount,
            WalletDocument.updatedAt: FieldValue.serverTimestamp(),
          });
        } else {
          final currentBalance = (data['demo_balance'] ?? 0.0).toDouble();
          final currentPending =
              (data['demo_pending_balance'] ?? 0.0).toDouble();
          if (currentPending < amount) {
            throw Exception('Insufficient locked demo funds');
          }
          txn.update(ref, {
            'demo_balance': currentBalance + amount,
            'demo_pending_balance': currentPending - amount,
            WalletDocument.updatedAt: FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (e) {
      // ignore: avoid_print
      print('Error unlocking funds: $e');
      throw Exception('Failed to unlock funds');
    }
  }

  /// Reduces a user's pending balance by a specified amount without returning
  /// it to their available balance. This is used to pay out winnings to
  /// other players or to collect platform commissions.
  Future<void> consumeLocked(String userId, double amount,
      {WalletKind kind = WalletKind.live}) async {
    try {
      await _firestore.runTransaction((txn) async {
        final ref = _firestore.collection(FirestoreSchema.wallets).doc(userId);
        final snap = await txn.get(ref);
        if (!snap.exists) {
          throw Exception('Wallet not found');
        }
        final data = snap.data() as Map<String, dynamic>;
        if (kind == WalletKind.live) {
          final currentPending =
              (data[WalletDocument.pendingBalance] ?? 0.0).toDouble();
          if (currentPending < amount) {
            throw Exception('Insufficient locked funds');
          }
          txn.update(ref, {
            WalletDocument.pendingBalance: currentPending - amount,
            WalletDocument.totalLost: FieldValue.increment(amount),
            WalletDocument.updatedAt: FieldValue.serverTimestamp(),
          });
        } else {
          final currentPending =
              (data['demo_pending_balance'] ?? 0.0).toDouble();
          if (currentPending < amount) {
            throw Exception('Insufficient locked demo funds');
          }
          txn.update(ref, {
            'demo_pending_balance': currentPending - amount,
            WalletDocument.updatedAt: FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (e) {
      // ignore: avoid_print
      print('Error consuming locked funds: $e');
      rethrow;
    }
  }

  /// Processes the payouts for a completed match or tournament. This includes
  /// consuming the entry fees from all participants, distributing the prize
  /// pool to the winners, and creating detailed transaction records for
  /// auditing purposes.
  Future<void> processPayouts(
    List<String> participantIds,
    Map<String, double> winners, // Map<userId, prizeShare>
    double entryFee,
    double commissionRate, {
    String? relatedMatchId,
    String? relatedTournamentId,
    WalletKind kind = WalletKind.live,
  }) async {
    final double totalPrizePool = participantIds.length * entryFee;
    final double commission = totalPrizePool * commissionRate;
    final double netPrizePool = totalPrizePool - commission;

    await _firestore.runTransaction((transaction) async {
      // 1. Consume entry fees from all participants' pending balances
      for (final userId in participantIds) {
        final ref = _firestore.collection(FirestoreSchema.wallets).doc(userId);
        final snap = await transaction.get(ref);
        if (!snap.exists) {
          throw Exception('Wallet for participant $userId not found.');
        }

        final data = snap.data() as Map<String, dynamic>;
        if (kind == WalletKind.live) {
          final currentPending =
              (data[WalletDocument.pendingBalance] ?? 0.0).toDouble();
          if (currentPending < entryFee) {
            throw Exception('Insufficient locked funds for $userId');
          }
          transaction.update(ref, {
            WalletDocument.pendingBalance: currentPending - entryFee,
            WalletDocument.totalLost: FieldValue.increment(entryFee),
          });
        } else {
          final currentPending =
              (data['demo_pending_balance'] ?? 0.0).toDouble();
          if (currentPending < entryFee) {
            throw Exception('Insufficient locked demo funds for $userId');
          }
          transaction
              .update(ref, {'demo_pending_balance': currentPending - entryFee});
        }

        // Create a transaction record for the entry fee
        final txRef =
            _firestore.collection(FirestoreSchema.walletTransactions).doc();
        transaction.set(txRef, {
          WalletTransactionDocument.id: txRef.id,
          WalletTransactionDocument.userId: userId,
          WalletTransactionDocument.type: FirestoreConstants.transactionTypeEntryFee,
          WalletTransactionDocument.amount: -entryFee,
          WalletTransactionDocument.status: FirestoreConstants.transactionStatusCompleted,
          WalletTransactionDocument.description: 'Entry fee for match/tournament',
          WalletTransactionDocument.relatedMatchId: relatedMatchId,
          WalletTransactionDocument.relatedTournamentId: relatedTournamentId,
          WalletTransactionDocument.createdAt: FieldValue.serverTimestamp(),
          WalletTransactionDocument.updatedAt: FieldValue.serverTimestamp(),
        });
      }

      // 2. Distribute winnings to the winners' available balances
      for (final winnerEntry in winners.entries) {
        final winnerId = winnerEntry.key;
        final prizeShare = winnerEntry.value;
        final payout = netPrizePool * prizeShare;

        final ref = _firestore.collection(FirestoreSchema.wallets).doc(winnerId);

        if (kind == WalletKind.live) {
          transaction.update(ref, {
            WalletDocument.balance: FieldValue.increment(payout),
            WalletDocument.totalWon: FieldValue.increment(payout),
            WalletDocument.updatedAt: FieldValue.serverTimestamp(),
          });
        } else {
          transaction.update(ref, {
            'demo_balance': FieldValue.increment(payout),
            WalletDocument.updatedAt: FieldValue.serverTimestamp(),
          });
        }

        // Create a transaction record for the payout
        final txRef =
            _firestore.collection(FirestoreSchema.walletTransactions).doc();
        transaction.set(txRef, {
          WalletTransactionDocument.id: txRef.id,
          WalletTransactionDocument.userId: winnerId,
          WalletTransactionDocument.type: FirestoreConstants.transactionTypePayout,
          WalletTransactionDocument.amount: payout,
          WalletTransactionDocument.status: FirestoreConstants.transactionStatusCompleted,
          WalletTransactionDocument.description: 'Prize payout for match/tournament',
          WalletTransactionDocument.relatedMatchId: relatedMatchId,
          WalletTransactionDocument.relatedTournamentId: relatedTournamentId,
          WalletTransactionDocument.createdAt: FieldValue.serverTimestamp(),
          WalletTransactionDocument.updatedAt: FieldValue.serverTimestamp(),
        });
      }
    });
  }
}
