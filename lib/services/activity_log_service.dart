import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:verzus/firestore/firestore_data_schema.dart';

class ActivityLogService {
  final _fs = FirebaseFirestore.instance;

  Future<void> logLaunch({
    required String uid,
    required String gameId,
    required String platform,
  }) async {
    final ref = _fs.collection('activityLogs').doc();
    await ref.set({
      'id': ref.id,
      'user_id': uid,
      'game_id': gameId,
      'platform': platform,
      'type': 'launch',
      'created_at': FieldValue.serverTimestamp(),
    });
  }
}
