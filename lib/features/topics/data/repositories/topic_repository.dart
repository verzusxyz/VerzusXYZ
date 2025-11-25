import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/features/topics/data/models/topic_model.dart';

class TopicRepository {
  final FirebaseFirestore _firestore;

  TopicRepository(this._firestore);

  Stream<List<Topic>> getTopics() {
    return _firestore.collection('topics').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Topic(id: doc.id, name: doc.data()['name'] ?? '');
      }).toList();
    });
  }
}

final topicRepositoryProvider = Provider((ref) {
  final firestore = FirebaseFirestore.instance;
  return TopicRepository(firestore);
});
