import 'dart:convert';
import 'dart:developer' as developer;
import 'package:evento_app/app/urls.dart';
import 'package:evento_app/features/bookings/data/models/booking_models.dart';
import 'package:http/http.dart' as http;
import 'package:evento_app/utils/net_utils.dart';
import 'package:evento_app/features/account/data/models/dashboard_models.dart';
import 'package:evento_app/network_services/core/http_errors.dart';

class DashboardService {
  static const String _tag = 'DashboardService';

  static Future<DashboardResponseModel> fetch(String token) async {
    final startTime = DateTime.now();
    developer.log(
      'Starting dashboard fetch',
      name: _tag,
      time: startTime,
    );

    http.Response response;
    try {
      final uri = Uri.parse(AppUrls.dashboard);
      final headers = {
        'Accept': 'application/json',
        if (token.isNotEmpty) 'Authorization': 'Bearer ${_maskToken(token)}',
      };

      developer.log(
        'Making GET request to: $uri',
        name: _tag,
        time: DateTime.now(),
      );
      developer.log(
        'Request headers: $headers',
        name: _tag,
        time: DateTime.now(),
      );

      response = await NetUtils.getWithRetry(
        uri,
        headers: {
          'Accept': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      final duration = DateTime.now().difference(startTime);
      developer.log(
        'Response received in ${duration.inMilliseconds}ms - Status: ${response.statusCode}',
        name: _tag,
        time: DateTime.now(),
      );
      developer.log(
        'Response body length: ${response.body.length} chars',
        name: _tag,
        time: DateTime.now(),
      );
    } catch (e, stackTrace) {
      developer.log(
        'Network error occurred',
        name: _tag,
        error: e,
        stackTrace: stackTrace,
        level: 1000, // ERROR level
      );
      throw Exception('Network error: $e');
    }

    // Handle auth errors
    if (response.statusCode == 401 ||
        response.statusCode == 419 ||
        response.statusCode == 403) {
      developer.log(
        'Authentication required - Status: ${response.statusCode}',
        name: _tag,
        level: 900, // WARNING level
      );
      throw const AuthRequiredException('Session expired. Please login again.');
    }

    // Handle non-200 responses
    if (response.statusCode != 200) {
      developer.log(
        'Server error - Status: ${response.statusCode}, Body: ${response.body}',
        name: _tag,
        level: 1000, // ERROR level
      );
      throw Exception(
        'Server responded ${response.statusCode}: ${response.body}',
      );
    }

    // Parse JSON
    dynamic decoded;
    try {
      decoded = json.decode(response.body);
      developer.log(
        'JSON decoded successfully - Type: ${decoded.runtimeType}',
        name: _tag,
        time: DateTime.now(),
      );
    } catch (e, stackTrace) {
      developer.log(
        'JSON parsing failed',
        name: _tag,
        error: e,
        stackTrace: stackTrace,
        level: 1000, // ERROR level
      );
      throw Exception('Invalid JSON: $e');
    }

    // Extract data container
    Map<String, dynamic> container = const {};
    if (decoded is Map<String, dynamic>) {
      final d = decoded['data'];
      if (d is Map<String, dynamic>) {
        container = d;
        developer.log(
          'Using nested data object',
          name: _tag,
          time: DateTime.now(),
        );
      } else {
        container = decoded;
        developer.log(
          'Using root object as container',
          name: _tag,
          time: DateTime.now(),
        );
      }
    }

    // Extract page title
    final String pageTitle =
        container['page_title']?.toString() ??
            container['pageTitle']?.toString() ??
            'Dashboard';
    developer.log(
      'Page title: $pageTitle',
      name: _tag,
      time: DateTime.now(),
    );

    // Extract auth user
    Map<String, dynamic>? authUserJson;
    if (container['auth_user'] is Map<String, dynamic>) {
      authUserJson = container['auth_user'] as Map<String, dynamic>;
      developer.log(
        'Found auth_user (snake_case)',
        name: _tag,
        time: DateTime.now(),
      );
    } else if (container['authUser'] is Map<String, dynamic>) {
      authUserJson = container['authUser'] as Map<String, dynamic>;
      developer.log(
        'Found authUser (camelCase)',
        name: _tag,
        time: DateTime.now(),
      );
    } else {
      developer.log(
        'No auth_user found in response',
        name: _tag,
        level: 900, // WARNING level
      );
    }

    // Extract bookings
    List<dynamic> bookingsJson = const [];
    final rawBookings = container['bookings'];
    if (rawBookings is List) {
      bookingsJson = rawBookings;
      developer.log(
        'Found ${bookingsJson.length} bookings',
        name: _tag,
        time: DateTime.now(),
      );
    } else {
      developer.log(
        'No bookings found or invalid format',
        name: _tag,
        level: 900, // WARNING level
      );
    }

    // Parse bookings
    final bookings = bookingsJson
        .whereType<Map<String, dynamic>>()
        .map((json) {
      try {
        return BookingItemModel.fromJson(json);
      } catch (e) {
        developer.log(
          'Failed to parse booking item',
          name: _tag,
          error: e,
          level: 900, // WARNING level
        );
        return null;
      }
    })
        .whereType<BookingItemModel>()
        .toList();

    developer.log(
      'Successfully parsed ${bookings.length} bookings',
      name: _tag,
      time: DateTime.now(),
    );

    final totalDuration = DateTime.now().difference(startTime);
    developer.log(
      'Dashboard fetch completed in ${totalDuration.inMilliseconds}ms',
      name: _tag,
      time: DateTime.now(),
    );

    return DashboardResponseModel(
      pageTitle: pageTitle,
      authUser: authUserJson == null
          ? null
          : AuthUserModel.fromJson(authUserJson),
      bookings: bookings,
    );
  }

  // Helper to mask sensitive token for logging
  static String _maskToken(String token) {
    if (token.isEmpty) return '[empty]';
    if (token.length <= 8) return '***';
    return '${token.substring(0, 4)}...${token.substring(token.length - 4)}';
  }
}
