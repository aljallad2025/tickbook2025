import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:evento_app/app/app_routes.dart';
import 'package:evento_app/app/app_constants.dart';
import 'package:evento_app/network_services/core/http_headers.dart';

class MercadoPagoGateway {
  static Future<bool> startCheckout({
    required int amountMinor,
    required String currency,
    required String name,
    required String email,
    String description = 'Order',
  }) async {
  // Logging removed for production.
    final res = await http.post(
      Uri.parse('$pgwBaseUrl/mercadopago-create-preference.php'),
      headers: {
        ...HttpHeadersHelper.base(),
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'amount_minor': amountMinor,
        'currency': currency.toUpperCase(),
        'name': name,
        'email': email,
        'description': description,
      }),
    );
  // Logging removed.
    if (res.statusCode >= 300) {
      throw Exception('Mercado Pago create failed: ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final url = data['redirect_url'] as String?;
    final extRef = data['external_reference'] as String?;
    if (url == null || extRef == null) {
      throw Exception('Missing redirect_url/external_reference');
    }

  // Logging removed.
    final finished =
        await Get.toNamed(
              AppRoutes.checkoutWebView,
              arguments: {
                'url': url,
                'finishScheme': 'myapp://mp-finish',
                'title': 'Mercado Pago',
              },
            )
            as bool?;

    if (finished != true) return false;

  // Logging removed.
    final st = await http.get(
      Uri.parse(
        '$pgwBaseUrl/mercadopago-status.php?external_reference=$extRef',
      ),
      headers: HttpHeadersHelper.base(),
    );
    if (st.statusCode >= 300) {
      throw Exception('Status failed: ${st.body}');
    }

    bool approved(dynamic decoded) {
      if (decoded is Map<String, dynamic>) {
        final s = (decoded['status'] ?? 'unknown').toString().toLowerCase();
        return s == 'approved' || s == 'success' || s == 'completed';
      }
      if (decoded is String) {
        final up = decoded.toLowerCase();
        return up.contains('approved') || up.contains('success');
      }
      return false;
    }

    try {
      final js = jsonDecode(st.body);
      final ok = approved(js);
  // Logging removed.
      return ok;
    } catch (_) {
      final ok = approved(st.body);
  // Logging removed.
      return ok;
    }
  }
}
