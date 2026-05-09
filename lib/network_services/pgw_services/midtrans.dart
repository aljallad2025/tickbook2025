import 'dart:convert';
import 'package:evento_app/app/app_constants.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:evento_app/network_services/core/http_headers.dart';

import 'package:evento_app/app/app_routes.dart';

class MidtransGateway {
  static Future<bool> startCheckout({
    required int amount,
    required String name,
    required String email,
    required String phone,
    String description = 'Order',
    required String currency,
  }) async {
    // 1) Create Snap transaction on your server
    final uri = Uri.parse('$pgwBaseUrl/midtrans-create-snap.php');
    final payload = {'amount': amount, 'currency': currency.toUpperCase()};
    // Logging removed for production.

    http.Response res = await http.post(
      uri,
      headers: {
        ...HttpHeadersHelper.base(),
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );
    if (res.statusCode >= 300) {
      throw Exception('MidTrans creation failed: ${res.body}');
    }

    final snap = jsonDecode(res.body) as Map<String, dynamic>;
    final redirectUrl = snap['redirect_url'] as String?;
    final orderId = snap['order_id'] as String?;

    if (redirectUrl == null || orderId == null) {
      throw Exception('Missing redirect_url or order_id');
    }

    final finished =
        await Get.toNamed(
              AppRoutes.checkoutWebView,
              arguments: {
                'url': redirectUrl,
                'finishScheme': 'myapp://midtrans-finish',
                'title': 'MidTrans',
                'invoiceId': orderId,
                'statusUrlTemplate':
                    '$pgwBaseUrl/midtrans-order-status.php?order_id={invoiceId}',
                // Poll every 6s for up to 20 attempts (~2 minutes)
                'statusPollIntervalSeconds': 6,
                'statusPollMaxAttempts': 20,
                'successUrlContains': [
                  'success',
                  'settlement',
                  'capture',
                  'completed',
                ],
              },
            )
            as bool?;

    if (finished != true) {
      // Final confirmation before declaring failure
      try {
        final st = await http.get(
          Uri.parse('$pgwBaseUrl/midtrans-order-status.php?order_id=$orderId'),
          headers: HttpHeadersHelper.base(),
        );
        if (st.statusCode >= 200 && st.statusCode < 300) {
          try {
            final js = jsonDecode(st.body) as Map<String, dynamic>;
            final txn = (js['transaction_status'] ?? '')
                .toString()
                .toLowerCase();
            if (txn == 'settlement' ||
                txn == 'capture' ||
                txn == 'success' ||
                txn == 'completed') {
              return true;
            }
          } catch (e) {
            // Non-critical JSON parse failure; treat as not completed yet.
            assert(() {
              // ignored midtrans status parse error: $e
              return true;
            }());
          }
        }
      } catch (e) {
        // Final status fetch failed; treat as cancellation.
        assert(() {
          // ignored midtrans status fetch error: $e
          return true;
        }());
      }
      return false;
    }

    return true;
  }
}
