import 'package-cloud_firestore/cloud_firestore.dart';
import 'package-flutter_riverpod/flutter_riverpod.dart';

class RatingService {
  final FirebaseFirestore _firestore;

  RatingService(this._firestore);

  // This is a simplified ELO rating calculation.
  // A real implementation would likely be more complex.
  Future<void> updateRatings(String gameId, String winnerId, String loserId) async {
    final winnerRef = _firestore.collection('users').doc(winnerId);
    final loserRef = _firestore.collection('users').doc(loserId);

    await _firestore.runTransaction((transaction) async {
      final winnerSnapshot = await transaction.get(winnerRef);
      final loserSnapshot = await transaction.get(loserRef);

      if (!winnerSnapshot.exists || !loserSnapshot.exists) {
        throw Exception('One or both users not found.');
      }

      // Ratings are stored per game in a map on the user document.
      final winnerRatings = Map<String, double>.from(winnerSnapshot.data()?['ratings'] ?? {});
      final loserRatings = Map<String, double>.from(loserSnapshot.data()?['ratings'] ?? {});

      final winnerRating = winnerRatings[gameId] ?? 1200.0;
      final loserRating = loserRatings[gameId] ?? 1200.0;

      const double k = 32.0; // K-factor

      final expectedWinner = 1.0 / (1.0 + (10.0 * (loserRating - winnerRating) / 400.0)));
      final expectedLoser = 1.0 / (1.0 + (10.0 * (winnerRating - loserRating) / 400.0)));

      final newWinnerRating = winnerRating + k * (1.0 - expectedWinner);
      final newLoserRating = loserRating + k * (0.0 - expectedLoser);

      winnerRatings[gameId] = newWinnerRating;
      loserRatings[gameId] = newLoserRating;

      transaction.update(winnerRef, {'ratings': winnerRatings});
      transaction.update(loserRef, {'ratings': loserRatings});
    });
  }
}

final ratingServiceProvider = Provider((ref) {
  final firestore = FirebaseFirestore.instance;
  return RatingService(firestore);
});
