import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for the activity log repository.
final activityLogRepositoryProvider = Provider<ActivityLogRepository>((ref) {
  return ActivityLogRepository(firestore: FirebaseFirestore.instance);
});

/// A repository for handling all activity logging operations.
class ActivityLogRepository {
  final FirebaseFirestore _firestore;

  ActivityLogRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  /// Logs a game launch event.
  Future<void> logLaunch({
    required String uid,
    required String gameId,
    required String platform,
  }) async {
    try {
      await _firestore.collection('activity_logs').add({
        'userId': uid,
        'gameId': gameId,
        'platform': platform,
        'action': 'launch',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } on FirebaseException {
      rethrow;
    }
  }
}
