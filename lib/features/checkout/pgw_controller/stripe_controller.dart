import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:evento_app/network_services/core/pgw_service.dart';
import 'package:evento_app/network_services/core/basic_service.dart';
import 'base_pgw_controller.dart';

class StripeController implements IPaymentController {
  @override
  Future<PaymentOutcome> pay({
    required Map<String, dynamic> data,
    required double amount,
    required int minor,
    required String currency,
    required String fullName,
    required String email,
    required String phone,
    required String customerId,
  }) async {
    // Ensure Stripe publishable key is loaded from basic API (fallbacks handled inside service)
    final pk = await BasicService.getStripePublishableKey();
    if (pk == null || pk.isEmpty) {
      return PaymentOutcome.failure('Stripe publishable key is not configured.');
    }
    Stripe.publishableKey = pk;
    // Many helper backends are configured for USD PaymentIntents.
    // Force USD to avoid currency mismatches that lead to "amount_too_small" conversions.
    final String stripeCurrency = 'usd';
    // Enforce Stripe minimum of $0.50 when using USD; otherwise show a friendly error.
    if (stripeCurrency == 'usd' && minor < 50) {
      return PaymentOutcome.failure(
        'Stripe requires a minimum charge of \$0.50. Please increase quantity or choose another method.',
      );
    }
    final r = await PGWService.createStripeIntent(
      amountMinor: minor,
      currency: stripeCurrency,
    );
    if (!r.success || r.clientSecret == null) {
      return PaymentOutcome.failure('Stripe init failed: ${r.message}');
    }
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: r.clientSecret!,
          merchantDisplayName: 'Evento',
          style: ThemeMode.system,
          allowsDelayedPaymentMethods: true,
        ),
      );
      await Stripe.instance.presentPaymentSheet();
    } on Exception catch (e) {
      return PaymentOutcome.failure('Stripe payment failed: $e');
    }
    final updated = Map<String, dynamic>.from(data);
    updated['gateway'] = 'stripe';
    updated['gatewayType'] = 'online';
    updated['paymentMethod'] = 'stripe';
    updated['paymentStatus'] = 'completed';
    updated['stripe_payment_intent'] = r.id;
    updated['stripe_client_secret'] = r.clientSecret;
    return PaymentOutcome.success(updated);
  }
}
