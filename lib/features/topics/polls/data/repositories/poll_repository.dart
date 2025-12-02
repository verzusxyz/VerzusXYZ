import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/features/topics/data/models/poll_model.dart';
import 'package:verzus/firestore/firestore_data_schema.dart';

final pollRepositoryProvider = Provider<PollRepository>((ref) {
  return PollRepository(firestore: FirebaseFirestore.instance);
});

class PollRepository {
  final FirebaseFirestore _firestore;

  PollRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference<PollModel> _pollsRef(String topicId) => _firestore
      .collection(FirestoreSchema.skillTopics)
      .doc(topicId)
      .collection(FirestoreSchema.polls)
      .withConverter<PollModel>(
        fromFirestore: (snapshot, _) => PollModel.fromFirestore(snapshot),
        toFirestore: (poll, _) => poll.toFirestore(),
      );

  Stream<List<PollModel>> getPolls(String topicId) {
    return _pollsRef(topicId)
        .where(PollDocument.status, isEqualTo: 'open')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<String> createPoll(String topicId, PollModel poll) async {
    try {
      final docRef = await _pollsRef(topicId).add(poll);
      return docRef.id;
    } on FirebaseException {
      rethrow;
    }
  }
}
