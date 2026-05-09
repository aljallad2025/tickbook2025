import 'dart:convert';
import 'package:evento_app/app/urls.dart';
import 'package:evento_app/features/bookings/data/models/booking_models.dart';
import 'package:evento_app/network_services/core/http_errors.dart';
import 'package:http/http.dart' as http;
import 'package:evento_app/utils/net_utils.dart';

class BookingsService {
  static Future<BookingsResponseModel> fetch(String token) async {
    http.Response response;
    try {
      response = await NetUtils.getWithRetry(
        Uri.parse(AppUrls.bookings),
        headers: {
          'Accept': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );
    } catch (e) {
      throw Exception('Network error: $e');
    }
    if (response.statusCode == 401 ||
        response.statusCode == 419 ||
        response.statusCode == 403) {
      throw const AuthRequiredException('Session expired. Please login again.');
    }
    if (response.statusCode != 200) {
      throw Exception(
        'Server responded ${response.statusCode}: ${response.body}',
      );
    }
    try {
      // Placeholder for future logging instrumentation.
    } catch (e) {
      assert(() { return true; }());
    }

    dynamic decoded;
    try {
      final body = response.body.trim();
      decoded = body.isEmpty ? {'bookings': []} : json.decode(body);
    } catch (e) {
      throw Exception('Invalid JSON: $e');
    }
    return BookingsResponseModel.fromAny(decoded);
  }
}
