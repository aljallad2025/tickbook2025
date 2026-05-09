import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:evento_app/app/app_constants.dart';
import 'package:evento_app/app/app_routes.dart';
import 'package:evento_app/network_services/core/http_headers.dart';

class MyFatoorahGateway {
  static Future<bool> startCheckout({
    required int amountMinor,
    required String currency,
    required String name,
    required String email,
    String? phone,
    String countryDialCode = "+965",
    String description = 'Order',
  }) async {
    // Sanitize phone to numeric, max 11 digits
    String sanitizedPhone = () {
      final raw = (phone ?? '').trim();
      if (raw.isEmpty) return '';
      final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
      return digits.length > 11 ? digits.substring(0, 11) : digits;
    }();

  // Logging removed for production.
    final res = await http.post(
      Uri.parse('$pgwBaseUrl/myfatoorah-create-payment.php'),
      headers: {
        ...HttpHeadersHelper.base(),
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'amount_minor': amountMinor,
        'currency': currency.toUpperCase(),
        'name': name,
        'email': email,
        'phone': sanitizedPhone,
        'country_dial_code': countryDialCode,
        'description': description,
      }),
    );
  // Logging removed.
    if (res.statusCode >= 300) {
      throw Exception('MyFatoorah create failed: ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final url = data['redirect_url'] as String?;
    final invoiceId = data['invoice_id']?.toString();
    if (url == null || invoiceId == null) {
      throw Exception('Missing redirect_url/invoice_id');
    }

  // Logging removed.
    final finished = await Get.toNamed(
      AppRoutes.checkoutWebView,
      arguments: {
        'url': url,
        'finishScheme': 'myapp://myfatoorah-finish',
        'title': 'MyFatoorah',
        // Enhanced detection / fallback polling support
        'invoiceId': invoiceId,
        'statusUrlTemplate': '$pgwBaseUrl/myfatoorah-status.php?invoice_id={invoiceId}',
        'statusPollIntervalSeconds': 4,
        'statusPollMaxAttempts': 10,
        'successUrlContains': [
          'success', 'paid', 'completed', 'captured', 'approved'
        ],
      },
    ) as bool?;

    if (finished != true) return false;

  // Logging removed.
    Future<http.Response> statusOnce() => http.get(
          Uri.parse('$pgwBaseUrl/myfatoorah-status.php?invoice_id=$invoiceId'),
          headers: HttpHeadersHelper.base(),
        );

    var st = await statusOnce();
    if (st.statusCode >= 300) {
      await Future.delayed(const Duration(seconds: 2));
      st = await statusOnce();
    }
    if (st.statusCode >= 300) {
      throw Exception('Status failed: ${st.body}');
    }

    bool isTruthy(dynamic v) {
      if (v is bool) return v;
      if (v is num) return v == 1 || v > 0;
      if (v is String) {
        final s = v.toLowerCase();
        return s == 'true' || s == '1' || s == 'ok' || s == 'yes' || s == 'paid' || s == 'success' || s == 'completed' || s == 'captured' || s == 'approved';
      }
      return false;
    }

    bool looksPaidString(String s) {
      final up = s.toLowerCase();
      return up.contains('paid') || up.contains('success') || up.contains('completed') || up.contains('captured') || up.contains('approved');
    }

    bool paidDeep(dynamic decoded) {
      if (decoded is Map) {
        for (final entry in decoded.entries) {
          final key = entry.key.toString().toLowerCase();
          final val = entry.value;
          if (key == 'success' || key == 'is_success' || key == 'issuccess' || key == 'ok' || key == 'paid') {
            if (isTruthy(val)) return true;
          }
          if (key.contains('status')) {
            if (val is String && looksPaidString(val)) return true;
          }
          if (key == 'invoicestatus' || key == 'paymentstatus' || key == 'status') {
            if (val is String && looksPaidString(val)) return true;
          }
          if (paidDeep(val)) return true;
        }
        return false;
      }
      if (decoded is List) {
        for (final item in decoded) {
          if (paidDeep(item)) return true;
        }
        return false;
      }
      if (decoded is String) {
        return looksPaidString(decoded);
      }
      return isTruthy(decoded);
    }

    try {
      final js = jsonDecode(st.body);
      final ok = paidDeep(js);
  // Logging removed.
      return ok;
    } catch (_) {
      final ok = paidDeep(st.body);
  // Logging removed.
      return ok;
    }
  }
}

