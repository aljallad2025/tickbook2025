import 'dart:convert';
import 'package:evento_app/app/urls.dart';
import 'package:http/http.dart' as http;
import 'package:evento_app/network_services/core/http_headers.dart';

class AuthServices {
  static String? token;

  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final uri = Uri.parse(AppUrls.login);
    final headers = HttpHeadersHelper.base();

    final response = await http.post(
      uri,
      headers: headers,
      body: {'username': username, 'password': password},
    );

    dynamic decoded;
    try {
      decoded = json.decode(response.body);
    } catch (e) {
      decoded = {'status': 'error', 'message': 'Invalid server response'};
    }
    if (response.statusCode != 200) {
      return {
        'status': 'error',
        'message': 'HTTP ${response.statusCode}',
        'raw': decoded,
      };
    }
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    return {'status': 'error', 'message': 'Unexpected login response'};
  }

  static Future<Map<String, dynamic>> signup({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final uri = Uri.parse(AppUrls.signup);
    http.Response response;
    try {
      final headers = {
        ...HttpHeadersHelper.base(),
        'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
        'User-Agent': 'evento-app/1.0',
      };
      response = await http.post(
        uri,
        headers: headers,
        body: {
          'fname': firstName,
          'lname': lastName,
          'username': username,
          'email': email,
          'password': password,
          'password_confirmation': confirmPassword,
        },
      );
    } catch (e) {
      return {'status': 'error', 'message': 'Network error: $e'};
    }

    final raw = response.body;

    dynamic decoded;
    try {
      decoded = json.decode(raw);
    } catch (e) {
      final start = raw.indexOf('{');
      final end = raw.lastIndexOf('}');
      if (start >= 0 && end > start) {
        final inner = raw.substring(start, end + 1);
        try {
          decoded = json.decode(inner);
        } catch (innerE) {
          assert(() { return true; }());
        }
      }
    }

    if (decoded is! Map<String, dynamic>) {
      return {
        'status': 'error',
        'message': 'Invalid server response',
        'raw': raw.length > 500 ? raw.substring(0, 500) : raw,
      };
    }
    final map = Map<String, dynamic>.from(decoded);

    if (response.statusCode != 200) {
      return {
        'status': 'error',
        'message': map['message']?.toString() ?? 'HTTP ${response.statusCode}',
        'raw': map,
      };
    }
    return map;
  }

  static Future<Map<String, dynamic>> sendPasswordResetEmail({
    required String email,
  }) async {
    final uri = Uri.parse(AppUrls.forgetPassword);
    try {
      final headers = {
        ...HttpHeadersHelper.base(),
        'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
      };
      final response = await http.post(
        uri,
        headers: headers,
        body: {'email': email},
      );

      final raw = response.body;
      dynamic decoded;
      try {
        decoded = json.decode(raw);
      } catch (_) {
        decoded = {
          'status': 'error',
          'message': 'Invalid server response',
          'raw': raw,
        };
      }
      if (response.statusCode != 200) {
        return {
          'status': 'error',
          'message': decoded['message'] ?? 'HTTP ${response.statusCode}',
          'raw': decoded,
        };
      }
      if (decoded is Map<String, dynamic>) return decoded;
      return {'status': 'error', 'message': 'Unexpected response', 'raw': raw};
    } catch (e) {
      return {'status': 'error', 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> resetPasswordWithCode({
    required String email,
    required String code,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    final uri = Uri.parse(AppUrls.resetPasswordUpdate);
    try {
      final headers = {
        ...HttpHeadersHelper.base(),
        'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
      };
      final response = await http.post(
        uri,
        headers: headers,
        body: {
          'email': email,
          'code': code,
          'new_password': newPassword,
          'new_password_confirmation': newPasswordConfirmation,
        },
      );

      final raw = response.body;
      dynamic decoded;
      try {
        decoded = json.decode(raw);
      } catch (_) {
        decoded = {
          'status': 'error',
          'message': 'Invalid server response',
          'raw': raw,
        };
      }
      if (response.statusCode != 200) {
        return {
          'status': 'error',
          'message': decoded['message'] ?? 'HTTP ${response.statusCode}',
          'raw': decoded,
        };
      }
      if (decoded is Map<String, dynamic>) return decoded;
      return {'status': 'error', 'message': 'Unexpected response', 'raw': raw};
    } catch (e) {
      return {'status': 'error', 'message': 'Network error: $e'};
    }
  }
}
