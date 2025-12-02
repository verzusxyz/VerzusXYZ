import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/features/topics/data/models/vote_model.dart';
import 'package:verzus/firestore/firestore_data_schema.dart';

final voteRepositoryProvider = Provider<VoteRepository>((ref) {
  return VoteRepository(firestore: FirebaseFirestore.instance);
});

class VoteRepository {
  final FirebaseFirestore _firestore;

  VoteRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference<VoteModel> _votesRef(String topicId) => _firestore
      .collection(FirestoreSchema.skillTopics)
      .doc(topicId)
      .collection(FirestoreSchema.votes)
      .withConverter<VoteModel>(
        fromFirestore: (snapshot, _) => VoteModel.fromFirestore(snapshot),
        toFirestore: (vote, _) => vote.toFirestore(),
      );

  Stream<List<VoteModel>> getVotes(String topicId) {
    return _votesRef(topicId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<String> createVote(String topicId, VoteModel vote) async {
    try {
      final docRef = await _votesRef(topicId).add(vote);
      return docRef.id;
    } on FirebaseException {
      rethrow;
    }
  }
}
