import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:verzus/firebase_options.dart';

/// A centralized service for Firebase initialization and core configurations.
/// This service ensures that Firebase is initialized only once and provides
/// a single source of truth for core Firebase settings.
class FirebaseService {
  FirebaseService._(); // Private constructor

  static final FirebaseService instance = FirebaseService._();

  bool _isInitialized = false;

  /// Initializes the Firebase app and configures core settings.
  /// This method should be called once at app startup.
  Future<void> initialize() async {
    if (_isInitialized) {
      if (kDebugMode) {
        print('Firebase is already initialized.');
      }
      return;
    }

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      _configureFirestore();
      _configureAuth();

      _isInitialized = true;
      if (kDebugMode) {
        print('Firebase initialized successfully.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Firebase initialization failed: $e');
      }
      // Re-throw the error to be handled by the app's error reporting service.
      rethrow;
    }
  }

  /// Configures Firestore settings for the app.
  void _configureFirestore() {
    final firestore = FirebaseFirestore.instance;

    // Set persistence to be enabled for offline access.
    // On web, this is handled automatically. For mobile, it's a good practice.
    if (!kIsWeb) {
      firestore.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
    }
  }

  /// Configures Firebase Auth settings.
  void _configureAuth() {
    final auth = FirebaseAuth.instance;

    // Set the default persistence to local.
    auth.setPersistence(Persistence.LOCAL);
  }

  /// Returns a server-generated timestamp.
  static FieldValue serverTimestamp() => FieldValue.serverTimestamp();

  /// Maps a [FirebaseAuthException] to a user-friendly error message.
  static String mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'weak-password':
        return 'Your password is too weak. Please choose a stronger one.';
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
        return 'An error occurred. Please try again.';
    }
  }
}
