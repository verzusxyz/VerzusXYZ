import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      final tournamentRef = _firestore.collection(FirestoreSchema.tournaments).doc();
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
        final tournamentRef =
            _firestore.collection(FirestoreSchema.tournaments).doc(tournamentId);
        final participantRef = _firestore
            .collection(FirestoreSchema.tournamentParticipants)
            .doc();

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
}
