import 'dart:async';
import 'package:evento_app/network_services/core/fcm_token_service.dart';

/// Handles lightweight preflight checks before starting checkout.
class CheckoutPreflightModel {
  const CheckoutPreflightModel();

  /// Ensures FCM token is available before proceeding.
  /// Returns (ok, errorMessage)
  Future<(bool, String?)> ensureFcmReady() async {
    if (FcmTokenService.token == null || FcmTokenService.token!.isEmpty) {
      try {
        await FcmTokenService.init();
      } catch (e) {
        assert(() { return true; }());
      }
    }
    if ((FcmTokenService.token ?? '').isEmpty) {
      return (
        false,
        'Notification token unavailable. Please wait and try again.',
      );
    }
    return (true, null);
  }
}
