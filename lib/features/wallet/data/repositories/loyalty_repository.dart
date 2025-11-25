import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/firestore/firestore_data_schema.dart';

final loyaltyRepositoryProvider = Provider<LoyaltyRepository>((ref) {
  return LoyaltyRepository(firestore: FirebaseFirestore.instance);
});

class LoyaltyRepository {
  final FirebaseFirestore _firestore;

  LoyaltyRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  Stream<List<Map<String, dynamic>>> getLoyaltyHistory(String userId) {
    return _firestore
        .collection(FirestoreSchema.loyaltyEntries)
        .where(LoyaltyEntryDocument.userId, isEqualTo: userId)
        .orderBy(LoyaltyEntryDocument.createdAt, descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<void> redeemLoyaltyPoints(String userId) async {
    await _firestore.runTransaction((transaction) async {
      final walletRef = _firestore.collection(FirestoreSchema.wallets).doc(userId);
      final walletDoc = await transaction.get(walletRef);
      if (!walletDoc.exists) {
        throw Exception('Wallet not found');
      }
      final walletData = walletDoc.data() as Map<String, dynamic>;
      final loyaltyPoints = walletData['loyaltyPoints'] ?? 0;
      if (loyaltyPoints <= 0) {
        throw Exception('No loyalty points to redeem');
      }
      final cashValue = loyaltyPoints / 100;
      transaction.update(walletRef, {
        WalletDocument.balance: FieldValue.increment(cashValue),
        'loyaltyPoints': 0,
        WalletDocument.updatedAt: FieldValue.serverTimestamp(),
      });
    });
  }
}
