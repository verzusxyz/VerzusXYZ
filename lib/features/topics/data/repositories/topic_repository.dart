import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/core/services/firebase_service.dart';
import 'package:verzus/features/topics/data/models/topic_model.dart';

final topicRepositoryProvider = Provider<TopicRepository>((ref) {
  return TopicRepository(ref.read(firebaseServiceProvider));
});

class TopicRepository {
  final FirebaseService _firebaseService;

  TopicRepository(this._firebaseService);

  FirebaseFirestore get _firestore => _firebaseService.firestore;

  CollectionReference<TopicModel> get _topicsRef =>
      _firestore.collection('skill_topics').withConverter<TopicModel>(
            fromFirestore: (snapshot, _) =>
                TopicModel.fromJson(snapshot.data()!),
            toFirestore: (topic, _) => topic.toJson(),
          );

  Stream<List<TopicModel>> getTopics() {
    return _topicsRef.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<void> createTopic(TopicModel topic) async {
    await _topicsRef.doc(topic.id).set(topic);
  }
}
