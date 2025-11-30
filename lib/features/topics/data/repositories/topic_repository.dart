import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/core/services/firebase_service.dart';
import 'package:verzus/features/topics/data/models/poll_model.dart';
import 'package:verzus/features/topics/data/models/topic_model.dart';
import 'package:verzus/firestore/firestore_data_schema.dart';

final topicRepositoryProvider = Provider<TopicRepository>((ref) {
  return TopicRepository(ref.read(firebaseServiceProvider));
});

class TopicRepository {
  final FirebaseService _firebaseService;

  TopicRepository(this._firebaseService);

  FirebaseFirestore get _firestore => _firebaseService.firestore;

  // For Skill Topics
  CollectionReference<TopicModel> get _topicsRef =>
      _firestore.collection(FirestoreSchema.skillTopics).withConverter<TopicModel>(
            fromFirestore: (snapshot, _) => TopicModel.fromFirestore(snapshot),
            toFirestore: (topic, _) => topic.toFirestore(),
          );

  // For Polls
  CollectionReference<PollModel> get _pollsRef =>
      _firestore.collection(FirestoreSchema.polls).withConverter<PollModel>(
            fromFirestore: (snapshot, _) => PollModel.fromFirestore(snapshot),
            toFirestore: (poll, _) => poll.toFirestore(),
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

  Stream<List<PollModel>> getPolls() {
    return _pollsRef
        .where('status', isEqualTo: 'open')
        .orderBy('created_at', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<void> createPoll(PollModel poll) async {
    await _pollsRef.add(poll);
  }

  Future<void> voteOnPoll(String pollId, int optionIndex, double entry, String userId, String walletKind) async {
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
