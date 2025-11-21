import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/models/user_model.dart';
import 'package:verzus/firestore/firestore_data_schema.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

final currentUserProvider = StreamProvider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) {
      if (user == null) return Stream.value(null);
      final authService = ref.watch(authServiceProvider);
      return authService.getUserStream(user.uid);
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Normalize usernames to a canonical form used everywhere
  String _normalizeUsername(String input) {
    final base = input.trim().toLowerCase();
    final normalized = base.replaceAll(RegExp(r'[^a-z0-9_]+'), '_');
    final collapsed = normalized.replaceAll(RegExp(r'_+'), '_');
    return collapsed.replaceAll(RegExp(r'^_+|_+\$'), '');
  }

  String _mapFirebaseAuthError(FirebaseAuthException e,
      {required bool forSignUp}) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'weak-password':
        return 'Your password is too weak. Please choose a stronger one.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found with these credentials.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return forSignUp
            ? 'Failed to create account. Please try again.'
            : 'Failed to sign in. Please try again.';
    }
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get user data stream
  Stream<UserModel?> getUserStream(String uid) {
    return _firestore
        .collection(FirestoreSchema.users)
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  // Sign up with email and password
  Future<UserModel?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
    required String username,
    required String country,
    String? referredBy,
  }) async {
    User? createdAuthUser;
    try {
      // Create user account first
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      createdAuthUser = result.user;
      final user = createdAuthUser;
      if (user == null) return null;

      // Update display name in Firebase Auth
      await user.updateDisplayName(displayName);

      // Normalize and atomically reserve the username using a usernames index
      final normalized = _normalizeUsername(username);
      final userModel = UserModel(
        uid: user.uid,
        displayName: displayName,
        email: email,
        username: normalized,
        country: country,
        referredBy: referredBy,
        kycStatus: KycStatus.pending,
        skillRatings: {},
        createdAt: DateTime.now(),
      );

      await _firestore.runTransaction((txn) async {
        final unameRef =
            _firestore.collection(FirestoreSchema.usernames).doc(normalized);
        final unameSnap = await txn.get(unameRef);
        if (unameSnap.exists) {
          throw Exception('USERNAME_TAKEN');
        }
        final userRef =
            _firestore.collection(FirestoreSchema.users).doc(user.uid);

        txn.set(unameRef, {
          'uid': user.uid,
          'created_at': FieldValue.serverTimestamp(),
        });
        txn.set(userRef, userModel.toFirestore());
      });

      // Initialize wallet (non-blocking failure)
      await _initializeUserWallet(user.uid);

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e, forSignUp: true));
    } catch (e) {
      // If username was taken, clean up the just-created auth account to avoid orphaned accounts
      if (e.toString().contains('USERNAME_TAKEN')) {
        try {
          await createdAuthUser?.delete();
        } catch (_) {}
        throw const AuthException(
            'That username is already taken. Please choose another.');
      }
      // Permission / network / unknown errors
      throw const AuthException(
          'We couldn\'t complete sign up. Please try again.');
    }
  }

  // Sign in with email and password
  Future<UserModel?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = result.user;
      if (user == null) return null;

      // Update last seen
      await _firestore.collection(FirestoreSchema.users).doc(user.uid).update({
        UserDocument.lastSeen: FieldValue.serverTimestamp(),
        UserDocument.isOnline: true,
      });

      // Get user data
      final doc = await _firestore
          .collection(FirestoreSchema.users)
          .doc(user.uid)
          .get();
      return doc.exists ? UserModel.fromFirestore(doc) : null;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e, forSignUp: false));
    } catch (e) {
      throw const AuthException('Failed to sign in. Please try again.');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw AuthException('Failed to sign out: ${e.toString()}');
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw AuthException(
          'Failed to send password reset email: ${e.toString()}');
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? displayName,
    String? username,
    String? phone,
    String? avatarUrl,
  }) async {
    final user = currentUser;
    if (user == null) throw AuthException('No user signed in');

    try {
      final updates = <String, dynamic>{};

      if (displayName != null) {
        updates[UserDocument.displayName] = displayName;
        await user.updateDisplayName(displayName);
      }
      if (username != null) {
        updates[UserDocument.username] = _normalizeUsername(username);
      }
      if (phone != null) updates['phone'] = phone;
      if (avatarUrl != null) updates[UserDocument.profileImageUrl] = avatarUrl;

      if (updates.isNotEmpty) {
        updates[UserDocument.updatedAt] = FieldValue.serverTimestamp();
        await _firestore
            .collection(FirestoreSchema.users)
            .doc(user.uid)
            .update(updates);
      }
    } catch (e) {
      throw AuthException('Failed to update profile: ${e.toString()}');
    }
  }

  // Check if username is available (best-effort; final check happens in transaction)
  Future<bool> isUsernameAvailable(String username) async {
    try {
      final normalized = _normalizeUsername(username);
      final doc = await _firestore
          .collection(FirestoreSchema.usernames)
          .doc(normalized)
          .get();
      return !doc.exists;
    } catch (e) {
      // If we cannot check (e.g., permission denied), don't block sign-up
      return true;
    }
  }

  // Initialize user wallet
  Future<void> _initializeUserWallet(String uid) async {
    try {
      await _firestore.collection(FirestoreSchema.wallets).doc(uid).set({
        WalletDocument.userId: uid,
        WalletDocument.balance: 0.0,
        WalletDocument.pendingBalance: 0.0,
        WalletDocument.totalDeposited: 0.0,
        WalletDocument.totalWithdrawn: 0.0,
        WalletDocument.totalWon: 0.0,
        WalletDocument.totalLost: 0.0,
        WalletDocument.createdAt: FieldValue.serverTimestamp(),
        WalletDocument.updatedAt: FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Log error but don't throw - user creation should still succeed
      // ignore: avoid_print
      print('Failed to initialize wallet: $e');
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    final user = currentUser;
    if (user == null) throw AuthException('No user signed in');

    try {
      // Mark user as offline before deletion
      await _firestore.collection(FirestoreSchema.users).doc(user.uid).update({
        UserDocument.isOnline: false,
        UserDocument.lastSeen: FieldValue.serverTimestamp(),
      });

      // Delete user data
      await _firestore.collection(FirestoreSchema.users).doc(user.uid).delete();
      await _firestore
          .collection(FirestoreSchema.wallets)
          .doc(user.uid)
          .delete();

      // Delete Firebase Auth account
      await user.delete();
    } catch (e) {
      throw AuthException('Failed to delete account: ${e.toString()}');
    }
  }
}

class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => message;
}
