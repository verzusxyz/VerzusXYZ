import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/firestore/firestore_data_schema.dart';

final affiliateRepositoryProvider = Provider<AffiliateRepository>((ref) {
  return AffiliateRepository(firestore: FirebaseFirestore.instance);
});

class AffiliateRepository {
  final FirebaseFirestore _firestore;

  AffiliateRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  Stream<List<Map<String, dynamic>>> getAffiliateHistory(String userId) {
    return _firestore
        .collection(FirestoreSchema.affiliateEntries)
        .where(AffiliateEntryDocument.userId, isEqualTo: userId)
        .orderBy(AffiliateEntryDocument.createdAt, descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<void> withdrawAffiliateEarnings(String userId) async {
    await _firestore.runTransaction((transaction) async {
      final walletRef = _firestore.collection(FirestoreSchema.wallets).doc(userId);
      final walletDoc = await transaction.get(walletRef);
      if (!walletDoc.exists) {
        throw Exception('Wallet not found');
      }
      final walletData = walletDoc.data() as Map<String, dynamic>;
      final affiliateBalance = (walletData['affiliateBalance'] ?? 0.0).toDouble();
      if (affiliateBalance <= 0) {
        throw Exception('No affiliate earnings to withdraw');
      }
      transaction.update(walletRef, {
        WalletDocument.balance: FieldValue.increment(affiliateBalance),
        'affiliateBalance': 0.0,
        WalletDocument.updatedAt: FieldValue.serverTimestamp(),
      });
    });
  }
}
