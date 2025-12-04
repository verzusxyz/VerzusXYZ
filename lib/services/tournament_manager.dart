import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:verzus/features/games/data/models/game_model.dart';
import 'package:verzus/firestore/firestore_data_schema.dart';
import 'package:verzus/features/wallet/data/models/wallet_model.dart';
import 'package:verzus/services/rating_service.dart';
import 'package:verzus/services/wallet_service.dart';
import 'package:verzus/features/tournaments/data/repositories/tournament_repository.dart';
import 'package:verzus/features/tournaments/data/models/tournament_match_model.dart';
import 'dart:math';

final tournamentManagerProvider =
    Provider<TournamentManager>((ref) => TournamentManager(ref));

class TournamentManager {
  final Ref _ref;
  final _fs = FirebaseFirestore.instance;

  TournamentManager(this._ref);

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
      if (entry > 0) {
        await WalletService().lockFunds(userId, entry,
            kind: isDemo ? WalletKind.demo : WalletKind.live);
      }
      final pRef = _fs.collection(FirestoreSchema.tournamentParticipants).doc();
      txn.set(pRef, {
        TournamentParticipantDocument.id: pRef.id,
        TournamentParticipantDocument.tournamentId: tournamentId,
        TournamentParticipantDocument.userId: userId,
        TournamentParticipantDocument.status: 'active',
        TournamentParticipantDocument.joinedAt: FieldValue.serverTimestamp(),
      });
      txn.update(tRef, {
        TournamentDocument.currentParticipants: FieldValue.increment(1),
        TournamentDocument.entryFeesTotal: FieldValue.increment(entry),
        TournamentDocument.updatedAt: FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> generateBracketAndMatches(String tournamentId) async {
    // This now delegates to the auto-tournament service's logic
    final autoTourneyService = _ref.read(autoTournamentServiceProvider);
    final participantsSnapshot = await _fs
        .collection(FirestoreSchema.tournamentParticipants)
        .where(TournamentParticipantDocument.tournamentId,
            isEqualTo: tournamentId)
        .get();
    final participantIds = participantsSnapshot.docs
        .map(
            (doc) => doc.data()[TournamentParticipantDocument.userId] as String)
        .toList();

    // We are assuming 12 players for auto-tournaments
    if (participantIds.length == 12) {
      await autoTourneyService.generate12PlayerDoubleEliminationBracket(
          tournamentId, participantIds);
    } else {
      // Fallback or error for other sizes
      throw UnimplementedError(
          'Only 12-player tournaments are currently supported for bracket generation.');
    }
  }

  Future<void> advanceWinner({
    required String tournamentId,
    required String completedMatchId,
    required String winnerId,
    required String gameId,
  }) async {
    final repo = _ref.read(tournamentRepositoryProvider);
    await repo.updateMatchWinner(tournamentId, completedMatchId, winnerId);

    final allMatches = await repo.getAllMatches(tournamentId);
    final completedMatch =
        allMatches.firstWhere((m) => m.matchId == completedMatchId);
    final loserId = (completedMatch.player1Id == winnerId)
        ? completedMatch.player2Id
        : completedMatch.player1Id;

    if (loserId != null) {
      await _ref
          .read(ratingServiceProvider)
          .updateRatings(gameId, winnerId, loserId);
    }
    await _ref
        .read(walletServiceProvider)
        .payoutTournament(completedMatchId, winnerId);

    // Here would be the complex logic to find the next match in the bracket
    // and update it with the winner/loser. This is a significant implementation
    // and will be stubbed out for now as per the user's acceptance of this limitation.
  }

  Future<void> payoutTournament(
      String tournamentId, List<String> placements) async {
    final tRef = _fs.collection(FirestoreSchema.tournaments).doc(tournamentId);
    final tSnap = await tRef.get();
    if (!tSnap.exists) throw Exception('Tournament not found');
    final t = tSnap.data() as Map<String, dynamic>;

    final commissionRate =
        (t[TournamentDocument.commissionRate] ?? 0.20).toDouble();
    final payoutRatios =
        Map<String, num>.from(t[TournamentDocument.payoutRatios] ?? {'1': 100});
    final isDemo = (t[TournamentDocument.walletKind] ?? 'live') == 'demo';
    final entryFee = (t[TournamentDocument.entryFee] ?? 0.0).toDouble();

    final participantsSnapshot = await _fs
        .collection(FirestoreSchema.tournamentParticipants)
        .where(TournamentParticipantDocument.tournamentId,
            isEqualTo: tournamentId)
        .get();
    final participantIds = participantsSnapshot.docs
        .map(
            (doc) => doc.data()[TournamentParticipantDocument.userId] as String)
        .toList();

    final Map<String, double> winners = {};
    for (int i = 0; i < placements.length; i++) {
      final rank = i + 1;
      final percent = (payoutRatios['$rank'] ?? 0).toDouble();
      if (percent > 0) {
        winners[placements[i]] = percent / 100.0;
      }
    }

    await _fs.runTransaction((transaction) async {
      final walletService = _ref.read(walletServiceProvider);
      await walletService.processPayouts(
        transaction,
        participantIds,
        winners,
        entryFee,
        commissionRate,
        kind: isDemo ? WalletKind.demo : WalletKind.live,
      );
    });

    await tRef.update({
      TournamentDocument.status: FirestoreConstants.tournamentStatusCompleted,
      TournamentDocument.endDate: FieldValue.serverTimestamp(),
      TournamentDocument.updatedAt: FieldValue.serverTimestamp(),
    });
  }

  Future<void> markMatchDispute(
      {required String tournamentId, required String matchId}) async {
    await _fs.collection(FirestoreSchema.matches).doc(matchId).update({
      MatchDocument.status: FirestoreConstants.matchStatusDisputed,
      MatchDocument.updatedAt: FieldValue.serverTimestamp(),
    });
  }
}

// NOTE: The auto-tournament service is now the primary bracket generator.
// This could be merged into the TournamentManager in a future refactor.
final autoTournamentServiceProvider = Provider((ref) {
  final firestore = FirebaseFirestore.instance;
  return AutoTournamentService(ref, firestore);
});

class AutoTournamentService {
  // ignore: unused_field
  final Ref _ref;
  // ignore: unused_field
  final FirebaseFirestore _firestore;
  final Uuid _uuid = const Uuid();

  AutoTournamentService(this._ref, this._firestore);

  Future<List<GameModel>> _getTopGames() async {
    final gamesSnapshot =
        await _firestore.collection(FirestoreSchema.gameResults).get();
    final gameCounts = <String, int>{};
    for (final doc in gamesSnapshot.docs) {
      final gameId = doc.data()['game_id'] as String;
      gameCounts[gameId] = (gameCounts[gameId] ?? 0) + 1;
    }
    final sortedGames = gameCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top5Games = sortedGames.take(5).map((e) => e.key).toList();

    final games = <GameModel>[];
    for (final gameId in top5Games) {
      final gameDoc = await _firestore.collection('games').doc(gameId).get();
      if (gameDoc.exists) {
        games.add(GameModel.fromFirestore(gameDoc));
      }
    }
    return games;
  }

  Future<void> _createAutoTournament(GameModel game, double entryFee,
      DateTime startDate, String titlePrefix) async {
    final tournament = {
      'title': '$titlePrefix: ${game.title}',
      'entryFee': entryFee,
      'maxParticipants': 12,
      'gameId': game.gameId,
      'walletKind': 'live',
      'status': 'open',
      'creatorId': 'system',
      'startDate': Timestamp.fromDate(startDate),
    };
    await _firestore.collection(FirestoreSchema.tournaments).add(tournament);
  }

  DateTime _getStartOfNextDay() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day + 1);
  }

  DateTime _getStartOfNextWeek() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day + 7);
  }

  Future<void> checkAndCreateAutoTournaments() async {
    final topGames = await _getTopGames();
    if (topGames.isEmpty) return;

    final dailyTournaments = await _firestore
        .collection(FirestoreSchema.tournaments)
        .where('title', isGreaterThanOrEqualTo: 'Daily:')
        .where('startDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(_getStartOfNextDay()))
        .get();

    if (dailyTournaments.docs.isEmpty) {
      final randomGame = topGames[Random().nextInt(topGames.length)];
      final entryFee = [5.0, 10.0, 25.0, 50.0][Random().nextInt(4)];
      await _createAutoTournament(
          randomGame, entryFee, _getStartOfNextDay(), 'Daily');
    }

    final weeklyTournaments = await _firestore
        .collection(FirestoreSchema.tournaments)
        .where('title', isGreaterThanOrEqualTo: 'Weekly:')
        .where('startDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(_getStartOfNextWeek()))
        .get();

    if (weeklyTournaments.docs.isEmpty) {
      final randomGame = topGames[Random().nextInt(topGames.length)];
      final entryFee = [5.0, 10.0, 25.0, 50.0][Random().nextInt(4)];
      await _createAutoTournament(
          randomGame, entryFee, _getStartOfNextWeek(), 'Weekly');
    }
  }

  Future<void> generate12PlayerDoubleEliminationBracket(
    String tournamentId,
    List<String> playerIds,
  ) async {
    playerIds.shuffle();
    final batch = _firestore.batch();
    final matches = <Map<String, dynamic>>[];

    // Winners Bracket - Round 1
    for (int i = 0; i < 6; i++) {
      matches.add(_createMatch(tournamentId, 1, i + 1,
          player1Id: playerIds[i * 2], player2Id: playerIds[i * 2 + 1]));
    }
    // Losers Bracket - Round 1
    for (int i = 0; i < 2; i++) {
      matches.add(_createMatch(tournamentId, -1, i + 1));
    }

    for (final match in matches) {
      final matchRef =
          _firestore.collection(FirestoreSchema.matches).doc(match['matchId']);
      batch.set(matchRef, match);
    }
    await batch.commit();
  }

  // ignore: unused_element
  Map<String, dynamic> _createMatch(
      String tournamentId, int roundNumber, int matchNumber,
      {String? player1Id, String? player2Id}) {
    return TournamentMatchModel(
      matchId: _uuid.v4(),
      tournamentId: tournamentId,
      roundNumber: roundNumber,
      matchNumber: matchNumber,
      player1Id: player1Id,
      player2Id: player2Id,
    ).toMap();
  }
}

// Provide an extension on WalletService to add processPayouts so the TournamentManager
// can call it; this is a compile-time stub that can be replaced with real logic.
extension WalletServiceTournamentExt on WalletService {
  Future<void> processPayouts(
    Transaction transaction,
    List<String> participantIds,
    Map<String, double> winners,
    double entryFee,
    double commissionRate, {
    WalletKind kind = WalletKind.live,
  }) async {
    final totalPrizePool =
        entryFee * participantIds.length * (1 - commissionRate);

    for (final entry in winners.entries) {
      final userId = entry.key;
      final percentage = entry.value;
      final amount = totalPrizePool * percentage;

      if (amount > 0) {
        final walletRef = FirebaseFirestore.instance
            .collection(FirestoreSchema.wallets)
            .doc(userId);
        transaction.update(walletRef, {
          (kind == WalletKind.live ? WalletDocument.balance : 'demo_balance'):
              FieldValue.increment(amount),
          WalletDocument.updatedAt: FieldValue.serverTimestamp(),
        });
      }
    }
  }

  /// Minimal payout helper so TournamentManager can call `payoutTournament`.
  /// This is a safe, compile-time stub that performs a merge update on the
  /// winner's wallet document to avoid creating or overwriting documents.
  Future<void> payoutTournament(String matchId, String winnerId) async {
    final walletRef = FirebaseFirestore.instance
        .collection(FirestoreSchema.wallets)
        .doc(winnerId);

    // Perform a merge set to ensure the document exists and update the timestamp.
    await walletRef.set({
      WalletDocument.updatedAt: FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
