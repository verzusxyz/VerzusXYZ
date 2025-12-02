import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/features/topics/data/models/polls_model.dart';
import 'package:verzus/firestore/firestore_data_schema.dart';

final pollRepositoryProvider = Provider<PollRepository>((ref) {
  return PollRepository(firestore: FirebaseFirestore.instance);
});

class PollRepository {
  final FirebaseFirestore _firestore;

  PollRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  // // For Polls
  CollectionReference<PollsModel> get _pollsRef =>
      _firestore.collection(FirestoreSchema.polls).withConverter<PollsModel>(
            fromFirestore: (snapshot, _) => PollsModel.fromFirestore(snapshot),
            toFirestore: (poll, _) => poll.toFirestore(),
          );

  Stream<List<PollsModel>> getPolls() {
    return _pollsRef
        .orderBy('created_at', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Creates a new poll in Firestore.
  Future<String> createPoll(PollsModel poll) async {
    try {
      final pollRef = _firestore.collection(FirestoreSchema.polls).doc();
      final pollData = poll.toFirestore();
      pollData['id'] = pollRef.id;
      await pollRef.set(pollData);
      return pollRef.id;
    } on FirebaseException {
      rethrow;
    }
  }

  Future<void> voteOnPoll(String pollId, int optionIndex, double entry,
      String userId, String walletKind) async {
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
