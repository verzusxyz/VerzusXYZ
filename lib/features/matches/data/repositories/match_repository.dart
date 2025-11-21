import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/firestore/firestore_data_schema.dart';
import 'package:verzus/models/match_model.dart';

/// Provider for the match repository.
final matchRepositoryProvider = Provider<MatchRepository>((ref) {
  return MatchRepository(firestore: FirebaseFirestore.instance);
});

/// A repository for handling all match-related Firestore operations.
class MatchRepository {
  final FirebaseFirestore _firestore;

  MatchRepository({required FirebaseFirestore firestore}) : _firestore = firestore;

  /// Creates a new match in Firestore.
  Future<String> createMatch(MatchModel match) async {
    try {
      final matchRef = _firestore.collection(FirestoreSchema.matches).doc();
      final matchData = match.toFirestore();
      matchData['id'] = matchRef.id;
      await matchRef.set(matchData);
      return matchRef.id;
    } on FirebaseException {
      rethrow;
    }
  }

  /// Joins an existing match in Firestore.
  Future<void> joinMatch(String matchId, String userId) async {
    try {
      await _firestore.collection(FirestoreSchema.matches).doc(matchId).update({
        MatchDocument.opponentId: userId,
        MatchDocument.status: FirestoreConstants.matchStatusActive,
        MatchDocument.startTime: FieldValue.serverTimestamp(),
        MatchDocument.updatedAt: FieldValue.serverTimestamp(),
      });
    } on FirebaseException {
      rethrow;
    }
  }

  /// Submits the result of a match to Firestore.
  Future<void> submitMatchResult({
    required String matchId,
    required String winnerId,
    required String loserId,
    required int winnerScore,
    required int loserScore,
    Map<String, dynamic>? gameData,
  }) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final matchRef = _firestore.collection(FirestoreSchema.matches).doc(matchId);
        final matchDoc = await transaction.get(matchRef);

        if (!matchDoc.exists) {
          throw Exception('Match not found');
        }

        final match = MatchModel.fromFirestore(matchDoc);
        if (match.status != FirestoreConstants.matchStatusActive) {
          throw Exception('Match is not active');
        }

        // Update match with results
        transaction.update(matchRef, {
          MatchDocument.winnerId: winnerId,
          MatchDocument.loserId: loserId,
          MatchDocument.creatorScore:
              match.creatorId == winnerId ? winnerScore : loserScore,
          MatchDocument.opponentScore:
              match.creatorId == winnerId ? loserScore : winnerScore,
          MatchDocument.status: FirestoreConstants.matchStatusCompleted,
          MatchDocument.endTime: FieldValue.serverTimestamp(),
          MatchDocument.gameData: gameData,
          MatchDocument.updatedAt: FieldValue.serverTimestamp(),
        });

        // Update user statistics
        final winnerRef = _firestore.collection(FirestoreSchema.users).doc(winnerId);
        final loserRef = _firestore.collection(FirestoreSchema.users).doc(loserId);

        transaction.update(winnerRef, {
          UserDocument.totalWins: FieldValue.increment(1),
          UserDocument.totalMatches: FieldValue.increment(1),
          UserDocument.updatedAt: FieldValue.serverTimestamp(),
        });

        transaction.update(loserRef, {
          UserDocument.totalLosses: FieldValue.increment(1),
          UserDocument.totalMatches: FieldValue.increment(1),
          UserDocument.updatedAt: FieldValue.serverTimestamp(),
        });
      });
    } on FirebaseException {
      rethrow;
    }
  }

  /// Retrieves a stream of available matches from Firestore.
  Stream<List<MatchModel>> getAvailableMatches({
    String? skillTopic,
    int limit = 20,
  }) {
    Query query = _firestore
        .collection(FirestoreSchema.matches)
        .where(MatchDocument.status, isEqualTo: FirestoreConstants.matchStatusPending)
        .orderBy(MatchDocument.createdAt, descending: true)
        .limit(limit);

    if (skillTopic != null) {
      query = query.where(MatchDocument.skillTopic, isEqualTo: skillTopic);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => MatchModel.fromFirestore(doc)).toList();
    });
  }

  /// Retrieves a stream of matches for a specific user from Firestore.
  Stream<List<MatchModel>> getUserMatches(String userId, {int limit = 50}) {
    return _firestore
        .collection(FirestoreSchema.matches)
        .where(Filter.or(
          Filter(MatchDocument.creatorId, isEqualTo: userId),
          Filter(MatchDocument.opponentId, isEqualTo: userId),
        ))
        .orderBy(MatchDocument.createdAt, descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => MatchModel.fromFirestore(doc)).toList());
  }

  /// Listens for real-time updates to a specific match in Firestore.
  Stream<MatchModel?> listenToMatch(String matchId) {
    return _firestore
        .collection(FirestoreSchema.matches)
        .doc(matchId)
        .snapshots()
        .map((doc) => doc.exists ? MatchModel.fromFirestore(doc) : null);
  }
}
