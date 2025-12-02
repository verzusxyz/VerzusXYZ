import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/features/topics/data/models/topic_model.dart';
import 'package:verzus/firestore/firestore_data_schema.dart';

final topicRepositoryProvider = Provider<TopicRepository>((ref) {
  return TopicRepository(firestore: FirebaseFirestore.instance);
});

class TopicRepository {
  final FirebaseFirestore _firestore;

  TopicRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  // For Skill Topics
  CollectionReference<TopicModel> get _topicsRef => _firestore
      .collection(FirestoreSchema.skillTopics)
      .withConverter<TopicModel>(
        fromFirestore: (snapshot, _) => TopicModel.fromFirestore(snapshot),
        toFirestore: (topic, _) => topic.toFirestore(),
      );

  Stream<List<TopicModel>> getTopics() {
    return _topicsRef
        .where(SkillTopicDocument.status, isEqualTo: 'open')
        .orderBy(SkillTopicDocument.question, descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<String> createTopic(TopicModel topic, String? s,
      {required String question, required List<String> options}) async {
    try {
      final topicRef = _firestore.collection(FirestoreSchema.skillTopics).doc();
      final topicData = topic.toFirestore();
      topicData['id'] = topicRef.id;
      await topicRef.set(topicData);
      return topicRef.id;
    } on FirebaseException {
      rethrow;
    }
  }
}
