import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/firebase_options.dart';
import 'package:verzus/services/firestore_service.dart';
import 'package:verzus/utils/firebase_utils.dart';

/// Firebase initialization service provider
final firebaseInitializationProvider =
    Provider<FirebaseInitializationService>((ref) {
  return FirebaseInitializationService();
});

/// Firebase initialization status
enum FirebaseInitializationStatus {
  notInitialized,
  initializing,
  initialized,
  error,
}

/// Firebase initialization service
class FirebaseInitializationService {
  FirebaseInitializationStatus _status =
      FirebaseInitializationStatus.notInitialized;
  String? _errorMessage;

  /// Get current initialization status
  FirebaseInitializationStatus get status => _status;

  /// Get error message if initialization failed
  String? get errorMessage => _errorMessage;

  /// Initialize Firebase with all required configurations
  Future<bool> initializeFirebase() async {
    if (_status == FirebaseInitializationStatus.initialized) {
      return true;
    }

    _status = FirebaseInitializationStatus.initializing;

    try {
      // Initialize Firebase Core
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Configure Firestore settings
      await _configureFirestore();

      // Configure Auth settings
      _configureAuth();

      // Enable offline persistence
      await _enableOfflinePersistence();

      // Initialize default data if needed
      await _initializeDefaultData();

      _status = FirebaseInitializationStatus.initialized;
      _errorMessage = null;

      // ignore: avoid_print
      print('Firebase initialized successfully');
      return true;
    } catch (e) {
      _status = FirebaseInitializationStatus.error;
      _errorMessage = e.toString();
      // ignore: avoid_print
      print('Firebase initialization failed: $e');
      return false;
    }
  }

  /// Configure Firestore settings
  Future<void> _configureFirestore() async {
    final firestore = FirebaseFirestore.instance;

    // Configure settings for better performance
    // Note: Settings must be set before any other Firestore operations
    // Persistence is handled during Firebase app initialization

    // Enable network for Firestore
    try {
      await firestore.enableNetwork();
    } catch (e) {
      // ignore: avoid_print
      print('Failed to enable Firestore network: $e');
    }
  }

  /// Configure Firebase Auth settings
  void _configureAuth() {
    final auth = FirebaseAuth.instance;

    // Set language code for auth
    auth.setLanguageCode('en');

    // Configure auth settings
    auth.setPersistence(Persistence.LOCAL);
  }

  /// Enable offline persistence for Firestore
  Future<void> _enableOfflinePersistence() async {
    try {
      await FirebaseUtils.enableOfflinePersistence();
    } catch (e) {
      // ignore: avoid_print
      print('Offline persistence might already be enabled: $e');
    }
  }

  /// Initialize default data in Firestore
  Future<void> _initializeDefaultData() async {
    try {
      final firestoreService = FirestoreService();

      // Check if skill topics exist
      final skillTopicsSnapshot = await FirebaseFirestore.instance
          .collection('skill_topics')
          .limit(1)
          .get();

      if (skillTopicsSnapshot.docs.isEmpty) {
        await firestoreService.initializeSkillTopics();
        // ignore: avoid_print
        print('Default skill topics initialized');
      }

      // Check if system settings exist
      final systemSettingsSnapshot = await FirebaseFirestore.instance
          .collection('system_settings')
          .limit(1)
          .get();

      if (systemSettingsSnapshot.docs.isEmpty) {
        await firestoreService.initializeSystemSettings();
        // ignore: avoid_print
        print('Default system settings initialized');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Failed to initialize default data: $e');
      // Don't throw error, as this is not critical for app functionality
    }
  }

  /// Check if Firebase is properly configured
  Future<bool> isFirebaseConfigured() async {
    try {
      // Try to access Firebase Auth
      final auth = FirebaseAuth.instance;
      if (auth.app.options.projectId.isEmpty) {
        return false;
      }

      // Try to access Firestore
      final firestore = FirebaseFirestore.instance;
      await firestore.doc('health/check').get();

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Reinitialize Firebase if needed
  Future<bool> reinitialize() async {
    _status = FirebaseInitializationStatus.notInitialized;
    return await initializeFirebase();
  }

  /// Get Firebase app information
  Map<String, dynamic> getFirebaseInfo() {
    try {
      final app = Firebase.app();
      return {
        'name': app.name,
        'projectId': app.options.projectId,
        'appId': app.options.appId,
        'apiKey':
            '${app.options.apiKey.substring(0, 10)}...', // Partial for security
        'authDomain': app.options.authDomain,
        'storageBucket': app.options.storageBucket,
        'messagingSenderId': app.options.messagingSenderId,
        'isInitialized': _status == FirebaseInitializationStatus.initialized,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// Test Firebase connectivity
  Future<Map<String, bool>> testConnectivity() async {
    final results = <String, bool>{};

    // Test Auth connectivity
    try {
      await FirebaseAuth.instance.signInAnonymously();
      await FirebaseAuth.instance.signOut();
      results['auth'] = true;
    } catch (e) {
      results['auth'] = false;
      // ignore: avoid_print
      print('Auth connectivity test failed: $e');
    }

    // Test Firestore connectivity
    try {
      await FirebaseFirestore.instance
          .collection('connectivity_test')
          .doc('test')
          .set({'timestamp': FieldValue.serverTimestamp()});
      results['firestore'] = true;
    } catch (e) {
      results['firestore'] = false;
      // ignore: avoid_print
      print('Firestore connectivity test failed: $e');
    }

    return results;
  }

  /// Clean up Firebase resources
  Future<void> cleanup() async {
    try {
      // Clear Firestore cache
      await FirebaseUtils.clearFirestoreCache();

      // Sign out current user
      await FirebaseAuth.instance.signOut();

      // Disable network
      await FirebaseFirestore.instance.disableNetwork();

      _status = FirebaseInitializationStatus.notInitialized;
    } catch (e) {
      // ignore: avoid_print
      print('Failed to cleanup Firebase resources: $e');
    }
  }

  /// Monitor Firebase connection status
  Stream<bool> get connectionStatusStream {
    return FirebaseFirestore.instance
        .doc('.info/connected')
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return false;
      final data = snapshot.data();
      return data?['connected'] as bool? ?? false;
    });
  }
}

/// Firebase health check service
class FirebaseHealthCheck {
  static Future<Map<String, dynamic>> performHealthCheck() async {
    final results = <String, dynamic>{};
    final startTime = DateTime.now();

    try {
      // Check Firebase Core
      final app = Firebase.app();
      results['firebase_core'] = {
        'status': 'healthy',
        'app_name': app.name,
        'project_id': app.options.projectId,
      };
    } catch (e) {
      results['firebase_core'] = {
        'status': 'unhealthy',
        'error': e.toString(),
      };
    }

    try {
      // Check Firestore
      final docRef = FirebaseFirestore.instance.doc('health/check');
      final testData = {
        'timestamp': FieldValue.serverTimestamp(),
        'test_id': DateTime.now().millisecondsSinceEpoch.toString(),
      };

      await docRef.set(testData);
      final doc = await docRef.get();

      if (doc.exists) {
        results['firestore'] = {
          'status': 'healthy',
          'write_test': 'passed',
          'read_test': 'passed',
        };
      } else {
        results['firestore'] = {
          'status': 'unhealthy',
          'error': 'Document not found after write',
        };
      }
    } catch (e) {
      results['firestore'] = {
        'status': 'unhealthy',
        'error': e.toString(),
      };
    }

    try {
      // Check Auth
      final user = FirebaseAuth.instance.currentUser;
      results['auth'] = {
        'status': 'healthy',
        'current_user': user?.uid ?? 'none',
        'email_verified': user?.emailVerified ?? false,
      };
    } catch (e) {
      results['auth'] = {
        'status': 'unhealthy',
        'error': e.toString(),
      };
    }

    final endTime = DateTime.now();
    results['health_check'] = {
      'timestamp': endTime.toIso8601String(),
      'duration_ms': endTime.difference(startTime).inMilliseconds,
      'overall_status': _calculateOverallStatus(results),
    };

    return results;
  }

  static String _calculateOverallStatus(Map<String, dynamic> results) {
    final services = ['firebase_core', 'firestore', 'auth'];
    int healthyServices = 0;

    for (final service in services) {
      if (results[service] != null && results[service]['status'] == 'healthy') {
        healthyServices++;
      }
    }

    if (healthyServices == services.length) {
      return 'healthy';
    } else if (healthyServices > 0) {
      return 'degraded';
    } else {
      return 'unhealthy';
    }
  }
}
