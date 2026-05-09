import 'dart:convert';

import 'package:evento_app/app/urls.dart';
import 'package:http/http.dart' as http;

class StripeIntentResult {
  final bool success;
  final String message;
  final String? id;
  final String? clientSecret;
  StripeIntentResult({
    required this.success,
    required this.message,
    this.id,
    this.clientSecret,
  });
}

class FlutterwaveCreateResult {
  final bool success;
  final String message;
  final String? txRef;
  final String? redirectUrl;
  FlutterwaveCreateResult({
    required this.success,
    required this.message,
    this.txRef,
    this.redirectUrl,
  });
}

class PGWService {
  static Future<StripeIntentResult> createStripeIntent({
    required int amountMinor,
    required String currency,
  }) async {
    final uri = Uri.parse(AppUrls.stripeCreatePaymentIntent);
    final body = json.encode({'amount': amountMinor, 'currency': currency});
    final res = await http
        .post(
          uri,
          headers: const {'Content-Type': 'application/json'},
          body: body,
        )
        .timeout(const Duration(seconds: 30));
    if (res.statusCode < 200 || res.statusCode >= 300) {
      return StripeIntentResult(
        success: false,
        message: 'Stripe error ${res.statusCode}: ${res.body}',
      );
    }
    Map<String, dynamic> decoded = const {};
    try {
      final raw = json.decode(res.body);
      if (raw is Map<String, dynamic>) decoded = raw;
    } catch (e) {
      assert(() { return true; }());
    }
    final id = decoded['id']?.toString();
    final clientSecret = decoded['client_secret']?.toString();
    if (id == null || clientSecret == null) {
      return StripeIntentResult(
        success: false,
        message: 'Invalid Stripe response',
      );
    }
    return StripeIntentResult(
      success: true,
      message: 'ok',
      id: id,
      clientSecret: clientSecret,
    );
  }

  static Future<FlutterwaveCreateResult> createFlutterwavePayment({
    required int amountMinor,
    required String currency,
  }) async {
    final uri = Uri.parse(AppUrls.flutterwaveCreatePayment);
    final body = json.encode({
      'amount_minor': amountMinor,
      'currency': currency,
    });
    final res = await http
        .post(
          uri,
          headers: const {'Content-Type': 'application/json'},
          body: body,
        )
        .timeout(const Duration(seconds: 30));
    if (res.statusCode < 200 || res.statusCode >= 300) {
      return FlutterwaveCreateResult(
        success: false,
        message: 'Flutterwave error ${res.statusCode}: ${res.body}',
      );
    }
    Map<String, dynamic> decoded = const {};
    try {
      final raw = json.decode(res.body);
      if (raw is Map<String, dynamic>) decoded = raw;
    } catch (e) {
      assert(() { return true; }());
    }
    final txRef = decoded['tx_ref']?.toString();
    final redirectUrl = decoded['redirect_url']?.toString();
    if (txRef == null || redirectUrl == null) {
      return FlutterwaveCreateResult(
        success: false,
        message: 'Invalid Flutterwave response',
      );
    }
    return FlutterwaveCreateResult(
      success: true,
      message: 'ok',
      txRef: txRef,
      redirectUrl: redirectUrl,
    );
  }

  static Future<bool> verifyFlutterwave({required String txRef}) async {
    final uri = Uri.parse(AppUrls.flutterwaveVerifyPayment);
    final body = json.encode({'tx_ref': txRef});
    try {
      final res = await http
          .post(
            uri,
            headers: const {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 30));
      if (res.statusCode < 200 || res.statusCode >= 300) return false;
      Map<String, dynamic> decoded = const {};
      try {
        final raw = json.decode(res.body);
        if (raw is Map<String, dynamic>) decoded = raw;
      } catch (e) {
        assert(() { return true; }());
      }
      final ok = decoded['success'] == true || decoded['status'] == true;
      return ok;
    } catch (_) {
      return false;
    }
  }
}
