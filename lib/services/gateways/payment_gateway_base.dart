import 'package:flutter/widgets.dart';

class PaymentResult {
  final bool success;
  final String? reference;
  final String? error;

  const PaymentResult({required this.success, this.reference, this.error});
}

abstract class PaymentGatewayFacade {
  Future<PaymentResult> paystackCheckout({
    required BuildContext context,
    required String publicKey,
    required double amount,
    required String email,
    String? currency,
    String? channel, // e.g., 'card', 'bank_transfer', 'ussd', 'mobile_money'
  });

  Future<PaymentResult> flutterwaveCheckout({
    required BuildContext context,
    required String publicKey,
    required double amount,
    required String email,
    required String fullName,
    String? currency,
    String? channel, // e.g., 'card', 'banktransfer', 'ussd', 'mpesa', 'mobilemoney'
  });
}
