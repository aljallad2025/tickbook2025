import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:evento_app/app/app_routes.dart';
import 'package:evento_app/app/app_constants.dart';

class FlutterwaveGateway {
  static Future<bool> startCheckout({
    required int amountMinor,
    required String currency,
    required String name,
    required String email,
    String description = 'Order',
  }) async {
    // 1) Create hosted payment on your server
    final createRes = await http.post(
      Uri.parse('$pgwBaseUrl/flutterwave-create-payment.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'amount_minor': amountMinor,
        'currency': currency.toUpperCase(),
        'name': name,
        'email': email,
        'description': description,
      }),
    );

    if (createRes.statusCode >= 300) {
      throw Exception('Flutterwave create failed: ${createRes.body}');
    }
    final data = jsonDecode(createRes.body) as Map<String, dynamic>;
    final checkoutUrl = data['redirect_url'] as String?;
    final txRef = data['tx_ref'] as String?;
    if (checkoutUrl == null || txRef == null) {
      throw Exception('Missing redirect_url/tx_ref');
    }

    final finished =
        await Get.toNamed(
              AppRoutes.checkoutWebView,
              arguments: {
                'url': checkoutUrl,
                'finishScheme': 'myapp://flutterwave-finish',
                'title': 'Flutterwave',
              },
            )
            as bool?;

    if (finished != true) return false;

    // 3) Query payment status by tx_ref
    final st = await http.get(
      Uri.parse('$pgwBaseUrl/flutterwave-status.php?tx_ref=$txRef'),
    );
    if (st.statusCode >= 300) {
      throw Exception('Status failed: ${st.body}');
    }
    final js = jsonDecode(st.body) as Map<String, dynamic>;
    final status = (js['status'] ?? 'unknown').toString().toLowerCase();

    return status == 'successful';
  }
}
