import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:evento_app/app/app_constants.dart';
import 'package:evento_app/app/app_routes.dart';
import 'package:evento_app/network_services/core/http_headers.dart';

class PayPalGateway {
  static Future<bool> startCheckout({
    required int amountMinor,
    required String currency,
    required String name,
    required String email,
    String description = 'Order',
    String phone = '',
  }) async {
    // Split name into first/last
    final parts     = name.trim().split(' ');
    final firstName = parts.first;
    final lastName  = parts.length > 1 ? parts.sublist(1).join(' ') : '-';

    // Amount: EazyPay uses 3 decimal places for BHD
    final amount = (amountMinor / 1000).toStringAsFixed(3);

    // ─── Step 1: Create EazyPay Invoice ──────────────────────────────────────
    final create = await http.post(
      Uri.parse('$pgwBaseUrl/paypal-create-order.php'),
      headers: {
        ...HttpHeadersHelper.base(),
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'amount':    amount,
        'currency':  'BHD',
        'firstName': firstName,
        'lastName':  lastName,
        'email':     email,
        'phone':     phone,
      }),
    );

    if (create.statusCode >= 300) {
      throw Exception('EazyPay create invoice failed: ${create.body}');
    }

    final j           = jsonDecode(create.body) as Map<String, dynamic>;
    final approveUrl  = j['redirect_url']  as String?;
    final orderId     = j['order_id']      as String?;

    if (approveUrl == null || orderId == null) {
      throw Exception('Missing redirect_url or order_id: ${create.body}');
    }

    // ─── Step 2: Open EazyPay hosted checkout in WebView ─────────────────────
    final finished = await Get.toNamed(
      AppRoutes.checkoutWebView,
      arguments: {
        'url':          approveUrl,
        'finishScheme': 'tick-book.com/event-booking/iyzico/notify',
        'title':        'Pay with Card',
      },
    ) as bool?;

    if (finished != true) return false;

    // ─── Step 3: Verify payment ───────────────────────────────────────────────
    final cap = await http.post(
      Uri.parse('$pgwBaseUrl/paypal-capture-order.php'),
      headers: {
        ...HttpHeadersHelper.base(),
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'order_id': orderId}),
    );

    if (cap.statusCode >= 300) {
      throw Exception('EazyPay verify failed: ${cap.body}');
    }

    final c      = jsonDecode(cap.body) as Map<String, dynamic>;
    final status = (c['status'] ?? 'UNKNOWN').toString().toUpperCase();
    return status == 'COMPLETED';
  }
}
