import 'dart:convert';

import 'package:evento_app/app/urls.dart';
import 'package:evento_app/network_services/core/auth_services.dart';
import 'package:evento_app/network_services/core/http_headers.dart';
import 'package:evento_app/network_services/core/http_errors.dart';
import 'package:http/http.dart' as http;

class BookingCreateResult {
  final bool status;
  final String message;
  final Map<String, dynamic>? bookingInfo;

  BookingCreateResult({
    required this.status,
    required this.message,
    required this.bookingInfo,
  });

  String? get bookingIdStr => bookingInfo?['booking_id']?.toString();
  int? get id => int.tryParse(bookingInfo?['id']?.toString() ?? '');
}

class BookingCreateService {
  static Future<BookingCreateResult> create({
    required Map<String, dynamic> payload,
    String? token,
  }) async {
    if (token != null && token.isNotEmpty) {
      AuthServices.token = token;
    }
    return submit(body: payload, authRequired: true);
  }

  static Future<BookingCreateResult> submit({
    required Map<String, dynamic> body,
    bool authRequired = true,
  }) async {
    final uri = Uri.parse(AppUrls.eventBooking);

    try {
      json.encode(body);
    } catch (e) {
      assert(() {
        return true;
      }());
    }
    final headers = authRequired
        ? HttpHeadersHelper.auth()
        : HttpHeadersHelper.base();
    final logHeaders = Map<String, String>.from(headers);
    if (logHeaders.containsKey('Authorization')) {
      logHeaders['Authorization'] = 'Bearer ***REDACTED***';
    }

    final res = await http
        .post(
          uri,
          headers: {...headers, 'Content-Type': 'application/json'},
          body: json.encode(body),
        )
        .timeout(const Duration(seconds: 60));


    if (res.statusCode == 401) {
      throw const AuthRequiredException();
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Booking request failed: ${res.statusCode} ${res.body}');
    }
    Map<String, dynamic> decoded = const {};
    try {
      final raw = json.decode(res.body);
      if (raw is Map<String, dynamic>) decoded = raw;
    } catch (e) {
      // Ignore booking JSON decode error; will fall back to defaults.
      assert(() {
        return true;
      }());
    }
    bool status =
        (decoded['status'] == true || decoded['status'] == 1) ||
        (decoded['success'] == true || decoded['success'] == 1);
    String message = decoded['message']?.toString() ?? '';
    void collectErrors(dynamic rawErrors) {
      if (rawErrors is! Map) return;
      final errs = rawErrors.cast<String, dynamic>();
      final errMsgs = <String>[];
      errs.forEach((k, v) {
        if (v is List && v.isNotEmpty) {
          errMsgs.add(v.first.toString());
        } else if (v is String && v.isNotEmpty) {
          errMsgs.add(v);
        }
      });
      if (errMsgs.isNotEmpty) {
        message = errMsgs.join("\n");

      }
    }

    try {
      if (!status) {
        if (decoded['errors'] is Map) collectErrors(decoded['errors']);
        if (decoded['validation_errors'] is Map) {
          collectErrors(decoded['validation_errors']);
        }
      }
    } catch (e) {
      // Ignore error aggregation failure.
      assert(() {
        return true;
      }());
    }
    Map<String, dynamic>? info = decoded['booking_info'] is Map<String, dynamic>
        ? (decoded['booking_info'] as Map<String, dynamic>)
        : null;

    // Some backends may wrap a nested Response in "booking_info" with an
    // `original` payload that contains the real status/message when failures
    // occur in downstream operations. Surface that error for clarity.
    try {
      if (info != null && info['original'] is Map) {
        final orig = Map<String, dynamic>.from(info['original'] as Map);
        final bool? origStatus = () {
          final v = orig['status'];
          if (v is bool) return v;
          if (v is num) return v == 1;
          if (v is String) return v.toLowerCase() == 'true' || v == '1';
          return null;
        }();
        final String origMsg = orig['message']?.toString() ?? '';
        if (origStatus == false) {
          status = false;
          if (origMsg.isNotEmpty) message = origMsg;
          info = null;
        }
      }
    } catch (e) {
      // Ignore nested original unwrap failure.
      assert(() {
        return true;
      }());
    }
    return BookingCreateResult(
      status: status,
      message: message,
      bookingInfo: info,
    );
  }
}
