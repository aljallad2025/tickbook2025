import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:evento_app/network_services/core/fcm_token_store_service.dart';

/// Simple singleton-style helper to obtain and cache FCM token.
class FcmTokenService {
  FcmTokenService._();
  static String? _token;
  static bool _initialized = false;
  static String? get token => _token;

  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    try {
      final messaging = FirebaseMessaging.instance;
      NotificationSettings settings = await messaging.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        return;
      }
      final t = await messaging.getToken();
      _token = t;
      
      if (_token != null && _token!.isNotEmpty) {
        // Send token to server on first acquire (once per token)
        unawaited(FcmTokenStoreService.storeIfNew(token: _token!));
      }
      // Optional: listen for token refresh
      messaging.onTokenRefresh.listen((newToken) async {
        _token = newToken;
        if (newToken.isNotEmpty) {
          unawaited(FcmTokenStoreService.storeIfNew(token: newToken));
        }
      });
    } catch (e) {
      assert(() { return true; }());
    }
  }
}
