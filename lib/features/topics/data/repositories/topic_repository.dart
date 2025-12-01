import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/core/services/firebase_service.dart';
import 'package:verzus/features/topics/data/models/topic_model.dart';
import 'package:verzus/firestore/firestore_data_schema.dart';

final topicRepositoryProvider = Provider<TopicRepository>((ref) {
  return TopicRepository(ref.read(firebaseServiceProvider));
});

class TopicRepository {
  final FirebaseService _firebaseService;

  TopicRepository(this._firebaseService);

  FirebaseFirestore get _firestore => _firebaseService.firestore;

  CollectionReference<TopicModel> get _topicsRef =>
      _firestore.collection(FirestoreSchema.skillTopics).withConverter<TopicModel>(
            fromFirestore: (snapshot, _) => TopicModel.fromFirestore(snapshot),
            toFirestore: (topic, _) => topic.toFirestore(),
          );

  Stream<List<TopicModel>> getTopics() {
    return _topicsRef
        .where(SkillTopicDocument.isActive, isEqualTo: true)
        .orderBy(SkillTopicDocument.name, descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<void> createTopic(TopicModel topic) async {
    await _topicsRef.add(topic);
  }
}
