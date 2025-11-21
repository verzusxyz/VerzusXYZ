import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:verzus/firestore/firestore_data_schema.dart';

/// Firebase utilities and helper functions
class FirebaseUtils {
  /// ==== FIRESTORE UTILITIES ====

  /// Convert Firestore timestamp to DateTime
  static DateTime? timestampToDateTime(dynamic timestamp) {
    if (timestamp == null) return null;
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is String && timestamp == 'TIMESTAMP') return DateTime.now();
    return null;
  }

  /// Convert DateTime to Firestore timestamp
  static Timestamp dateTimeToTimestamp(DateTime dateTime) {
    return Timestamp.fromDate(dateTime);
  }

  /// Get current timestamp for Firestore
  static Timestamp getCurrentTimestamp() {
    return Timestamp.now();
  }

  /// Generate a new document ID
  static String generateDocumentId([String? collection]) {
    return FirebaseFirestore.instance.collection(collection ?? 'temp').doc().id;
  }

  /// Create server timestamp field value
  static FieldValue serverTimestamp() {
    return FieldValue.serverTimestamp();
  }

  /// Create increment field value
  static FieldValue increment(num value) {
    return FieldValue.increment(value);
  }

  /// Create array union field value
  static FieldValue arrayUnion(List<dynamic> elements) {
    return FieldValue.arrayUnion(elements);
  }

  /// Create array remove field value
  static FieldValue arrayRemove(List<dynamic> elements) {
    return FieldValue.arrayRemove(elements);
  }

  /// ==== AUTHENTICATION UTILITIES ====

  /// Get current user ID
  static String? getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  /// Check if user is authenticated
  static bool isAuthenticated() {
    return FirebaseAuth.instance.currentUser != null;
  }

  /// Get current user email
  static String? getCurrentUserEmail() {
    return FirebaseAuth.instance.currentUser?.email;
  }

  /// Check if user email is verified
  static bool isEmailVerified() {
    return FirebaseAuth.instance.currentUser?.emailVerified ?? false;
  }

  /// ==== DATA VALIDATION ====

  /// Validate email format
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Validate username format
  static bool isValidUsername(String username) {
    return RegExp(r'^[a-zA-Z0-9_]{3,20}$').hasMatch(username);
  }

  /// Normalize username
  static String normalizeUsername(String input) {
    final base = input.trim().toLowerCase();
    final normalized = base.replaceAll(RegExp(r'[^a-z0-9_]+'), '_');
    final collapsed = normalized.replaceAll(RegExp(r'_+'), '_');
    return collapsed.replaceAll(RegExp(r'^_+|_+\$'), '');
  }

  /// Validate password strength
  static bool isStrongPassword(String password) {
    return password.length >= 8 &&
        password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[a-z]')) &&
        password.contains(RegExp(r'[0-9]'));
  }

  /// ==== STORAGE UTILITIES ====

  /// Generate storage path for user uploads
  static String generateUserUploadPath(String userId, String fileName) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = fileName.split('.').last;
    return 'users/$userId/uploads/$timestamp.$extension';
  }

  /// Generate storage path for game screenshots
  static String generateGameScreenshotPath(String gameId, String fileName) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = fileName.split('.').last;
    return 'games/$gameId/screenshots/$timestamp.$extension';
  }

  /// Generate storage path for match evidence
  static String generateMatchEvidencePath(String matchId, String fileName) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = fileName.split('.').last;
    return 'matches/$matchId/evidence/$timestamp.$extension';
  }

  /// Get download URL from storage reference
  static Future<String> getDownloadUrl(Reference ref) async {
    return await ref.getDownloadURL();
  }

  /// ==== ERROR HANDLING ====

  /// Map Firebase Auth errors to user-friendly messages
  static String mapAuthError(FirebaseAuthException e) {
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
        return 'An error occurred. Please try again.';
    }
  }

  /// Map Firestore errors to user-friendly messages
  static String mapFirestoreError(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'You do not have permission to perform this action.';
      case 'unavailable':
        return 'Service is currently unavailable. Please try again later.';
      case 'deadline-exceeded':
        return 'Request timed out. Please try again.';
      case 'resource-exhausted':
        return 'Service quota exceeded. Please try again later.';
      case 'unauthenticated':
        return 'You must be signed in to perform this action.';
      case 'not-found':
        return 'The requested resource was not found.';
      case 'already-exists':
        return 'The resource already exists.';
      case 'invalid-argument':
        return 'Invalid request. Please check your data.';
      default:
        return 'An error occurred while processing your request.';
    }
  }

  /// Map Storage errors to user-friendly messages
  static String mapStorageError(FirebaseException e) {
    switch (e.code) {
      case 'storage/object-not-found':
        return 'File not found.';
      case 'storage/bucket-not-found':
        return 'Storage bucket not found.';
      case 'storage/project-not-found':
        return 'Storage project not found.';
      case 'storage/quota-exceeded':
        return 'Storage quota exceeded.';
      case 'storage/unauthenticated':
        return 'You must be signed in to upload files.';
      case 'storage/unauthorized':
        return 'You do not have permission to upload files.';
      case 'storage/retry-limit-exceeded':
        return 'Upload failed. Please try again.';
      case 'storage/invalid-checksum':
        return 'File upload verification failed.';
      case 'storage/canceled':
        return 'Upload was canceled.';
      case 'storage/invalid-event-name':
        return 'Invalid upload event.';
      case 'storage/invalid-url':
        return 'Invalid file URL.';
      case 'storage/invalid-argument':
        return 'Invalid upload argument.';
      default:
        return 'Upload failed. Please try again.';
    }
  }

  /// ==== QUERY HELPERS ====

  /// Create a query with pagination
  static Query applyPagination(
    Query query, {
    DocumentSnapshot? startAfter,
    int limit = 20,
  }) {
    Query paginatedQuery = query.limit(limit);
    if (startAfter != null) {
      paginatedQuery = paginatedQuery.startAfterDocument(startAfter);
    }
    return paginatedQuery;
  }

  /// Create a query with filters
  static Query applyFilters(Query query, Map<String, dynamic> filters) {
    Query filteredQuery = query;
    for (final entry in filters.entries) {
      if (entry.value != null) {
        filteredQuery = filteredQuery.where(entry.key, isEqualTo: entry.value);
      }
    }
    return filteredQuery;
  }

  /// ==== BATCH OPERATIONS ====

  /// Execute batch write with error handling
  static Future<void> executeBatchWrite(
    List<void Function(WriteBatch)> operations,
  ) async {
    final batch = FirebaseFirestore.instance.batch();
    for (final operation in operations) {
      operation(batch);
    }
    await batch.commit();
  }

  /// ==== TRANSACTION HELPERS ====

  /// Execute transaction with retry logic
  static Future<T> executeTransaction<T>(
    Future<T> Function(Transaction) updateFunction, {
    int maxAttempts = 3,
  }) async {
    return await FirebaseFirestore.instance.runTransaction(
      updateFunction,
      maxAttempts: maxAttempts,
    );
  }

  /// ==== DATA CONVERSION ====

  /// Convert Firestore document to Map
  static Map<String, dynamic> documentToMap(DocumentSnapshot doc) {
    if (!doc.exists) return {};
    final data = doc.data() as Map<String, dynamic>? ?? {};
    data['id'] = doc.id;
    return data;
  }

  /// Convert QuerySnapshot to List of Maps
  static List<Map<String, dynamic>> querySnapshotToList(
      QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) => documentToMap(doc)).toList();
  }

  /// Safe field extraction from Firestore document
  static T? getField<T>(Map<String, dynamic> data, String fieldName,
      [T? defaultValue]) {
    try {
      final value = data[fieldName];
      if (value is T) return value;
      return defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }

  /// ==== CLEANUP UTILITIES ====

  /// Clean up old documents based on timestamp
  static Future<void> cleanupOldDocuments(
    String collection,
    String timestampField,
    Duration maxAge,
  ) async {
    final cutoffDate = DateTime.now().subtract(maxAge);
    final cutoffTimestamp = Timestamp.fromDate(cutoffDate);

    final query = FirebaseFirestore.instance
        .collection(collection)
        .where(timestampField, isLessThan: cutoffTimestamp)
        .limit(500); // Batch delete in chunks

    final snapshot = await query.get();
    if (snapshot.docs.isEmpty) return;

    final batch = FirebaseFirestore.instance.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  /// ==== SECURITY UTILITIES ====

  /// Check if user owns document
  static bool isUserOwner(Map<String, dynamic> document, String? userId) {
    if (userId == null) return false;
    final ownerId =
        document['owner_id'] ?? document['user_id'] ?? document['creator_id'];
    return ownerId == userId;
  }

  /// Sanitize user input
  static String sanitizeInput(String input) {
    // ignore: valid_regexps
    return input.trim().replaceAll(RegExp(r'[<>"\' ']'), '');
  }

  /// ==== PERFORMANCE UTILITIES ====

  /// Enable Firestore offline persistence
  static Future<void> enableOfflinePersistence() async {
    try {
      // Note: Web persistence is enabled differently
      // For Flutter web, persistence is automatically enabled
      // For other platforms, use Settings during initialization
      // ignore: avoid_print
      print(
          'Firestore persistence configuration handled during initialization');
    } catch (e) {
      // Persistence might already be enabled
      // ignore: avoid_print
      print('Failed to enable persistence: $e');
    }
  }

  /// Clear Firestore cache
  static Future<void> clearFirestoreCache() async {
    try {
      await FirebaseFirestore.instance.clearPersistence();
    } catch (e) {
      // ignore: avoid_print
      print('Failed to clear cache: $e');
    }
  }

  /// ==== CONSTANTS ====

  static const int defaultQueryLimit = 20;
  static const int maxBatchSize = 500;
  static const int maxTransactionAttempts = 3;
  static const Duration defaultTimeout = Duration(seconds: 30);

  /// Collection names
  static const String usersCollection = FirestoreSchema.users;
  static const String matchesCollection = FirestoreSchema.matches;
  static const String tournamentsCollection = FirestoreSchema.tournaments;
  static const String walletsCollection = FirestoreSchema.wallets;
  static const String transactionsCollection =
      FirestoreSchema.walletTransactions;
}

/// Firebase connection status
enum FirebaseConnectionStatus {
  connected,
  disconnected,
  connecting,
  error,
}

/// Firebase utilities for connection monitoring
class FirebaseConnectionMonitor {
  static Stream<FirebaseConnectionStatus> get connectionStatus {
    return FirebaseFirestore.instance
        .doc('.info/connected')
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data() as Map<String, dynamic>;
        final isConnected = data['connected'] as bool? ?? false;
        return isConnected
            ? FirebaseConnectionStatus.connected
            : FirebaseConnectionStatus.disconnected;
      }
      return FirebaseConnectionStatus.error;
    });
  }
}
