import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:verzus/services/tournament_service.dart';
import 'package:uuid/uuid.dart';

class AutoTournamentService {
  final Ref _ref;
  final FirebaseFirestore _firestore;
  final Uuid _uuid = const Uuid();

  AutoTournamentService(this._ref, this._firestore);

  // This function would be called periodically from a UI entry point,
  // for example, when a user visits the tournaments screen.
  Future<void> checkAndCreateAutoTournaments() async {
    // We'll check a hypothetical 'waitlist' collection.
    // This collection would group users by the tournament tier they've joined.
    final waitlistRef = _firestore.collection('waitlists');

    // Get all waitlist documents (each representing a different tier)
    final waitlistDocs = await waitlistRef.get();

    for (final doc in waitlistDocs.docs) {
      final waitlist = doc.data();
      final List<String> playerIds = List<String>.from(waitlist['playerIds'] ?? []);

      // The plan specifies auto-tournaments start when 12 players join.
      if (playerIds.length >= 12) {
        final newTournamentId = _uuid.v4();

        // Create a new tournament document (simplified)
        await _firestore.collection('tournaments').doc(newTournamentId).set({
          'tournamentId': newTournamentId,
          'name': 'Auto-Tournament',
          'createdAt': FieldValue.serverTimestamp(),
          'isAuto': true,
          'playerIds': playerIds.take(12).toList(),
        });

        // Generate the bracket using the TournamentService
        await _ref.read(tournamentServiceProvider).generateBracket(
              newTournamentId,
              playerIds.take(12).toList(),
              TournamentFormat.doubleElimination, // As per the user's plan
            );

        // Clear the waitlist for these players
        final remainingPlayerIds = playerIds.sublist(12);
        await doc.reference.update({'playerIds': remainingPlayerIds});
      }
    }
  }
}

final autoTournamentServiceProvider = Provider((ref) {
  final firestore = FirebaseFirestore.instance;
  return AutoTournamentService(ref, firestore);
});
