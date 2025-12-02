import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/features/topics/polls/data/models/vote_model.dart';
import 'package:verzus/firestore/firestore_data_schema.dart';

final voteRepositoryProvider = Provider<VoteRepository>((ref) {
  return VoteRepository(firestore: FirebaseFirestore.instance);
});

class VoteRepository {
  final FirebaseFirestore _firestore;

  VoteRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference<VoteModel> _votesRef(String topicId, String pollId) =>
      _firestore
          .collection(FirestoreSchema.skillTopics)
          .doc(topicId)
          .collection(FirestoreSchema.polls)
          .doc(pollId)
          .collection(FirestoreSchema.votes)
          .withConverter<VoteModel>(
            fromFirestore: (snapshot, _) => VoteModel.fromFirestore(snapshot),
            toFirestore: (vote, _) => vote.toFirestore(),
          );

  Future<void> vote(String topicId, String pollId, VoteModel vote) async {
    try {
      await _votesRef(topicId, pollId).add(vote);
    } on FirebaseException {
      rethrow;
    }
  }
}
