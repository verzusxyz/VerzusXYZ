import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/firestore/firestore_data_schema.dart';
import 'package:verzus/models/match_model.dart';
import 'package:verzus/models/wallet_model.dart';
import 'package:verzus/services/wallet_service.dart';

final tournamentManagerProvider =
    Provider<TournamentManager>((ref) => TournamentManager());

class TournamentManager {
  final _fs = FirebaseFirestore.instance;

  Future<String> createTournament({
    required String creatorId,
    required String title,
    required double entryFee,
    required String walletKind, // 'live' or 'demo'
    required String gameId,
    String skillTopic = 'general',
    int maxParticipants = 12,
    String tournamentType = 'single_elim',
    String visibility = 'public',
    String payoutMode = 'top3',
    Map<String, num>? payoutRatios, // e.g., {'1':50,'2':30,'3':20}
    int matchBestOf = 1,
    int checkinDeadlineMins = 15,
    int matchDeadlineMins = 60,
    DateTime? startDate,
    String seeding = 'random',
    Map<String, dynamic>? pools,
  }) async {
    final doc = _fs.collection(FirestoreSchema.tournaments).doc();
    final inviteCode =
        visibility == 'private' ? doc.id.substring(0, 6).toUpperCase() : null;
    final ratios = payoutRatios ??
        (payoutMode == 'winner_takes_all'
            ? {'1': 100}
            : {'1': 50, '2': 30, '3': 20});
    final Timestamp? regDeadline = startDate != null
        ? Timestamp.fromDate(
            startDate.subtract(Duration(minutes: checkinDeadlineMins)))
        : null;
    await doc.set({
      TournamentDocument.id: doc.id,
      TournamentDocument.creatorId: creatorId,
      TournamentDocument.title: title,
      TournamentDocument.description: 'User-created tournament',
      TournamentDocument.skillTopic: skillTopic,
      TournamentDocument.entryFee: entryFee,
      TournamentDocument.prizePool: 0.0,
      TournamentDocument.maxParticipants: maxParticipants,
      TournamentDocument.currentParticipants: 0,
      TournamentDocument.status: FirestoreConstants.tournamentStatusOpen,
      TournamentDocument.tournamentType: tournamentType,
      TournamentDocument.startDate: startDate != null
          ? Timestamp.fromDate(startDate)
          : FieldValue.serverTimestamp(),
      TournamentDocument.registrationDeadline: regDeadline,
      TournamentDocument.visibility: visibility,
      TournamentDocument.inviteCode: inviteCode,
      TournamentDocument.payoutMode: payoutMode,
      TournamentDocument.payoutRatios: ratios,
      TournamentDocument.matchBestOf: matchBestOf,
      TournamentDocument.checkinDeadlineMins: checkinDeadlineMins,
      TournamentDocument.matchDeadlineMins: matchDeadlineMins,
      TournamentDocument.seeding: seeding,
      TournamentDocument.pools: pools,
      TournamentDocument.walletKind: walletKind,
      TournamentDocument.gameId: gameId,
      TournamentDocument.entryFeesTotal: 0.0,
      TournamentDocument.commissionRate: 0.20,
      TournamentDocument.bracket: null,
      // Dispute & notifications defaults
      TournamentDocument.disputePolicy: 'creator_judge',
      TournamentDocument.judgeUserId: creatorId,
      TournamentDocument.notifyOnPairing: true,
      TournamentDocument.notifyOnDeadline: true,
      TournamentDocument.createdAt: FieldValue.serverTimestamp(),
      TournamentDocument.updatedAt: FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  /// Join a tournament: lock entry fee in user's chosen wallet and add participant
  Future<void> joinTournament({
    required String tournamentId,
    required String userId,
  }) async {
    await _fs.runTransaction((txn) async {
      final tRef =
          _fs.collection(FirestoreSchema.tournaments).doc(tournamentId);
      final tSnap = await txn.get(tRef);
      if (!tSnap.exists) throw Exception('Tournament not found');
      final t = tSnap.data() as Map<String, dynamic>;
      if ((t[TournamentDocument.status] as String) !=
          FirestoreConstants.tournamentStatusOpen) {
        throw Exception('Tournament not open');
      }
      final maxP = (t[TournamentDocument.maxParticipants] ?? 0) as int;
      final curP = (t[TournamentDocument.currentParticipants] ?? 0) as int;
      if (curP >= maxP) throw Exception('Tournament is full');
      final entry = (t[TournamentDocument.entryFee] ?? 0.0).toDouble();
      final isDemo = (t[TournamentDocument.walletKind] ?? 'live') == 'demo';
      // Lock entry fee (if any)
      if (entry > 0) {
        await WalletService().lockFunds(userId, entry,
            kind: isDemo ? WalletKind.demo : WalletKind.live);
      }
      // Add participant row
      final pRef = _fs.collection(FirestoreSchema.tournamentParticipants).doc();
      txn.set(pRef, {
        TournamentParticipantDocument.id: pRef.id,
        TournamentParticipantDocument.tournamentId: tournamentId,
        TournamentParticipantDocument.userId: userId,
        TournamentParticipantDocument.status: 'active',
        TournamentParticipantDocument.joinedAt: FieldValue.serverTimestamp(),
      });
      // Update tournament counters
      txn.update(tRef, {
        TournamentDocument.currentParticipants: FieldValue.increment(1),
        TournamentDocument.entryFeesTotal: FieldValue.increment(entry),
        TournamentDocument.updatedAt: FieldValue.serverTimestamp(),
      });
    });
  }

  /// Generate initial bracket and matches when tournament starts
  Future<void> generateBracketAndMatches(String tournamentId) async {
    final tRef = _fs.collection(FirestoreSchema.tournaments).doc(tournamentId);
    final tSnap = await tRef.get();
    if (!tSnap.exists) throw Exception('Tournament not found');
    final t = tSnap.data() as Map<String, dynamic>;
    final type =
        (t[TournamentDocument.tournamentType] ?? 'single_elim') as String;
    final isDemo = (t[TournamentDocument.walletKind] ?? 'live') == 'demo';

    // Load participants
    final qs = await _fs
        .collection(FirestoreSchema.tournamentParticipants)
        .where(TournamentParticipantDocument.tournamentId,
            isEqualTo: tournamentId)
        .where(TournamentParticipantDocument.status, isEqualTo: 'active')
        .get();
    final participants = qs.docs
        .map((d) => d.data()[TournamentParticipantDocument.userId] as String)
        .toList();
    if (participants.length < 2) {
      throw Exception('Not enough participants to start');
    }

    if (type == 'single_elim') {
      // Seed: random
      participants.shuffle();
      // If not power of two, add byes
      int size = 1;
      while (size < participants.length) {
        size *= 2;
      }
      final byes = size - participants.length;
      final seeded = List<String>.from(participants);
      for (int i = 0; i < byes; i++) {
        seeded.add('BYE');
      }
      // Create matches for round 1
      final batch = _fs.batch();
      int matchIdx = 0;
      for (int i = 0; i < seeded.length; i += 2) {
        final p1 = seeded[i];
        final p2 = seeded[i + 1];
        if (p1 == 'BYE' || p2 == 'BYE') {
          // Advance real player automatically; store in bracket state
          // We'll materialize bracket state in tournament doc
          continue;
        }
        final matchId = _fs.collection(FirestoreSchema.matches).doc().id;
        final matchData = {
          MatchDocument.id: matchId,
          MatchDocument.creatorId: p1,
          MatchDocument.opponentId: p2,
          MatchDocument.skillTopic:
              t[TournamentDocument.skillTopic] ?? 'general',
          MatchDocument.wagerAmount: 0.0,
          MatchDocument.status: FirestoreConstants.matchStatusPending,
          MatchDocument.matchType: MatchType.tournament.name,
          MatchDocument.matchFormat: MatchFormat.oneVOne.name,
          MatchDocument.gameMode: isDemo ? 'demo' : 'live',
          MatchDocument.participants: [p1, p2],
          MatchDocument.platformFee: 0.0,
          MatchDocument.tournamentId: tournamentId,
          MatchDocument.tournamentRound: 1,
          MatchDocument.tournamentMatchIndex: matchIdx,
          MatchDocument.createdAt: FieldValue.serverTimestamp(),
          MatchDocument.updatedAt: FieldValue.serverTimestamp(),
        };
        final mRef = _fs.collection(FirestoreSchema.matches).doc(matchId);
        batch.set(mRef, matchData);
        matchIdx++;
      }
      batch.update(tRef, {
        TournamentDocument.status: FirestoreConstants.tournamentStatusStarted,
        TournamentDocument.updatedAt: FieldValue.serverTimestamp(),
      });
      await batch.commit();
    } else {
      // TODO: add double_elim, round_robin, pools_knockout scheduling
      await tRef.update({
        TournamentDocument.status: FirestoreConstants.tournamentStatusStarted,
        TournamentDocument.updatedAt: FieldValue.serverTimestamp(),
      });
    }
  }

  /// Payout winners and record platform commission (20%)
  Future<void> payoutTournament(
      String tournamentId, List<String> placements) async {
    // placements: ordered list of userIds by final rank (index 0 => 1st)
    await _fs.runTransaction((txn) async {
      final tRef =
          _fs.collection(FirestoreSchema.tournaments).doc(tournamentId);
      final tSnap = await txn.get(tRef);
      if (!tSnap.exists) throw Exception('Tournament not found');
      final t = tSnap.data() as Map<String, dynamic>;
      final totalEntries =
          (t[TournamentDocument.entryFeesTotal] ?? 0.0).toDouble();
      final commissionRate =
          (t[TournamentDocument.commissionRate] ?? 0.20).toDouble();
      final payoutRatios = Map<String, num>.from(
          t[TournamentDocument.payoutRatios] ?? {'1': 100});
      final isDemo = (t[TournamentDocument.walletKind] ?? 'live') == 'demo';
      final entry = (t[TournamentDocument.entryFee] ?? 0.0).toDouble();

      final platformCut = totalEntries * commissionRate;
      final prizePool = totalEntries - platformCut;

      // Consume each participant's entry pending
      final qs = await _fs
          .collection(FirestoreSchema.tournamentParticipants)
          .where(TournamentParticipantDocument.tournamentId,
              isEqualTo: tournamentId)
          .get();
      for (final d in qs.docs) {
        final uid = d.data()[TournamentParticipantDocument.userId] as String;
        if (entry > 0) {
          await WalletService().consumeLocked(uid, entry,
              kind: isDemo ? WalletKind.demo : WalletKind.live);
        }
      }

      // Credit winners based on payout ratios

      for (int i = 0; i < placements.length; i++) {
        final rank = i + 1;
        final percent = (payoutRatios['$rank'] ?? 0).toDouble();
        if (percent <= 0) continue;
        final amount = prizePool * (percent / 100.0);

        final winnerId = placements[i];
        await WalletService().creditBalance(winnerId, amount,
            kind: isDemo ? WalletKind.demo : WalletKind.live);
        await WalletService().addWalletTransaction(
          userId: winnerId,
          type: FirestoreConstants.transactionTypeWin,
          amount: amount,
          status: FirestoreConstants.transactionStatusCompleted,
          description: 'Tournament payout for rank #$rank',
          relatedTournamentId: tournamentId,
        );
      }

      // Record platform commission
      final adminRef = _fs
          .collection(AdminFinancialsSchema.collection)
          .doc(AdminFinancialsSchema.commissions);
      txn.set(
          adminRef,
          {
            AdminFinancialsSchema.totalCommission:
                FieldValue.increment(platformCut),
            AdminFinancialsSchema.updatedAt: FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true));

      // Finalize tournament document
      txn.update(tRef, {
        TournamentDocument.status: FirestoreConstants.tournamentStatusCompleted,
        TournamentDocument.prizePool: prizePool,
        TournamentDocument.platformFee: platformCut,
        TournamentDocument.endDate: FieldValue.serverTimestamp(),
        TournamentDocument.updatedAt: FieldValue.serverTimestamp(),
      });
    });
  }

  /// Mark a match as disputed and assign to creator to judge
  Future<void> markMatchDispute(
      {required String tournamentId, required String matchId}) async {
    await _fs.collection(FirestoreSchema.matches).doc(matchId).update({
      MatchDocument.status: FirestoreConstants.matchStatusDisputed,
      MatchDocument.updatedAt: FieldValue.serverTimestamp(),
    });
  }
}
