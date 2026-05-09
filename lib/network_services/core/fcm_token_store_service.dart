import 'dart:convert';
import 'package:evento_app/app/urls.dart';
import 'package:evento_app/network_services/core/http_headers.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FcmTokenStoreService {
  static const _prefsLastSentKey = 'last_fcm_token_sent';

  static Future<String?> getLastSentToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_prefsLastSentKey);
    } catch (_) {
      return null;
    }
  }

  static Future<void> setLastSentToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsLastSentKey, token);
    } catch (e) {
      // Ignore prefs write failure; token resend will retry later.
      assert(() { return true; }());
    }
  }

  /// Sends the FCM token to server. Returns true on success.
  static Future<bool> store({required String token}) async {
    if (token.trim().isEmpty) return false;
    final uri = Uri.parse(AppUrls.saveFcmToken)
        .replace(queryParameters: {'token': token});
    // Logging removed.
    try {
      var res = await http
          .post(uri, headers: HttpHeadersHelper.base())
          .timeout(const Duration(seconds: 20));
      if (res.statusCode >= 400) {
        // Some servers expect GET
        res = await http
            .get(uri, headers: HttpHeadersHelper.base())
            .timeout(const Duration(seconds: 20));
      }
      if (res.statusCode >= 200 && res.statusCode < 300) {
        try {
          final body = res.body.trim();
          if (body.isNotEmpty) {
            final decoded = json.decode(body);
            if (decoded is Map<String, dynamic>) {
              final ok = decoded['success'] == true ||
                  decoded['status'] == 'success' ||
                  decoded['status'] == true;
              if (ok) {
                await setLastSentToken(token);
                return true;
              }
            }
          }
        } catch (e) {
          // Even if response isn't JSON, consider 2xx success
          await setLastSentToken(token);
          return true;
        }
        // Fallback treat 2xx as success
        await setLastSentToken(token);
        return true;
      }
    } catch (e) {
      // Network/storage error sending FCM token; will retry on next refresh.
      assert(() { return true; }());
    }
    return false;
  }

  /// Sends only if different from the last sent token.
  static Future<bool> storeIfNew({required String token}) async {
    final last = await getLastSentToken();
    if (last == token) {
      return true;
    }
    return await store(token: token);
  }
}

