import 'dart:convert';
import 'package:evento_app/app/urls.dart';
import 'package:evento_app/network_services/core/http_headers.dart';
import 'package:http/http.dart' as http;

class CheckoutVerifyResult {
  final bool success;
  final String message;
  final Map<String, dynamic> data;
  CheckoutVerifyResult({
    required this.success,
    required this.message,
    required this.data,
  });

  List<Map<String, dynamic>> get selTickets => (data['selTickets'] is List)
      ? (data['selTickets'] as List)
            .whereType<Map<String, dynamic>>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList()
      : const <Map<String, dynamic>>[];
  List<Map<String, dynamic>> get seatData => (data['seat_data'] is List)
      ? (data['seat_data'] as List)
            .whereType<Map<String, dynamic>>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList()
      : const <Map<String, dynamic>>[];
  int get quantityScalar {
    final q = data['quantity'];
    if (q is int) return q;
    if (q is String) return int.tryParse(q) ?? 0;
    return 0;
  }

  double get total =>
      (data['total'] is num) ? (data['total'] as num).toDouble() : 0.0;
  double get subTotal => (data['sub_total'] is num)
      ? (data['sub_total'] as num).toDouble()
      : total;
}

class CheckoutVerifyService {
  static Future<CheckoutVerifyResult> verify(Map<String, dynamic> body) async {
    final uri = Uri.parse(AppUrls.eventCheckoutVerify);
  // Logging removed.
    final headers = HttpHeadersHelper.auth();
    final reqBody = json.encode(body);
    // Logging removed.
    final res = await http
        .post(
          uri,
          headers: {...headers, 'Content-Type': 'application/json'},
          body: reqBody,
        )
        .timeout(const Duration(seconds: 45));
  // Logging removed.
    if (res.statusCode < 200 || res.statusCode >= 300) {
      return CheckoutVerifyResult(
        success: false,
        message: 'Verify failed: ${res.statusCode}',
        data: const {},
      );
    }
    Map<String, dynamic> decoded = const {};
    try {
      final raw = json.decode(res.body);
      if (raw is Map<String, dynamic>) decoded = raw;
    } catch (e) {
      // Ignore JSON decode error; treat as failure via decoded map {}.
      assert(() { return true; }());
    }
    final bool ok = decoded['success'] == true || decoded['status'] == true;
    final msg = decoded['message']?.toString() ?? '';
    return CheckoutVerifyResult(success: ok, message: msg, data: decoded);
  }
}
