import 'dart:convert';

import 'package:evento_app/app/urls.dart';
import 'package:evento_app/network_services/core/http_headers.dart';
import 'package:http/http.dart' as http;

class VerifyPaymentResult {
  final bool success;
  final String message;
  final double? paidAmount;
  final String? currency;

  const VerifyPaymentResult({
    required this.success,
    required this.message,
    required this.paidAmount,
    this.currency,
  });
}


class VerifyPaymentService {
  static Future<VerifyPaymentResult> verify({
    required String gateway,
    required String total,
  }) async {
    // API expects POST with query params (?gateway=...&total=...)
    final uri = Uri.parse(
      AppUrls.eventVerifyPayment,
    ).replace(queryParameters: {'gateway': gateway, 'total': total});
    final headers = {...HttpHeadersHelper.base(), 'Accept': 'application/json'};

  // Logging removed.
    try {
      http.Response res = await http
          .post(uri, headers: headers)
          .timeout(const Duration(seconds: 30));

      // Fallback to GET if server only allows GET/HEAD
      if (res.statusCode == 405 ||
          res.statusCode == 404 ||
          (res.statusCode >= 400 && res.body.contains('GET,HEAD'))) {
  // Logging removed.
        res = await http
            .get(uri, headers: headers)
            .timeout(const Duration(seconds: 30));
      }

      Map<String, dynamic> decoded = const {};
      try {
        final raw = json.decode(res.body);
        if (raw is Map<String, dynamic>) decoded = raw;
      } catch (_) {}

      bool ok = decoded['success'] == true || decoded['status'] == true;
      String msg = decoded['message']?.toString() ?? '';
      if (!ok && (res.statusCode < 200 || res.statusCode >= 300)) {
        if (msg.isEmpty) msg = 'Request failed (${res.statusCode})';
      }
      final paidRaw = decoded['paidAmount'] ?? decoded['amount'];
      final paidCurrency =
          (decoded['currency'] ??
                  decoded['paidCurrency'] ??
                  decoded['currency_text'] ??
                  decoded['currencyText'])
              ?.toString();
      double? paid;
      if (paidRaw is num) {
        paid = paidRaw.toDouble();
      } else if (paidRaw is String) {
        paid = double.tryParse(paidRaw);
      }
      return VerifyPaymentResult(
        success: ok,
        message: msg,
        paidAmount: paid,
        currency: paidCurrency,
      );
    } catch (e) {
      return VerifyPaymentResult(
        success: false,
        message: e.toString(),
        paidAmount: null,
        currency: null,
      );
    }
  }
}
