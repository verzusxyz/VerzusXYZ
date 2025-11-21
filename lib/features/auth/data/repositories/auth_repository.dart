import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/firestore/firestore_data_schema.dart';
import 'package:verzus/features/auth/data/models/user_model.dart';

/// Provider for the authentication repository.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    firebaseAuth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
  );
});

/// A repository for handling all authentication and user profile actions.
/// This class interacts directly with Firebase Auth and Firestore.
class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRepository({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  })  : _firebaseAuth = firebaseAuth,
        _firestore = firestore;

  /// Stream to listen for authentication state changes.
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Returns the current authenticated user, or null if none.
  User? get currentUser => _firebaseAuth.currentUser;

  /// Signs up a new user with the given [email] and [password].
  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException {
      rethrow;
    }
  }

  /// Signs in a user with the given [email] and [password].
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException {
      rethrow;
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  /// Fetches the user profile for the given [uid].
  /// Returns a [UserModel] or null if the user does not exist.
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection(FirestoreSchema.users).doc(uid).get();
      return doc.exists ? UserModel.fromFirestore(doc) : null;
    } on FirebaseException {
      rethrow;
    }
  }

  /// Creates a new user profile document in Firestore.
  Future<void> createUserProfile({
    required String uid,
    required String email,
    required String username,
    required String displayName,
    required String country,
    String? referredBy,
  }) async {
    try {
      final user = UserModel(
        id: uid,
        email: email,
        username: username,
        displayName: displayName,
        country: country,
        referredBy: referredBy,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _firestore
          .collection(FirestoreSchema.users)
          .doc(uid)
          .set(user.toFirestore());
    } on FirebaseException {
      rethrow;
    }
  }

  /// Updates the user profile for the given [uid] with the provided [updates].
  Future<void> updateUserProfile(String uid, Map<String, dynamic> updates) async {
    try {
      updates[UserDocument.updatedAt] = FieldValue.serverTimestamp();
      await _firestore.collection(FirestoreSchema.users).doc(uid).update(updates);
    } on FirebaseException {
      rethrow;
    }
  }
}
