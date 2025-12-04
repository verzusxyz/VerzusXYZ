import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/firestore/firestore_data_schema.dart';
import 'package:verzus/services/currency_service.dart';
import 'package:verzus/services/gateways/payment_gateway_base.dart';
import 'package:verzus/services/gateways/payment_gateway_selector.dart';

final paymentServiceProvider = Provider<PaymentService>((ref) {
  return PaymentService();
});

class DepositEstimate {
  final double grossAmount; // in local currency
  final String currency;
  final double fee; // gateway fee in local currency
  final double net; // credited to wallet in base currency terms depending on policy
  final double usdEquivalent; // gross in USD for display
  const DepositEstimate({
    required this.grossAmount,
    required this.currency,
    required this.fee,
    required this.net,
    required this.usdEquivalent,
  });
}

class WithdrawalEstimate {
  final double grossAmount; // requested in local currency
  final String currency;
  final double fee; // gateway payout fee in local currency
  final double netReceived; // what user receives in local currency
  final double usdEquivalent; // gross in USD
  const WithdrawalEstimate({
    required this.grossAmount,
    required this.currency,
    required this.fee,
    required this.netReceived,
    required this.usdEquivalent,
  });
}

class PaymentService {
  // Provided public test keys (replace with your real public keys). Do NOT ship secret keys in client apps.
  static const String paystackPublicKey = 'PAYSTACK_PUBLIC_KEY_PLACEHOLDER';
  static const String flutterwavePublicKey = 'FLWPUBK_TEST_PLACEHOLDER';

  // Base currency for the app
  static const String baseCurrency = 'USD';

  static const double gatewayFeeRate = 0.015; // 1.5% sample

  // Demo/test mode flag: in debug/web preview we simulate success
  bool get _isTestMode => kDebugMode || kIsWeb;

  // Platform-aware gateway facade (mobile uses real SDKs; web uses stub)
  final PaymentGatewayFacade _gateway = PlatformPaymentGateway();
  final CurrencyService _currency = CurrencyService();

  // ---------------------------
  // Estimations
  // ---------------------------
  Future<DepositEstimate> estimateDeposit({
    required double amount,
    required String currency,
  }) async {
    final fee = _round(amount * gatewayFeeRate);
    final net = _round(amount - fee);
    final usdEq = await _currency.convert(amount: amount, from: currency, to: baseCurrency);
    return DepositEstimate(
      grossAmount: amount,
      currency: currency,
      fee: fee,
      net: net,
      usdEquivalent: usdEq,
    );
  }

  Future<WithdrawalEstimate> estimateWithdrawal({
    required double amount,
    required String currency,
  }) async {
    final fee = _round(amount * gatewayFeeRate);
    final net = _round(amount - fee);
    final usdEq = await _currency.convert(amount: amount, from: currency, to: baseCurrency);
    return WithdrawalEstimate(
      grossAmount: amount,
      currency: currency,
      fee: fee,
      netReceived: net,
      usdEquivalent: usdEq,
    );
  }

  // ---------------------------
  // Deposits
  // ---------------------------
  Future<void> depositWithPaystack({
    required BuildContext context,
    required String userId,
    required String email,
    required double amount,
    required String currency,
    String? channel,
  }) async {
    if (_isTestMode) {
      // Simulate success in test mode
      debugPrint('[PaymentService] TestMode deposit (Paystack) amount=$amount $currency');
      final est = await estimateDeposit(amount: amount, currency: currency);
      await _recordDeposit(
        userId: userId,
        grossAmount: amount,
        fee: est.fee,
        net: est.net,
        currency: currency,
        usdEquivalent: est.usdEquivalent,
        method: 'paystack',
        externalRef: 'test_${_randId()}',
      );
      return;
    }

    final result = await _gateway.paystackCheckout(
      context: context,
      publicKey: paystackPublicKey,
      amount: amount,
      email: email,
      currency: currency,
      channel: channel,
    );

    if (result.success) {
      final est = await estimateDeposit(amount: amount, currency: currency);
      await _recordDeposit(
        userId: userId,
        grossAmount: amount,
        fee: est.fee,
        net: est.net,
        currency: currency,
        usdEquivalent: est.usdEquivalent,
        method: 'paystack',
        externalRef: result.reference ?? 'ps_${_randId()}',
      );
    } else {
      throw Exception(result.error ?? 'Paystack payment failed');
    }
  }

  Future<void> depositWithFlutterwave({
    required BuildContext context,
    required String userId,
    required String email,
    required String fullName,
    required double amount,
    required String currency,
    String? channel,
  }) async {
    if (_isTestMode) {
      debugPrint('[PaymentService] TestMode deposit (Flutterwave) amount=$amount $currency');
      final est = await estimateDeposit(amount: amount, currency: currency);
      await _recordDeposit(
        userId: userId,
        grossAmount: amount,
        fee: est.fee,
        net: est.net,
        currency: currency,
        usdEquivalent: est.usdEquivalent,
        method: 'flutterwave',
        externalRef: 'test_${_randId()}',
      );
      return;
    }

    final result = await _gateway.flutterwaveCheckout(
      context: context,
      publicKey: flutterwavePublicKey,
      amount: amount,
      email: email,
      fullName: fullName,
      currency: currency,
      channel: channel,
    );

    if (result.success) {
      final est = await estimateDeposit(amount: amount, currency: currency);
      await _recordDeposit(
        userId: userId,
        grossAmount: amount,
        fee: est.fee,
        net: est.net,
        currency: currency,
        usdEquivalent: est.usdEquivalent,
        method: 'flutterwave',
        externalRef: result.reference ?? 'fw_${_randId()}',
      );
    } else {
      throw Exception(result.error ?? 'Flutterwave payment failed');
    }
  }

  Future<void> _recordDeposit({
    required String userId,
    required double grossAmount,
    required double fee,
    required double net,
    required String currency,
    required double usdEquivalent,
    required String method,
    required String externalRef,
  }) async {
    final batch = FirebaseFirestore.instance.batch();
    final walletRef = FirebaseFirestore.instance.collection(FirestoreSchema.wallets).doc(userId);
    final txRef = FirebaseFirestore.instance.collection(FirestoreSchema.walletTransactions).doc();

    // Ensure wallet exists and increment via merge
    batch.set(walletRef, {
      WalletDocument.userId: userId,
      WalletDocument.balance: FieldValue.increment(net),
      WalletDocument.totalDeposited: FieldValue.increment(grossAmount),
      WalletDocument.updatedAt: FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    batch.set(txRef, {
      WalletTransactionDocument.id: txRef.id,
      WalletTransactionDocument.userId: userId,
      WalletTransactionDocument.type: FirestoreConstants.transactionTypeDeposit,
      WalletTransactionDocument.amount: net, // legacy amount field keeps net
      WalletTransactionDocument.status: FirestoreConstants.transactionStatusCompleted,
      WalletTransactionDocument.description: 'Deposit ${grossAmount.toStringAsFixed(2)} $currency (fee ${fee.toStringAsFixed(2)}) via $method',
      WalletTransactionDocument.paymentMethod: method,
      WalletTransactionDocument.externalTransactionId: externalRef,
      // Extended fields for transparency
      'currency': currency,
      'gross_amount': _round(grossAmount),
      'gateway_fee': _round(fee),
      'net_amount': _round(net),
      'usd_equivalent': _round(usdEquivalent),
      WalletTransactionDocument.createdAt: FieldValue.serverTimestamp(),
      WalletTransactionDocument.updatedAt: FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  // ---------------------------
  // Withdrawals
  // ---------------------------
  Future<void> requestWithdrawal({
    required String userId,
    required double amount,
    required String method, // 'paystack' | 'flutterwave'
    String currency = baseCurrency,
    String? note, // optional payout details for admin
  }) async {
    if (amount <= 0) {
      throw Exception('Amount must be greater than 0');
    }

    final est = await estimateWithdrawal(amount: amount, currency: currency);

    final firestore = FirebaseFirestore.instance;
    final walletRef = firestore.collection(FirestoreSchema.wallets).doc(userId);
    final txRef = firestore.collection(FirestoreSchema.walletTransactions).doc();

    await firestore.runTransaction((txn) async {
      final walletSnap = await txn.get(walletRef);
      if (!walletSnap.exists) {
        throw Exception('Wallet not found');
      }
      final data = walletSnap.data() as Map<String, dynamic>;
      final currentBalance = (data[WalletDocument.balance] ?? 0.0).toDouble();
      if (currentBalance < amount) {
        throw Exception('Insufficient balance');
      }

      // Deduct the requested amount immediately and record a pending withdrawal
      txn.update(walletRef, {
        WalletDocument.balance: currentBalance - amount,
        WalletDocument.updatedAt: FieldValue.serverTimestamp(),
      });

      txn.set(txRef, {
        WalletTransactionDocument.id: txRef.id,
        WalletTransactionDocument.userId: userId,
        WalletTransactionDocument.type: FirestoreConstants.transactionTypeWithdrawal,
        WalletTransactionDocument.amount: amount, // legacy amount keeps gross requested
        WalletTransactionDocument.status: FirestoreConstants.transactionStatusPending,
        WalletTransactionDocument.description: note ?? 'Withdrawal request via $method',
        WalletTransactionDocument.paymentMethod: method,
        WalletTransactionDocument.externalTransactionId: null,
        // Extended fields
        'currency': currency,
        'gross_amount': _round(amount),
        'gateway_fee': _round(est.fee),
        'net_received': _round(est.netReceived),
        'usd_equivalent': _round(est.usdEquivalent),
        WalletTransactionDocument.createdAt: FieldValue.serverTimestamp(),
        WalletTransactionDocument.updatedAt: FieldValue.serverTimestamp(),
      });
    });

    // In test mode, auto-complete the withdrawal
    if (_isTestMode) {
      debugPrint('[PaymentService] TestMode withdrawal request amount=$amount $currency via $method');
      await firestore.runTransaction((txn) async {
        final walletSnap = await txn.get(walletRef);
        if (!walletSnap.exists) return;
        txn.update(walletRef, {
          WalletDocument.totalWithdrawn: FieldValue.increment(amount),
          WalletDocument.updatedAt: FieldValue.serverTimestamp(),
        });
        txn.update(txRef, {
          WalletTransactionDocument.status: FirestoreConstants.transactionStatusCompleted,
          WalletTransactionDocument.updatedAt: FieldValue.serverTimestamp(),
          WalletTransactionDocument.externalTransactionId: 'test_${_randId()}',
        });
      });
    }
  }

  String _randId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final rand = Random();
    return List.generate(10, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  double _round(double v) => double.parse(v.toStringAsFixed(2));
}
