import 'package:flutter/foundation.dart';

@immutable
class TournamentMatchModel {
  final String matchId;
  final String tournamentId;
  final int roundNumber;
  final int matchNumber;
  final String? player1Id;
  final String? player2Id;
  final String? winnerId;
  final bool isComplete;

  const TournamentMatchModel({
    required this.matchId,
    required this.tournamentId,
    required this.roundNumber,
    required this.matchNumber,
    this.player1Id,
    this.player2Id,
    this.winnerId,
    this.isComplete = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'matchId': matchId,
      'tournamentId': tournamentId,
      'roundNumber': roundNumber,
      'matchNumber': matchNumber,
      'player1Id': player1Id,
      'player2Id': player2Id,
      'winnerId': winnerId,
      'isComplete': isComplete,
    };
  }

  factory TournamentMatchModel.fromMap(Map<String, dynamic> map) {
    return TournamentMatchModel(
      matchId: map['matchId'] ?? '',
      tournamentId: map['tournamentId'] ?? '',
      roundNumber: map['roundNumber']?.toInt() ?? 0,
      matchNumber: map['matchNumber']?.toInt() ?? 0,
      player1Id: map['player1Id'],
      player2Id: map['player2Id'],
      winnerId: map['winnerId'],
      isComplete: map['isComplete'] ?? false,
    );
  }

  TournamentMatchModel copyWith({
    String? matchId,
    String? tournamentId,
    int? roundNumber,
    int? matchNumber,
    String? player1Id,
    String? player2Id,
    String? winnerId,
    bool? isComplete,
  }) {
    return TournamentMatchModel(
      matchId: matchId ?? this.matchId,
      tournamentId: tournamentId ?? this.tournamentId,
      roundNumber: roundNumber ?? this.roundNumber,
      matchNumber: matchNumber ?? this.matchNumber,
      player1Id: player1Id ?? this.player1Id,
      player2Id: player2Id ?? this.player2Id,
      winnerId: winnerId ?? this.winnerId,
      isComplete: isComplete ?? this.isComplete,
    );
  }
}
