import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/firestore/firestore_data_schema.dart';

/// Provider for the wallet repository.
final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepository(firestore: FirebaseFirestore.instance);
});

/// A repository for handling all wallet-related Firestore operations.
class WalletRepository {
  final FirebaseFirestore _firestore;

  WalletRepository({required FirebaseFirestore firestore}) : _firestore = firestore;

  /// Fetches a user's wallet from Firestore.
  Future<Map<String, dynamic>?> getUserWallet(String userId) async {
    try {
      final doc =
          await _firestore.collection(FirestoreSchema.wallets).doc(userId).get();
      return doc.exists ? doc.data() as Map<String, dynamic> : null;
    } on FirebaseException {
      rethrow;
    }
  }

  /// Listens for real-time updates to a user's wallet.
  Stream<Map<String, dynamic>?> listenToWallet(String userId) {
    return _firestore
        .collection(FirestoreSchema.wallets)
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? doc.data() as Map<String, dynamic> : null);
  }

  /// Retrieves a stream of transactions for a specific user from Firestore.
  Stream<List<Map<String, dynamic>>> getUserTransactions(String userId,
      {int limit = 50}) {
    return _firestore
        .collection(FirestoreSchema.walletTransactions)
        .where(WalletTransactionDocument.userId, isEqualTo: userId)
        .orderBy(WalletTransactionDocument.createdAt, descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList());
  }
}
