import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:verzus/firestore/firestore_data_schema.dart';

class GameResultModel {
  final String id;
  final String matchId;
  final String player1Id;
  final String? player2Id;
  final int? player1Score;
  final int? player2Score;
  final String? winnerId;
  final Map<String, dynamic>? gameData;
  final int? duration;
  final DateTime createdAt;

  const GameResultModel({
    required this.id,
    required this.matchId,
    required this.player1Id,
    this.player2Id,
    this.player1Score,
    this.player2Score,
    this.winnerId,
    this.gameData,
    this.duration,
    required this.createdAt,
  });

  factory GameResultModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GameResultModel(
      id: doc.id,
      matchId: data[GameResultDocument.matchId] ?? '',
      player1Id: data[GameResultDocument.player1Id] ?? '',
      player2Id: data[GameResultDocument.player2Id],
      player1Score: data[GameResultDocument.player1Score],
      player2Score: data[GameResultDocument.player2Score],
      winnerId: data[GameResultDocument.winnerId],
      gameData: data[GameResultDocument.gameData],
      duration: data[GameResultDocument.duration],
      createdAt: (data[GameResultDocument.createdAt] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      GameResultDocument.matchId: matchId,
      GameResultDocument.player1Id: player1Id,
      GameResultDocument.player2Id: player2Id,
      GameResultDocument.player1Score: player1Score,
      GameResultDocument.player2Score: player2Score,
      GameResultDocument.winnerId: winnerId,
      GameResultDocument.gameData: gameData,
      GameResultDocument.duration: duration,
      GameResultDocument.createdAt: FieldValue.serverTimestamp(),
    };
  }
}
