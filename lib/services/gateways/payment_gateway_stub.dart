import 'package:flutter/widgets.dart';
import 'payment_gateway_base.dart';

// Web-safe no-op implementation. Always returns unsupported.
class PlatformPaymentGateway implements PaymentGatewayFacade {
  @override
  Future<PaymentResult> paystackCheckout({
    required BuildContext context,
    required String publicKey,
    required double amount,
    required String email,
    String? currency,
    String? channel,
  }) async {
    return const PaymentResult(success: false, error: 'Paystack not available on this platform (using test mode).');
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
    return const PaymentResult(success: false, error: 'Flutterwave not available on this platform (using test mode).');
  }
}
