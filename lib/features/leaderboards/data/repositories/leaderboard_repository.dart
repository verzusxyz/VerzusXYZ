import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/features/leaderboards/data/models/leaderboard_entry_model.dart';

class LeaderboardRepository {
  final FirebaseFirestore _firestore;

  LeaderboardRepository(this._firestore);

  Future<List<LeaderboardEntry>> getLeaderboard(String gameId) async {
    final usersSnapshot = await _firestore
        .collection('users')
        .orderBy('ratings.$gameId', descending: true)
        .limit(100)
        .get();

    final List<LeaderboardEntry> leaderboard = [];
    for (final doc in usersSnapshot.docs) {
      final data = doc.data();
      final ratings = data['ratings'] as Map<String, dynamic>?;
      if (ratings != null && ratings.containsKey(gameId)) {
        leaderboard.add(LeaderboardEntry(
          userId: doc.id,
          username: data['username'] ?? 'Anonymous',
          rating: (ratings[gameId] as num).toDouble(),
        ));
      }
    }
    return leaderboard;
  }
}

final leaderboardRepositoryProvider = Provider((ref) {
  final firestore = FirebaseFirestore.instance;
  return LeaderboardRepository(firestore);
});
