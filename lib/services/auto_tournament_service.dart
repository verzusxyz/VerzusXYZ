import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:verzus/features/tournaments/data/models/tournament_match_model.dart';
import 'package:verzus/features/tournaments/data/repositories/tournament_repository.dart';

class AutoTournamentService {
  final Ref _ref;
  final FirebaseFirestore _firestore;
  final Uuid _uuid = const Uuid();

  AutoTournamentService(this._ref, this._firestore);

  Future<void> checkAndCreateAutoTournaments() async {
    final waitlistRef = _firestore.collection('waitlists');
    final waitlistDocs = await waitlistRef.get();

    for (final doc in waitlistDocs.docs) {
      final waitlist = doc.data();
      final List<String> playerIds = List<String>.from(waitlist['playerIds'] ?? []);

      if (playerIds.length >= 12) {
        final newTournamentId = _uuid.v4();
        final tournamentPlayers = playerIds.take(12).toList();

        await _firestore.collection('tournaments').doc(newTournamentId).set({
          'tournamentId': newTournamentId,
          'name': 'Auto-Tournament (Double Elimination)',
          'createdAt': FieldValue.serverTimestamp(),
          'isAuto': true,
          'playerIds': tournamentPlayers,
        });

        await _generate12PlayerDoubleEliminationBracket(newTournamentId, tournamentPlayers);

        final remainingPlayerIds = playerIds.sublist(12);
        await doc.reference.update({'playerIds': remainingPlayerIds});
      }
    }
  }

  Future<void> _generate12PlayerDoubleEliminationBracket(
    String tournamentId,
    List<String> playerIds,
  ) async {
    final List<Map<String, dynamic>> matches = [];
    final shuffledPlayers = List.from(playerIds)..shuffle();

    // --- Winners Bracket ---
    // WB Round 1: 6 matches
    for (int i = 0; i < 12; i += 2) {
      matches.add(_createMatch(tournamentId, 1, (i ~/ 2) + 1,
          player1Id: shuffledPlayers[i], player2Id: shuffledPlayers[i + 1]));
    }
    // WB Round 2: 3 placeholder matches
    for (int i = 0; i < 3; i++) {
      matches.add(_createMatch(tournamentId, 2, i + 7));
    }
    // WB Semi-Final: 1 placeholder match
    matches.add(_createMatch(tournamentId, 3, 10));
    // WB Final: 1 placeholder match
    matches.add(_createMatch(tournamentId, 4, 11));

    // --- Losers Bracket ---
    // LB Round 1: 2 placeholder matches
    matches.add(_createMatch(tournamentId, -1, 1));
    matches.add(_createMatch(tournamentId, -1, 2));
    // LB Round 2: 2 placeholder matches
    matches.add(_createMatch(tournamentId, -2, 1));
    matches.add(_createMatch(tournamentId, -2, 2));
    // LB Semi-Final: 1 placeholder match
    matches.add(_createMatch(tournamentId, -3, 1));
    // LB Final: 1 placeholder match
    matches.add(_createMatch(tournamentId, -4, 1));

    // --- Grand Final ---
    matches.add(_createMatch(tournamentId, 5, 1));

    await _ref.read(tournamentRepositoryProvider).createBracket(tournamentId, matches);
  }

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

final autoTournamentServiceProvider = Provider((ref) {
  final firestore = FirebaseFirestore.instance;
  return AutoTournamentService(ref, firestore);
});
