import 'dart:convert';
import 'package:evento_app/app/urls.dart';
import 'package:evento_app/network_services/core/http_headers.dart';
import 'package:http/http.dart' as http;

class CouponApplyResult {
  final bool success;
  final String message;
  final double discount;
  final Map<String, List<String>> validationErrors;
  CouponApplyResult({
    required this.success,
    required this.message,
    required this.discount,
    required this.validationErrors,
  });

  factory CouponApplyResult.fromJson(Map<String, dynamic> json) {
    final bool ok = json['success'] == true || json['status'] == true;
    final msg = json['message']?.toString() ?? '';
    final discRaw = json['discount'];
    double disc = 0;
    if (discRaw is num) {
      disc = discRaw.toDouble();
    } else if (discRaw is String) {
      disc = double.tryParse(discRaw) ?? 0;
    }
    Map<String, List<String>> valErrors = {};
    if (json['validation_errors'] is Map) {
      final ve = json['validation_errors'] as Map;
      ve.forEach((k, v) {
        if (v is List) {
          valErrors[k.toString()] = v.map((e) => e.toString()).toList();
        } else if (v is String) {
          valErrors[k.toString()] = [v];
        }
      });
    }
    return CouponApplyResult(
      success: ok,
      message: msg,
      discount: disc,
      validationErrors: valErrors,
    );
  }
}

class CouponService {
  static Future<CouponApplyResult> apply({
    required int eventId,
    required String couponCode,
    required double price,
    double totalEarlyBirdDicount = 0.0,
  }) async {
    final uri = Uri.parse(AppUrls.eventCouponApply);
    final bodyMap = {
      'event_id': eventId.toString(),
      'coupon_code': couponCode.trim(),
      // Backend validation shows these are required
      'price': price,
      'total_early_bird_dicount': totalEarlyBirdDicount,
    };
    final body = json.encode(bodyMap);
    final headers = {
      ...HttpHeadersHelper.auth(),
      'Content-Type': 'application/json',
    };
  // Logging removed.
    final res = await http
        .post(uri, headers: headers, body: body)
        .timeout(const Duration(seconds: 30));
  // Logging removed.
    if (res.statusCode < 200 || res.statusCode >= 300) {
      return CouponApplyResult(
        success: false,
        message: 'Failed (${res.statusCode})',
        discount: 0,
        validationErrors: {},
      );
    }
    Map<String, dynamic> decoded = const {};
    try {
      final raw = json.decode(res.body);
      if (raw is Map<String, dynamic>) decoded = raw;
    } catch (e) {
      // Ignore coupon decode error; return default failure object below.
      assert(() { return true; }());
    }
    return CouponApplyResult.fromJson(decoded);
  }
}
