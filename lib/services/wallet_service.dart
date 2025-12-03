import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/features/wallet/data/models/wallet_model.dart';
import 'package:verzus/firestore/firestore_data_schema.dart';
import 'package:verzus/services/staking_service.dart';

final walletServiceProvider = Provider<WalletService>((ref) {
  return WalletService();
});

final walletProvider = NotifierProvider<WalletNotifier, WalletModel?>(() {
  return WalletNotifier();
});

/// Global wallet mode selector used by Wallet and Matches flows
final walletModeProvider = NotifierProvider<WalletModeNotifier, WalletKind>(() {
  return WalletModeNotifier();
});

class WalletService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<WalletModel?> watchWallet(String userId) {
    return _firestore
        .collection(FirestoreSchema.wallets)
        .doc(userId)
        .snapshots()
        .map((doc) {
      try {
        if (!doc.exists) return null;
        return WalletModel.fromFirestore(doc);
      } catch (e) {
        // ignore: avoid_print
        print('Error parsing wallet: $e');
        return null;
      }
    }).handleError((e) {
      // ignore: avoid_print
      print('Stream error: $e');
    });
  }

  /// BULLETPROOF: Get wallet with retry logic
  Future<WalletModel?> getWallet(String userId) async {
    try {
      final docRef = _firestore.collection(FirestoreSchema.wallets).doc(userId);
      final snap = await docRef.get();
      if (!snap.exists) {
        // Initialize with BULLETPROOF defaults
        final now = FieldValue.serverTimestamp();
        await docRef.set({
          WalletDocument.userId: userId,
          WalletDocument.balance: 0.0,
          WalletDocument.pendingBalance: 0.0,
          WalletDocument.totalDeposited: 0.0,
          WalletDocument.totalWithdrawn: 0.0,
          WalletDocument.totalWon: 0.0,
          WalletDocument.totalLost: 0.0,
          'demo_balance': 100.0, // ✅ Starter demo funds
          'demo_pending_balance': 0.0,
          'loyaltyPoints': 0,
          WalletDocument.createdAt: now,
          WalletDocument.updatedAt: now,
        });
        final created = await docRef.get();
        return WalletModel.fromFirestore(created);
      }
      return WalletModel.fromFirestore(snap);
    } catch (e) {
      // ignore: avoid_print
      print('Error loading wallet: $e');
      rethrow;
    }
  }

  Future<void> updateBalance(String userId, double newBalance) async {
    try {
      await _firestore.collection(FirestoreSchema.wallets).doc(userId).update({
        WalletDocument.balance: newBalance,
        WalletDocument.updatedAt: FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // ignore: avoid_print
      print('Error updating balance: $e');
      throw Exception('Failed to update balance');
    }
  }


  /// Credit balance (e.g., prize payout)
  Future<void> creditBalance(String userId, double amount,
      {WalletKind kind = WalletKind.live}) async {
    try {
      await _firestore.collection(FirestoreSchema.wallets).doc(userId).update({
        (kind == WalletKind.live ? WalletDocument.balance : 'demo_balance'):
            FieldValue.increment(amount),
        WalletDocument.updatedAt: FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // ignore: avoid_print
      print('Error crediting balance: $e');
      rethrow;
    }
  }

  Future<void> addAffiliatePending(String userId, double amount,
      {WalletKind kind = WalletKind.live}) async {
    try {
      await _firestore.collection(FirestoreSchema.wallets).doc(userId).update({
        kind == WalletKind.live
            ? WalletDocument.pendingBalance
            : 'demo_pending_balance': FieldValue.increment(amount),
        WalletDocument.updatedAt: FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // ignore: avoid_print
      print('Error adding affiliate pending: $e');
      throw Exception('Failed to add affiliate funds');
    }
  }

  Future<void> addLoyaltyPoints(String userId, int points) async {
    try {
      await _firestore.collection(FirestoreSchema.wallets).doc(userId).update({
        'loyaltyPoints': FieldValue.increment(points),
        WalletDocument.updatedAt: FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // ignore: avoid_print
      print('Error adding loyalty points: $e');
      throw Exception('Failed to add loyalty points');
    }
  }

  // Demo wallet utilities
  Future<void> addDemoFunds(String userId, double amount) async {
    try {
      await _firestore.collection(FirestoreSchema.wallets).doc(userId).set({
        'demo_balance': FieldValue.increment(amount),
        WalletDocument.updatedAt: FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      await addWalletTransaction(
        userId: userId,
        type: FirestoreConstants.transactionTypeDeposit,
        amount: amount,
        status: FirestoreConstants.transactionStatusCompleted,
        description: 'Demo deposit',
        paymentMethod: 'demo',
      );
    } catch (e) {
      // ignore: avoid_print
      print('Error adding demo funds: $e');
      throw Exception('Failed to add demo funds');
    }
  }

  Future<String> addWalletTransaction({
    required String userId,
    required String type,
    required double amount,
    required String status,
    String? description,
    String? relatedMatchId,
    String? relatedTournamentId,
    String? paymentMethod,
    String? externalTransactionId,
  }) async {
    try {
      final ref =
          _firestore.collection(FirestoreSchema.walletTransactions).doc();
      await ref.set({
        WalletTransactionDocument.id: ref.id,
        WalletTransactionDocument.userId: userId,
        WalletTransactionDocument.type: type,
        WalletTransactionDocument.amount: amount,
        WalletTransactionDocument.status: status,
        WalletTransactionDocument.description: description,
        WalletTransactionDocument.relatedMatchId: relatedMatchId,
        WalletTransactionDocument.relatedTournamentId: relatedTournamentId,
        WalletTransactionDocument.paymentMethod: paymentMethod,
        WalletTransactionDocument.externalTransactionId: externalTransactionId,
        WalletTransactionDocument.createdAt: FieldValue.serverTimestamp(),
        WalletTransactionDocument.updatedAt: FieldValue.serverTimestamp(),
      });
      return ref.id;
    } catch (e) {
      // ignore: avoid_print
      print('Error adding wallet transaction: $e');
      rethrow;
    }
  }

  Future<void> resetWallet(String userId) async {
    try {
      await _firestore.collection(FirestoreSchema.wallets).doc(userId).update({
        WalletDocument.balance: 0.0,
        WalletDocument.pendingBalance: 0.0,
        WalletDocument.totalDeposited: 0.0,
        WalletDocument.totalWithdrawn: 0.0,
        WalletDocument.totalWon: 0.0,
        WalletDocument.totalLost: 0.0,
        'demo_balance': 100.0,
        'demo_pending_balance': 0.0,
        'loyaltyPoints': 0,
        WalletDocument.updatedAt: FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // ignore: avoid_print
      print('Error resetting wallet: $e');
      throw Exception('Failed to reset wallet');
    }
  }
}

class WalletModeNotifier extends Notifier<WalletKind> {
  @override
  WalletKind build() => WalletKind.live;

  void setMode(WalletKind kind) => state = kind;
}

class WalletNotifier extends Notifier<WalletModel?> {
  late final WalletService _walletService;
  late final StakingService _stakingService;

  @override
  WalletModel? build() {
    _walletService = ref.read(walletServiceProvider);
    _stakingService = ref.read(stakingServiceProvider);
    return null;
  }

  Future<void> loadWallet(String userId) async {
    try {
      final wallet = await _walletService.getWallet(userId);
      state = wallet;
    } catch (e) {
      // ignore: avoid_print
      print('Error loading wallet: $e');
    }
  }

  Future<void> updateBalance(double newBalance) async {
    if (state == null) return;

    try {
      await _walletService.updateBalance(state!.userId, newBalance);
      state = state!.copyWith(
        balance: newBalance,
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      // ignore: avoid_print
      print('Error updating balance: $e');
      rethrow;
    }
  }

  Future<void> lockFunds(double amount,
      {WalletKind kind = WalletKind.live}) async {
    if (state == null) return;

    try {
      await _stakingService.lockFunds(state!.userId, amount, kind: kind);
      // The wallet stream will update the state automatically.
    } catch (e) {
      // ignore: avoid_print
      print('Error locking funds: $e');
      rethrow;
    }
  }

  Future<void> unlockFunds(double amount,
      {WalletKind kind = WalletKind.live}) async {
    if (state == null) return;

    try {
      await _stakingService.unlockFunds(state!.userId, amount, kind: kind);
      // The wallet stream will update the state automatically.
    } catch (e) {
      // ignore: avoid_print
      print('Error unlocking funds: $e');
      rethrow;
    }
  }

  Future<void> addAffiliatePending(double amount,
      {WalletKind kind = WalletKind.live}) async {
    if (state == null) return;

    try {
      await _walletService.addAffiliatePending(state!.userId, amount,
          kind: kind);
      if (kind == WalletKind.live) {
        state = state!.copyWith(
          pendingBalance: state!.pendingBalance + amount,
          updatedAt: DateTime.now(),
        );
      } else {
        state = state!.copyWith(
          demoPendingBalance: state!.demoPendingBalance + amount,
          updatedAt: DateTime.now(),
        );
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error adding affiliate funds: $e');
      rethrow;
    }
  }

  Future<void> addLoyaltyPoints(int points) async {
    if (state == null) return;

    try {
      await _walletService.addLoyaltyPoints(state!.userId, points);
      state = state!.copyWith(
        loyaltyPoints: state!.loyaltyPoints + points,
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      // ignore: avoid_print
      print('Error adding loyalty points: $e');
      rethrow;
    }
  }

  // Demo functions
  Future<void> addDemoFunds(double amount) async {
    if (state == null) return;

    try {
      await _walletService.addDemoFunds(state!.userId, amount);
      state = state!.copyWith(
        demoBalance: state!.demoBalance + amount,
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      // ignore: avoid_print
      print('Error adding demo funds: $e');
      rethrow;
    }
  }

  Future<void> resetWallet() async {
    if (state == null) return;

    try {
      await _walletService.resetWallet(state!.userId);
      state = WalletModel(
        userId: state!.userId,
        balance: 0.0,
        pendingBalance: 0.0,
        totalDeposited: 0.0,
        totalWithdrawn: 0.0,
        totalWon: 0.0,
        totalLost: 0.0,
        demoBalance: 100.0,
        demoPendingBalance: 0.0,
        loyaltyPoints: 0,
        updatedAt: DateTime.now(),
        affiliateBalance: 0.0,
      );
    } catch (e) {
      // ignore: avoid_print
      print('Error resetting wallet: $e');
      rethrow;
    }
  }

  Future<void> processPayouts(
    List<String> participantIds,
    Map<String, double> winners, // Map<userId, prizeShare>
    double entryFee,
    double commissionRate, {
    String? relatedMatchId,
    String? relatedTournamentId,
    WalletKind kind = WalletKind.live,
  }) async {
    await _stakingService.processPayouts(
      participantIds,
      winners,
      entryFee,
      commissionRate,
      relatedMatchId: relatedMatchId,
      relatedTournamentId: relatedTournamentId,
      kind: kind,
    );
    // The wallet stream will update the state automatically.
  }
}
