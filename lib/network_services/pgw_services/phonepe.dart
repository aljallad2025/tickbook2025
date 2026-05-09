import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:evento_app/app/app_constants.dart';
import 'package:evento_app/app/app_routes.dart';
import 'package:evento_app/network_services/core/http_headers.dart';

class PhonePeGateway {
  static Future<bool> startCheckout({
    required int amountMinor,
    required String merchantUserId,
    required String name,
    required String email,
    String mobile = '',
    String description = 'Order',
    required String currency,
    Map<String, dynamic>? originalCheckoutArgs,
  }) async {
    final res = await http.post(
      Uri.parse('$pgwBaseUrl/phonepe-create-payment.php'),
      headers: {
        ...HttpHeadersHelper.base(),
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'amount_minor': amountMinor,
        'merchant_user_id': merchantUserId,
        'mobile': mobile,
        'name': name,
        'email': email,
        'description': description,
        'currency': currency.toUpperCase(),
      }),
    );

    if (res.statusCode >= 300) {
      throw Exception('PhonePe create failed: ${res.body}');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final url = data['redirect_url'] as String?;
    final mtx = data['merchant_txn_id'] as String?;
    if (url == null || mtx == null) {
      throw Exception('Missing redirect_url / merchant_txn_id');
    }

    final finished =
        await Get.toNamed(
              AppRoutes.checkoutWebView,
              arguments: {
                'url': url,
                'finishScheme': 'myapp://phonepe-return',
                'title': 'PhonePe',
                'successUrlContains': [
                  'success',
                  'completed',
                  'paid',
                  'captured',
                  'settlement',
                  'settled',
                ],
                'statusUrlTemplate':
                    '$pgwBaseUrl/phonepe-status.php?merchant_txn_id={txnId}',
                'invoiceId': mtx,
                'statusPollIntervalSeconds': 5,
                'statusPollMaxAttempts': 8,
              },
            )
            as bool?;
    // Logging removed for production.
    if (finished != true) return false;

    Future<http.Response> checkOnce() => http.get(
      Uri.parse('$pgwBaseUrl/phonepe-status.php?merchant_txn_id=$mtx'),
      headers: HttpHeadersHelper.base(),
    );

    await Future.delayed(const Duration(milliseconds: 600));
    var st = await checkOnce();
    if (st.statusCode >= 300) {
      await Future.delayed(const Duration(seconds: 2));
      st = await checkOnce();
    }
    if (st.statusCode >= 300) {
      throw Exception('Status failed: ${st.body}');
    }

    bool isSuccessMap(Map<String, dynamic> m) {
      String up(Object? v) => (v ?? '').toString().toUpperCase();
      if (m['success'] == true) return true;
      final s = up(m['status']);
      if (s.contains('SUCCESS') ||
          s == 'COMPLETED' ||
          s == 'PAID' ||
          s == 'CAPTURED' ||
          s == 'SETTLEMENT' ||
          s == 'SETTLED') {
        return true;
      }
      final rs = up(m['result']);
      if (rs.contains('SUCCESS')) return true;
      final txn = up(
        m['transaction_status'] ??
            m['transactionStatus'] ??
            m['payment_status'],
      );
      if (txn.contains('SUCCESS') ||
          txn == 'COMPLETED' ||
          txn == 'CAPTURED' ||
          txn == 'SETTLEMENT' ||
          txn == 'SETTLED') {
        return true;
      }
      final d = m['data'];
      if (d is Map<String, dynamic>) return isSuccessMap(d);
      return false;
    }

    bool success = false;
    try {
      final decoded = jsonDecode(st.body);
      if (decoded is Map<String, dynamic>) success = isSuccessMap(decoded);
      if (!success && decoded is String) {
        final up = decoded.toUpperCase();
        success =
            up.contains('SUCCESS') ||
            up.contains('COMPLETED') ||
            up.contains('PAID');
      }
    } catch (_) {
      final up = st.body.toUpperCase();
      success =
          up.contains('SUCCESS') ||
          up.contains('COMPLETED') ||
          up.contains('PAID');
    }

    int attempts = 0;
    while (!success && attempts < 6) {
      attempts++;
      await Future.delayed(const Duration(seconds: 2));
      final again = await checkOnce();
      if (again.statusCode >= 300) continue;
      try {
        final decoded = jsonDecode(again.body);
        if (decoded is Map<String, dynamic>) success = isSuccessMap(decoded);
        if (!success && decoded is String) {
          final up = decoded.toUpperCase();
          success =
              up.contains('SUCCESS') ||
              up.contains('COMPLETED') ||
              up.contains('PAID');
        }
      } catch (_) {
        final up = again.body.toUpperCase();
        success =
            up.contains('SUCCESS') ||
            up.contains('COMPLETED') ||
            up.contains('PAID');
      }
    }

    // Logging removed.

    return success;
  }
}
