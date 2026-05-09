import 'dart:async';
import 'package:evento_app/app/evento_app.dart';
import 'package:evento_app/app/app_colors.dart';
import 'package:evento_app/network_services/core/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:evento_app/app/keys.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:evento_app/network_services/core/basic_service.dart';
import 'package:evento_app/network_services/core/fcm_token_service.dart';
import 'package:evento_app/utils/firebase_options.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform, kIsWeb;

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    final isApple =
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.macOS);
    if (!isApple) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    assert(() {
      return true;
    }());
  }
  await NotificationService.ensureInitialized();
  try {
    await FcmTokenService.init();
  } catch (e) {
    assert(() {
      return true;
    }());
  }
  try {} catch (e) {
    assert(() {
      return true;
    }());
  }
  NotificationService.instance.showRemoteMessage(message);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (AppKeys.stripePublishableKey.isNotEmpty) {
    Stripe.publishableKey = AppKeys.stripePublishableKey;
    try {
      await Stripe.instance.applySettings();
    } catch (e) {
      assert(() {
        return true;
      }());
    }
  }
  final isApple =
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS);

  // Initialize Firebase only on non-Apple platforms for now.
  if (!isApple) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
      name: 'ticbook-e7934'
    );
    try {
      await FirebaseAnalytics.instance.logAppOpen();
    } catch (e) {
      assert(() {
        return true;
      }());
    }
    await NotificationService.ensureInitialized();
  }

  if (!isApple) {
    try {
      await FcmTokenService.init();
    } catch (e) {
      assert(() {
        return true;
      }());
    }
  }

  try {
    String? pHex = await BasicService.getCachedPrimaryColorHex();
    Color? parseHex(String? hex) {
      if (hex == null || hex.isEmpty) return null;
      var h = hex.replaceAll('#', '').trim();
      if (h.length == 6) h = 'FF$h';
      try {
        return Color(int.parse(h, radix: 16));
      } catch (_) {
        return null;
      }
    }

    final p = parseHex(pHex);
    if (p != null) {
      AppColors.applyBrand(primary: p);
    }
  } catch (e) {
    assert(() {
      return true;
    }());
  }
  if (!isApple) {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }
  runApp(EventoApp());
}
