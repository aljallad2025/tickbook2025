import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

import 'package:evento_app/app/app_constants.dart';
import 'package:evento_app/network_services/core/basic_service.dart';

class StripeServerGateway {
  static Future<bool> startCardPayment({
    required BuildContext context,
    required int amountMinor,
    required String currency,
    String merchantName = 'Evento',
  }) async {
    try {
      // Ensure publishable key is configured (must come from backend get-basic)
      final apiKey = await BasicService.getStripePublishableKey();
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('Stripe publishable key not provided by API');
      }
      Stripe.publishableKey = apiKey;
      await Stripe.instance.applySettings();

      // 1) Ask your server for a PaymentIntent client_secret
      final res = await http.post(
        Uri.parse('$pgwBaseUrl/create-payment-intent.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'amount': amountMinor, 'currency': currency}),
      );
      if (res.statusCode >= 300) {
        throw Exception('Create PI failed: ${res.body}');
      }
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final clientSecret = data['client_secret'] as String?;
      if (clientSecret == null || clientSecret.isEmpty) {
        throw Exception('No client_secret in response');
      }

      // 2) Init and present PaymentSheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: merchantName,
          style: ThemeMode.system,
        ),
      );

      await Stripe.instance.presentPaymentSheet();
      return true;
    } on StripeException catch (e) {
      // Treat user cancellations as non-fatal false
      if (e.error.code == FailureCode.Canceled) return false;
      rethrow;
    }
  }
}
