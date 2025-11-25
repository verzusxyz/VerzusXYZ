import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/features/tournaments/data/models/tournament_match_model.dart';
import 'package:verzus/firestore/firestore_data_schema.dart';

/// Provider for the tournament repository.
final tournamentRepositoryProvider = Provider<TournamentRepository>((ref) {
  return TournamentRepository(firestore: FirebaseFirestore.instance);
});

/// A repository for handling all tournament-related Firestore operations.
class TournamentRepository {
  final FirebaseFirestore _firestore;

  TournamentRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  /// Creates a new tournament in Firestore.
  Future<String> createTournament(Map<String, dynamic> tournament) async {
    try {
      final tournamentRef =
          _firestore.collection(FirestoreSchema.tournaments).doc();
      tournament['id'] = tournamentRef.id;
      tournament[TournamentDocument.createdAt] = FieldValue.serverTimestamp();
      tournament[TournamentDocument.updatedAt] = FieldValue.serverTimestamp();
      await tournamentRef.set(tournament);
      return tournamentRef.id;
    } on FirebaseException {
      rethrow;
    }
  }

  /// Joins an existing tournament in Firestore.
  Future<void> joinTournament(String tournamentId, String userId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final tournamentRef = _firestore
            .collection(FirestoreSchema.tournaments)
            .doc(tournamentId);
        final participantRef =
            _firestore.collection(FirestoreSchema.tournamentParticipants).doc();

        final tournamentDoc = await transaction.get(tournamentRef);
        if (!tournamentDoc.exists) {
          throw Exception('Tournament not found');
        }

        final tournament = tournamentDoc.data() as Map<String, dynamic>;
        final currentParticipants =
            tournament[TournamentDocument.currentParticipants] ?? 0;
        final maxParticipants =
            tournament[TournamentDocument.maxParticipants] ?? 0;

        if (currentParticipants >= maxParticipants) {
          throw Exception('Tournament is full');
        }

        // Add participant
        transaction.set(participantRef, {
          TournamentParticipantDocument.id: participantRef.id,
          TournamentParticipantDocument.tournamentId: tournamentId,
          TournamentParticipantDocument.userId: userId,
          TournamentParticipantDocument.status: 'active',
          TournamentParticipantDocument.joinedAt: FieldValue.serverTimestamp(),
        });

        // Update tournament participant count
        transaction.update(tournamentRef, {
          TournamentDocument.currentParticipants: FieldValue.increment(1),
          TournamentDocument.updatedAt: FieldValue.serverTimestamp(),
        });
      });
    } on FirebaseException {
      rethrow;
    }
  }

  /// Retrieves a stream of tournaments from Firestore.
  Stream<List<Map<String, dynamic>>> getTournaments({
    String? status,
    String? skillTopic,
    int limit = 20,
  }) {
    Query query = _firestore
        .collection(FirestoreSchema.tournaments)
        .orderBy(TournamentDocument.startDate, descending: false)
        .limit(limit);

    if (status != null) {
      query = query.where(TournamentDocument.status, isEqualTo: status);
    }
    if (skillTopic != null) {
      query = query.where(TournamentDocument.skillTopic, isEqualTo: skillTopic);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
          .toList();
    });
  }

  /// Creates the initial bracket for a tournament.
  Future<void> createBracket(
      String tournamentId, List<Map<String, dynamic>> matches) async {
    final batch = _firestore.batch();
    final tournamentRef =
        _firestore.collection(FirestoreSchema.tournaments).doc(tournamentId);

    for (final match in matches) {
      final matchRef =
          tournamentRef.collection('matches').doc(match['matchId']);
      batch.set(matchRef, match);
    }

    await batch.commit();
  }

  /// Updates a match with the winner's ID.
  Future<void> updateMatchWinner(
      String tournamentId, String matchId, String winnerId) async {
    final matchRef = _firestore
        .collection(FirestoreSchema.tournaments)
        .doc(tournamentId)
        .collection('matches')
        .doc(matchId);
    await matchRef.update({
      'winnerId': winnerId,
      'isComplete': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Fetches all matches for a given tournament.
  Future<List<TournamentMatchModel>> getAllMatches(String tournamentId) async {
    final snapshot = await _firestore
        .collection(FirestoreSchema.tournaments)
        .doc(tournamentId)
        .collection('matches')
        .get();
    return snapshot.docs
        .map((doc) => TournamentMatchModel.fromMap(doc.data()))
        .toList();
  }

  /// Updates a match with the player IDs.
  Future<void> updateMatchPlayers(String tournamentId, String matchId,
      String? player1Id, String? player2Id) async {
    final matchRef = _firestore
        .collection(FirestoreSchema.tournaments)
        .doc(tournamentId)
        .collection('matches')
        .doc(matchId);
    await matchRef.update({
      'player1Id': player1Id,
      'player2Id': player2Id,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
