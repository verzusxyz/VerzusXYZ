import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/features/auth/data/models/user_model.dart';
import 'package:verzus/firestore/firestore_data_schema.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(firestore: FirebaseFirestore.instance);
});

class ProfileRepository {
  final FirebaseFirestore _firestore;

  ProfileRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  Stream<UserModel?> watchUserProfile(String uid) {
    return _firestore
        .collection(FirestoreSchema.users)
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  Future<void> updateUserProfile(
      String uid, Map<String, dynamic> updates) async {
    try {
      updates[UserDocument.updatedAt] = FieldValue.serverTimestamp();
      await _firestore
          .collection(FirestoreSchema.users)
          .doc(uid)
          .update(updates);
    } on FirebaseException {
      rethrow;
    }
  }
}
