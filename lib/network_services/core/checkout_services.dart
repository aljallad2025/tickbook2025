import 'dart:convert';
import 'dart:math';
import 'package:evento_app/app/urls.dart';
import 'package:evento_app/network_services/core/http_headers.dart';
import 'package:evento_app/network_services/core/verify_payment_service.dart';
import 'package:http/http.dart' as http;

const int kAdminFallbackId = 1;

class CheckoutService {
  // Base URL and endpoints are centralized in Urls

  /// Verify payment amount for a specific gateway keyword (server matches gateway directly).
  static Future<num> verifyPaymentForGateway({
    required String amountRaw,
    required String gatewayKeyword,
    Duration timeout = const Duration(seconds: 20),
  }) async {
    final parsed = num.tryParse(amountRaw) ?? 0;
    final variants = <String>{};
    if (parsed % 1 == 0) variants.add(parsed.toStringAsFixed(0));
    variants.add(parsed.toStringAsFixed(2));
    variants.add(parsed.toStringAsFixed(1));

    for (final amt in variants) {
      final r = await VerifyPaymentService.verify(
        gateway: gatewayKeyword,
        total: amt,
      );
      if (r.success && r.paidAmount != null && r.paidAmount! > 0) {
        return r.paidAmount!;
      }
    }
    throw Exception(
      'Payment verification failed for gateway=$gatewayKeyword amount $amountRaw.',
    );
  }

  static Future<num> verifyPaymentSmart({
    required String amountRaw,
    Duration timeout = const Duration(seconds: 25),
  }) async {
    final gateways = <String>[
      'paypal',
      'stripe',
      'flutterwave',
    ]..shuffle(Random());

    final parsed = num.tryParse(amountRaw) ?? 0;
    final variants = <String>{};
    if (parsed % 1 == 0) variants.add(parsed.toStringAsFixed(0));
    variants.add(parsed.toStringAsFixed(2));
    variants.add(parsed.toStringAsFixed(1));

    for (final gw in gateways) {
      for (final amt in variants) {
        final r = await VerifyPaymentService.verify(
          gateway: gw,
          total: amt,
        );
        if (r.success && r.paidAmount != null && r.paidAmount! > 0) {
          return r.paidAmount!;
        }
      }
    }
    throw Exception('Payment verification failed for amount $amountRaw.');
  }

  // ------------------ Checkout (backend finalize) ------------------

  /// Sends final booking/payment to your backend.
  /// If [bearerToken] is provided, adds `Authorization: Bearer <token>`.
  /// You can also merge custom [headers] and control [timeout].
  static Future<Map<String, dynamic>> paymentProcess(
    Map<String, String> fields, {
    String? bearerToken,
    Map<String, String>? headers,
    // Optional single or multiple file attachments: field name -> file path
    Map<String, String>? filePaths,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final req = http.MultipartRequest(
      'POST',
      Uri.parse(AppUrls.paymentProcessUrl),
    );
    req.fields.addAll(fields);

    // Default headers
    final base = HttpHeadersHelper.base();
    req.headers.addAll(base);
    req.headers['Accept'] = 'application/json';
    if (bearerToken != null && bearerToken.isNotEmpty) {
      req.headers['Authorization'] = 'Bearer $bearerToken';
    }
    if (headers != null) {
      req.headers.addAll(headers);
    }

    // Attach files if provided (e.g., offline payment receipt)
    if (filePaths != null && filePaths.isNotEmpty) {
      for (final entry in filePaths.entries) {
        final field = entry.key;
        final path = entry.value;
        if (path.trim().isEmpty) continue;
        try {
          final file = await http.MultipartFile.fromPath(field, path);
          req.files.add(file);
        } catch (_) {
          // Ignore bad file path; server will still get the fields
        }
      }
    }

    final streamed = await req.send().timeout(timeout);
    final body = await streamed.stream.bytesToString();

    if (streamed.statusCode >= 200 && streamed.statusCode < 300) {
      try {
        final js = jsonDecode(body);
        return (js is Map<String, dynamic>) ? js : {'data': js};
      } catch (_) {
        return {'raw': body};
      }
    }

    // Try to extract server error details if JSON
    try {
      final err = jsonDecode(body);
      throw Exception('payment-process ${streamed.statusCode}: $err');
    } catch (_) {
      throw Exception('payment-process ${streamed.statusCode}: $body');
    }
  }
}
