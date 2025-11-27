import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/core/services/firebase_service.dart';
import 'package:verzus/features/auth/data/models/user_model.dart';


class ProfileRepository {
  final FirebaseService _firebaseService;

  ProfileRepository(this._firebaseService);

  Future<void> updateUserProfile({
    required String displayName,
    required String username,
  }) async {
    final user = _firebaseService.auth.currentUser;
    if (user != null) {
      await user.updateDisplayName(displayName);
      await _firebaseService.firestore.collection('users').doc(user.uid).update({
        'displayName': displayName,
        'username': username,
      });
    }
  }
}
