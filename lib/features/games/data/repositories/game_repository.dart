import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/models/game_model.dart';

/// Provider for the game repository.
final gameRepositoryProvider = Provider<GameRepository>((ref) {
  return GameRepository(firestore: FirebaseFirestore.instance);
});

/// A repository for handling all game-related Firestore operations.
class GameRepository {
  final FirebaseFirestore _firestore;

  GameRepository({required FirebaseFirestore firestore}) : _firestore = firestore;

  /// Adds a new game to the 'games' collection in Firestore.
  Future<String> addGame(GameModel game) async {
    try {
      final gameRef = _firestore.collection('games').doc();
      final gameData = game.toFirestore();
      gameData['gameId'] = gameRef.id;
      await gameRef.set(gameData);
      return gameRef.id;
    } on FirebaseException {
      rethrow;
    }
  }

  /// Retrieves a stream of games from Firestore.
  Stream<List<GameModel>> getGames({int limit = 50}) {
    return _firestore
        .collection('games')
        .orderBy('popularityScore', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => GameModel.fromFirestore(doc)).toList());
  }

  /// Retrieves a stream of popular games from Firestore.
  Stream<List<GameModel>> getPopularGames({int limit = 20}) {
    return _firestore
        .collection('games')
        .where('autoGenEnabled', isEqualTo: true)
        .orderBy('popularityScore', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => GameModel.fromFirestore(doc)).toList());
  }
}
