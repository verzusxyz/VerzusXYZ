import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/firestore/firestore_data_schema.dart';

final topicsServiceProvider = Provider<TopicsService>((ref) => TopicsService());

final openTopicsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return TopicsService().streamOpenTopics();
});

class TopicsService {
  final _firestore = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> streamOpenTopics() {
    return _firestore
        .collection(FirestoreSchema.skillTopics)
        .where(SkillTopicDocument.status, isEqualTo: 'open')
        .orderBy(SkillTopicDocument.createdAt, descending: true)
        .limit(50)
        .snapshots()
        .map((qs) => qs.docs.map((d) => d.data()).toList());
  }

  Future<void> createOpenTopic({
    required String question,
    List<String>? options,
    required String pollType,
    required String status,
  }) async {
    final ref = _firestore.collection(FirestoreSchema.skillTopics).doc();
    await ref.set({
      SkillTopicDocument.id: ref.id,
      SkillTopicDocument.question: question,
      SkillTopicDocument.options: options,
      SkillTopicDocument.pollType: pollType,
      SkillTopicDocument.status: status,
      SkillTopicDocument.createdAt: FieldValue.serverTimestamp(),
      SkillTopicDocument.updatedAt: FieldValue.serverTimestamp(),
    });
  }
}
