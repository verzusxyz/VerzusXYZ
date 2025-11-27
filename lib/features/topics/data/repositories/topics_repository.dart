import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:verzus/core/services/firebase_service.dart';
import 'package:verzus/features/topics/data/models/topic_model.dart';

class TopicsRepository {
  final FirebaseService _firebaseService;

  TopicsRepository(this._firebaseService);

  FirebaseFirestore get _firestore => _firebaseService.firestore;

  CollectionReference<TopicModel> get _pollsRef =>
      _firestore.collection('polls').withConverter<TopicModel>(
            fromFirestore: (snapshot, _) =>
                TopicModel.fromJson(snapshot.data()!),
            toFirestore: (topic, _) => topic.toJson(),
          );

  Stream<List<TopicModel>> getTopics() {
    return _pollsRef.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<void> addTopic(TopicModel topic) {
    return _pollsRef.add(topic);
  }

  Future<void> voteOnTopic(String topicId, String option) {
    return _pollsRef.doc(topicId).update({
      'votes.$option': FieldValue.increment(1),
    });
  }
}
