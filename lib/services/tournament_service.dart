import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:verzus/features/tournaments/data/models/tournament_match_model.dart';
import 'package:verzus/features/tournaments/data/repositories/tournament_repository.dart';

enum TournamentFormat { singleElimination, doubleElimination }

class TournamentService {
  final Ref _ref;
  final Uuid _uuid = const Uuid();

  TournamentService(this._ref);

  Future<void> generateBracket(
    String tournamentId,
    List<String> playerIds,
    TournamentFormat format,
  ) async {
    // For this implementation, we will focus on the double-elimination format
    // for a 12-player auto-tournament, as specified in the user's plan.
    if (format == TournamentFormat.doubleElimination && playerIds.length == 12) {
      await _generate12PlayerDoubleEliminationBracket(tournamentId, playerIds);
    } else {
      // Placeholder for other tournament formats
      throw UnimplementedError('This tournament format is not yet supported.');
    }
  }

  Future<void> _generate12PlayerDoubleEliminationBracket(
    String tournamentId,
    List<String> playerIds,
  ) async {
    final List<Map<String, dynamic>> matches = [];
    final shuffledPlayers = List.from(playerIds)..shuffle();

    // Round 1 (Winners Bracket) - 6 matches
    for (int i = 0; i < 12; i += 2) {
      matches.add(TournamentMatchModel(
        matchId: _uuid.v4(),
        tournamentId: tournamentId,
        roundNumber: 1,
        matchNumber: (i ~/ 2) + 1,
        player1Id: shuffledPlayers[i],
        player2Id: shuffledPlayers[i + 1],
      ).toMap());
    }

    // Create placeholder matches for the rest of the bracket
    // Winners Bracket
    matches.add(_createPlaceholderMatch(tournamentId, 2, 1)); // WB Round 2, Match 1
    matches.add(_createPlaceholderMatch(tournamentId, 2, 2)); // WB Round 2, Match 2
    matches.add(_createPlaceholderMatch(tournamentId, 2, 3)); // WB Round 2, Match 3
    matches.add(_createPlaceholderMatch(tournamentId, 3, 1)); // WB Semi-Final
    matches.add(_createPlaceholderMatch(tournamentId, 4, 1)); // WB Final

    // Losers Bracket
    matches.add(_createPlaceholderMatch(tournamentId, -1, 1)); // LB Round 1, Match 1
    matches.add(_createPlaceholderMatch(tournamentId, -1, 2)); // LB Round 1, Match 2
    matches.add(_createPlaceholderMatch(tournamentId, -2, 1)); // LB Round 2
    matches.add(_createPlaceholderMatch(tournamentId, -2, 2)); // LB Round 2
    matches.add(_createPlaceholderMatch(tournamentId, -3, 1)); // LB Semi-Final
    matches.add(_createPlaceholderMatch(tournamentId, -4, 1)); // LB Final

    // Grand Final
    matches.add(_createPlaceholderMatch(tournamentId, 5, 1)); // Grand Final

    await _ref.read(tournamentRepositoryProvider).createBracket(tournamentId, matches);
  }

  Map<String, dynamic> _createPlaceholderMatch(String tournamentId, int roundNumber, int matchNumber) {
    return TournamentMatchModel(
      matchId: _uuid.v4(),
      tournamentId: tournamentId,
      roundNumber: roundNumber,
      matchNumber: matchNumber,
    ).toMap();
  }

  Future<void> advanceWinner(String tournamentId, String matchId, String winnerId) async {
    // This is a highly simplified advancement logic for a 12-player double-elimination bracket.
    // A full implementation would require a much more robust system for tracking match progressions.

    await _ref.read(tournamentRepositoryProvider).updateMatchWinner(tournamentId, matchId, winnerId);

    // In a real app, you would fetch the completed match, determine the next match
    // for the winner (and loser, in double-elimination), and update those matches.
    // This logic is complex and depends on the full bracket structure, which is
    // beyond the scope of this simplified implementation.
  }
}

final tournamentServiceProvider = Provider((ref) => TournamentService(ref));
