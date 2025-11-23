import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:cloud_functions/cloud_functions.dart';

import 'payment_gateway_base.dart';

// Mobile impl now also uses Cloud Functions hosted checkout to support all channels
class PlatformPaymentGateway implements PaymentGatewayFacade {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<PaymentResult> _openHostedCheckout({
    required BuildContext context,
    required String initFunctionName,
    required String verifyFunctionName,
    required Map<String, dynamic> initPayload,
  }) async {
    try {
      final callable = _functions.httpsCallable(initFunctionName);
      final resp = await callable.call(initPayload);
      final data = resp.data as Map;
      final String? authUrl = data['authorizationUrl'] as String? ?? data['authUrl'] as String?;
      final String? reference = data['reference'] as String? ?? data['txRef'] as String?;

      if (authUrl == null || authUrl.isEmpty || reference == null || reference.isEmpty) {
        return const PaymentResult(success: false, error: 'Server did not return authorization URL');
      }

      final launched = await launchUrlString(authUrl, mode: LaunchMode.externalApplication);
      if (!launched) {
        return const PaymentResult(success: false, error: 'Unable to open payment page');
      }

      final verifier = _functions.httpsCallable(verifyFunctionName);
      const total = 30;
      for (int i = 0; i < total; i++) {
        await Future.delayed(const Duration(seconds: 3));
        try {
          final v = await verifier.call(<String, dynamic>{'reference': reference});
          final vData = (v.data as Map?) ?? const {};
          final status = (vData['status'] ?? '').toString().toLowerCase();
          if (status == 'success' || status == 'successful') {
            return PaymentResult(success: true, reference: reference);
          }
          if (status == 'failed' || status == 'cancelled' || status == 'error') {
            return const PaymentResult(success: false, error: 'Payment failed');
          }
        } catch (_) {}
      }

      return const PaymentResult(success: false, error: 'Payment not confirmed in time');
    } catch (e) {
      return PaymentResult(success: false, error: 'Gateway error: $e');
    }
  }

  @override
  Future<PaymentResult> paystackCheckout({
    required BuildContext context,
    required String publicKey,
    required double amount,
    required String email,
    String? currency,
    String? channel,
  }) async {
    return _openHostedCheckout(
      context: context,
      initFunctionName: 'initPaystackTransaction',
      verifyFunctionName: 'verifyPaystackTransaction',
      initPayload: <String, dynamic>{
        'amount': amount,
        'currency': currency ?? 'USD',
        'email': email,
        if (channel != null) 'channel': channel,
      },
    );
  }

  @override
  Future<PaymentResult> flutterwaveCheckout({
    required BuildContext context,
    required String publicKey,
    required double amount,
    required String email,
    required String fullName,
    String? currency,
    String? channel,
  }) async {
    return _openHostedCheckout(
      context: context,
      initFunctionName: 'initFlutterwavePayment',
      verifyFunctionName: 'verifyFlutterwavePayment',
      initPayload: <String, dynamic>{
        'amount': amount,
        'currency': currency ?? 'USD',
        'email': email,
        'name': fullName,
        if (channel != null) 'channel': channel,
      },
    );
  }
}
