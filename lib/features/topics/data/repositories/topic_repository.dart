import 'package.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/core/services/firebase_service.dart';
import 'package:verzus/features/topics/data/models/poll_model.dart';
import 'package:verzus/firestore/firestore_data_schema.dart';

final topicRepositoryProvider = Provider<TopicRepository>((ref) {
  return TopicRepository(ref.read(firebaseServiceProvider));
});

class TopicRepository {
  final FirebaseService _firebaseService;

  TopicRepository(this._firebaseService);

  FirebaseFirestore get _firestore => _firebaseService.firestore;

  CollectionReference<PollModel> get _pollsRef =>
      _firestore.collection(FirestoreSchema.polls).withConverter<PollModel>(
            fromFirestore: (snapshot, _) =>
                PollModel.fromJson(snapshot.data()!),
            toFirestore: (topic, _) => topic.toJson(),
          );

  CollectionReference<Map<String, dynamic>> get _openTopicsRef =>
      _firestore.collection(FirestoreSchema.skillTopics);

  Stream<List<PollModel>> getPolls() {
    return _pollsRef
        .where('status', isEqualTo: 'open')
        .orderBy('created_at', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<void> createPoll(PollModel topic) async {
    await _pollsRef.add(topic);
  }

  Stream<List<Map<String, dynamic>>> getOpenTopics() {
    return _openTopicsRef.snapshots().map(
        (snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<void> createOpenTopic(
      {required String title, String? description}) async {
    await _openTopicsRef.add({
      SkillTopicDocument.name: title,
      SkillTopicDocument.description: description ?? '',
      SkillTopicDocument.isActive: true,
      SkillTopicDocument.createdAt: FieldValue.serverTimestamp(),
      SkillTopicDocument.updatedAt: FieldValue.serverTimestamp(),
    });
  }

  Future<void> vote(String pollId, int optionIndex, double entry, String userId, String walletKind) async {
    final voteData = {
      'poll_id': pollId,
      'user_id': userId,
      'option_index': optionIndex,
      'amount_locked': entry,
      'wallet_kind': walletKind,
      'created_at': FieldValue.serverTimestamp(),
    };
    await _firestore.collection('poll_votes').add(voteData);
  }
}
