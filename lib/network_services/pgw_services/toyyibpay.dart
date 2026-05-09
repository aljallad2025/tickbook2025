import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:evento_app/app/app_constants.dart';
import 'package:evento_app/app/app_routes.dart';
import 'package:evento_app/network_services/core/http_headers.dart';

class ToyyibpayGateway {
  static Future<bool> startCheckout({
    required int amountMinor,
    required String name,
    required String email,
    required String phone,
    String description = 'Order',
  }) async {
    final res = await http.post(
      Uri.parse('$pgwBaseUrl/toyyibpay-create-bill.php'),
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

    if (res.statusCode >= 300) {
      throw Exception('Toyyibpay create failed: ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final url = data['redirect_url'] as String?;
    final billCode = data['billCode'] as String?;
    if (url == null || billCode == null) {
      throw Exception('Missing redirect_url/billCode');
    }

    final finished =
        await Get.toNamed(
              AppRoutes.checkoutWebView,
              arguments: {
                'url': url,
                'finishScheme': 'myapp://toyyibpay-finish',
                'title': 'Toyyibpay',
              },
            )
            as bool?;

    if (finished != true) return false;

    final st = await http.get(
      Uri.parse('$pgwBaseUrl/toyyibpay-status.php?billCode=$billCode'),
      headers: HttpHeadersHelper.base(),
    );
    if (st.statusCode >= 300) {
      throw Exception('Status failed: ${st.body}');
    }

    bool isPaid(dynamic decoded) {
      if (decoded is Map<String, dynamic>) {
        final s = (decoded['status'] ?? '').toString();
        return s == '1' || s.toLowerCase() == 'paid';
      }
      if (decoded is String) {
        final up = decoded.toLowerCase();
        return up.contains('1') || up.contains('paid');
      }
      return false;
    }

    try {
      final js = jsonDecode(st.body);
      final ok = isPaid(js);

      return ok;
    } catch (_) {
      final ok = isPaid(st.body);

      return ok;
    }
  }
}
