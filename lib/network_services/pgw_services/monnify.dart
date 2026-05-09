import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:evento_app/app/app_constants.dart';
import 'package:evento_app/app/app_routes.dart';
import 'package:evento_app/network_services/core/http_headers.dart';

class MonnifyGateway {
  static Future<bool> startCheckout({
    required int amountMinor,
    required String name,
    required String email,
    required String phone,
    String description = 'Order',
  }) async {
  // Logging removed for production.
    final res = await http.post(
      Uri.parse('$pgwBaseUrl/monnify-create.php'),
      headers: {
        ...HttpHeadersHelper.base(),
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'amount_minor': amountMinor,
        'name': name,
        'email': email,
        'phone': phone,
        'description': description,
      }),
    );
  // Logging removed.
    if (res.statusCode >= 300) {
      throw Exception('Monnify create failed: ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final url = data['redirect_url'] as String?;
    final trx = (data['transactionReference'] ?? '').toString();
    final pref = (data['paymentReference'] ?? '').toString();
    if (url == null || (trx.isEmpty && pref.isEmpty)) {
      throw Exception('Missing redirect_url/transactionReference');
    }

  // Logging removed.
    final finished = await Get.toNamed(
      AppRoutes.checkoutWebView,
      arguments: {
        'url': url,
        'finishScheme': 'myapp://monnify-finish',
        'title': 'Monnify',
      },
    ) as bool?;

    if (finished != true) return false;

    final statusUrl = trx.isNotEmpty
        ? Uri.parse('$pgwBaseUrl/monnify-status.php?transactionReference=$trx')
        : Uri.parse('$pgwBaseUrl/monnify-status.php?paymentReference=$pref');
  // Logging removed.
    final st = await http.get(statusUrl, headers: HttpHeadersHelper.base());
    if (st.statusCode >= 300) {
      throw Exception('Status failed: ${st.body}');
    }

    bool success(dynamic decoded) {
      if (decoded is Map<String, dynamic>) {
        final s = (decoded['status'] ?? 'UNKNOWN').toString().toUpperCase();
        return s == 'PAID' || s == 'SUCCESS' || s == 'COMPLETED';
      }
      if (decoded is String) {
        final up = decoded.toUpperCase();
        return up.contains('PAID') || up.contains('SUCCESS');
      }
      return false;
    }

    try {
      final js = jsonDecode(st.body);
      final ok = success(js);
  // Logging removed.
      return ok;
    } catch (_) {
      final ok = success(st.body);
  // Logging removed.
      return ok;
    }
  }
}

