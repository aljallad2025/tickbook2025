import 'dart:convert';
import 'package:evento_app/app/app_constants.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:evento_app/app/app_routes.dart';

class PayStackGateway {
  static Future<bool> startCheckout({
    required int amountMinor,
    required String currency,
    required String name,
    required String email,
    String description = 'Order',
  }) async {
    final res = await http.post(
      Uri.parse('$pgwBaseUrl/paystack-create-transaction.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'amount_minor': amountMinor,
        'currency': currency.toUpperCase(),
        'email': email,
        'name': name,
        'description': description,
      }),
    );

    if (res.statusCode >= 300) {
      throw Exception('PayStack create failed: ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final url = data['authorization_url'] as String?;
    final ref = data['reference'] as String?;
    if (url == null || ref == null) {
      throw Exception('Missing authorization_url/reference');
    }

    final finished =
        await Get.toNamed(
              AppRoutes.checkoutWebView,
              arguments: {
                'url': url,
                'finishScheme': 'myapp://paystack-finish',
                'title': 'PayStack',
              },
            )
            as bool?;

    if (finished != true) return false; // user cancelled/closed

    // 3) Verify status by reference on your server
    final st = await http.get(
      Uri.parse('$pgwBaseUrl/paystack-status.php?reference=$ref'),
    );
    if (st.statusCode >= 300) {
      throw Exception('Status failed: ${st.body}');
    }

    final js = jsonDecode(st.body) as Map<String, dynamic>;
    final status = (js['status'] ?? 'unknown').toString().toLowerCase();

    // Paystack typical success: "success"
    return status == 'success' || status == 'successful';
  }
}
