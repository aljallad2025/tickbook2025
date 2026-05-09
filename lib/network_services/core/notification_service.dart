import 'dart:async';
import 'dart:convert';
import 'package:evento_app/network_services/core/navigation_service.dart';
import 'package:evento_app/app/app_routes.dart';
import 'package:evento_app/features/home/ui/widgets/booking_guest_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:evento_app/network_services/core/fcm_token_store_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  static final FlutterLocalNotificationsPlugin _fln =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _defaultChannel =
      AndroidNotificationChannel(
        'default_channel',
        'General Notifications',
        description: 'General app notifications',
        importance: Importance.high,
      );

  static bool _initialized = false;
  static final ValueNotifier<bool> notificationsEnabled = ValueNotifier<bool>(
    true,
  );
  static const String _prefsKeyEnabled = 'notifications_enabled';

  final ValueNotifier<String?> fcmToken = ValueNotifier<String?>(null);

  static Future<void> ensureInitialized() async {
    if (_initialized) return;
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );
    await _fln.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    final android = _fln
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.createNotificationChannel(_defaultChannel);

    final fm = FirebaseMessaging.instance;

    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getBool(_prefsKeyEnabled);
      if (saved != null) notificationsEnabled.value = saved;
    } catch (_) {}

    try {
      await fm.setAutoInitEnabled(true);
    } catch (_) {}

    await requestPermissions();

    try {
      final token = await fm.getToken();
      instance.fcmToken.value = token;
      if (token != null) {
        // Logging removed.
        // Send token to server on first acquire
        try {
          await FcmTokenStoreService.storeIfNew(token: token);
        } catch (_) {}
      } else {
        // Logging removed.
      }
    } catch (e) {
      // Logging removed.
    }

    fm.onTokenRefresh.listen((newToken) async {
      instance.fcmToken.value = newToken;
      // Logging removed.
      // Send refreshed token to server
      try {
        await FcmTokenStoreService.storeIfNew(token: newToken);
      } catch (_) {}
    });

    await fm.setForegroundNotificationPresentationOptions(
      alert: notificationsEnabled.value,
      badge: notificationsEnabled.value,
      sound: notificationsEnabled.value,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (notificationsEnabled.value) {
        instance.showRemoteMessage(message);
      }
    });

    final initialMsg = await fm.getInitialMessage();
    if (initialMsg != null) {
      if (notificationsEnabled.value) {
        _handleNavigation(initialMsg);
      }
    }

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (notificationsEnabled.value) _handleNavigation(message);
    });
    _initialized = true;
  }

  static Future<void> setNotificationsEnabled(bool enabled) async {
    notificationsEnabled.value = enabled;

    final fm = FirebaseMessaging.instance;
    await fm.setForegroundNotificationPresentationOptions(
      alert: enabled,
      badge: enabled,
      sound: enabled,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKeyEnabled, enabled);
    if (!enabled) {
      await _fln.cancelAll();
    }
  }

  static Future<bool> getNotificationsEnabledFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_prefsKeyEnabled) ?? true;
    } catch (_) {
      return true;
    }
  }

  static Future<void> requestPermissions() async {
    final fm = FirebaseMessaging.instance;
    await fm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  void showRemoteMessage(RemoteMessage message) async {
    if (!notificationsEnabled.value) return;
    final notification = message.notification;
    final android = notification?.android;
    final data = message.data;
    final title = notification?.title ?? data['title'] ?? 'Notification';
    final body = notification?.body ?? data['body'] ?? '';

    final payload = jsonEncode({
      'route': data['route'],
      'args': data['args'],
      'raw': data,
    });

    try {
      // Logging removed; previously constructed logMap now omitted.
    } catch (e) {
      assert(() {
        return true;
      }());
    }

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _defaultChannel.id,
        _defaultChannel.name,
        channelDescription: _defaultChannel.description,
        importance: Importance.high,
        priority: Priority.high,
        icon: android?.smallIcon ?? '@mipmap/ic_launcher',
        visibility: NotificationVisibility.public,
      ),
      iOS: const DarwinNotificationDetails(),
    );

    await _fln.show(message.hashCode, title, body, details, payload: payload);
  }

  static void _onNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null) return;

    final map = jsonDecode(payload) as Map<String, dynamic>;
    final raw = (map['raw'] as Map?)?.cast<String, dynamic>();
    if (raw != null) {
      handleNotificationTapData(raw);
    } else {
      handleNotificationTapData(map);
    }
  }

  static void _handleNavigation(RemoteMessage message) {
    final data = message.data;
    handleNotificationTapData(data);
  }

  static Future<void> handleNotificationTapData(
    Map<String, dynamic> data,
  ) async {
    final route = data['route'] as String?;
    final args = data['args'];
    final url = (data['button_url'] ?? data['url'] ?? data['link']) as String?;

    // Check if this is a booking notification with booking_id
    // Handle both direct FCM data and nested data structure
    Map<String, dynamic> fcmData = data;
    if (data.containsKey('data') && data['data'] is Map) {
      fcmData = Map<String, dynamic>.from(data['data']);
    }

    // Support both snake_case and camelCase keys from various backends
    final bookingId = (fcmData['booking_id'] ?? fcmData['bookingId'])
        ?.toString();
    final eventTitle =
        fcmData['event_title']?.toString() ??
        fcmData['eventTitle']?.toString() ??
        data['event_title']?.toString() ??
        data['eventTitle']?.toString() ??
        data['title']?.toString() ??
        '';

    try {
      // Logging removed.
    } catch (_) {}

    if (bookingId != null && bookingId.isNotEmpty) {
      final bookingIdInt = int.tryParse(bookingId);
      if (bookingIdInt != null && bookingIdInt > 0) {
        // If unauthenticated user (guest), show details popup instead of navigating.
        try {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');
          final loggedIn = (token ?? '').isNotEmpty;
          if (!loggedIn) {
            final ctx = NavigationService.navigatorKey.currentContext;
            if (ctx != null) {
              final message =
                  (fcmData['message'] ?? data['message'] ?? data['body'])
                      ?.toString();
              final eventDate =
                  (fcmData['event_date'] ??
                          fcmData['eventDate'] ??
                          data['event_date'] ??
                          data['eventDate'])
                      ?.toString();
              final paymentStatus =
                  (fcmData['paymentStatus'] ??
                          fcmData['payment_status'] ??
                          data['paymentStatus'] ??
                          data['payment_status'])
                      ?.toString();
              if (!ctx.mounted) return;
              await showBookingGuestDialog(
                context: ctx,
                title: eventTitle,
                bookingId: bookingId,
                message: message,
                eventDate: eventDate,
                paymentStatus: paymentStatus,
                onLogin: () {
                  NavigationService.navigatorKey.currentState?.pushNamed(
                    AppRoutes.login,
                    arguments: {'popOnSuccess': true},
                  );
                },
              );
              return;
            }
          }
        } catch (_) {}

        try {
          // Logging removed.
        } catch (_) {}
        // Navigate to booking details screen
        NavigationService.navigatorKey.currentState?.pushNamed(
          AppRoutes.bookingDetails,
          arguments: {
            'bookingId': bookingIdInt,
            'booking_id': bookingId,
            'eventTitle': eventTitle,
            'event_title': eventTitle,
          },
        );
        return;
      }
    }

    // Fallback to URL navigation
    if (url != null && url.trim().isNotEmpty) {
      await _launchUrl(url);
      return;
    }

    // Fallback to route navigation
    if (route != null && route.isNotEmpty) {
      NavigationService.navigatorKey.currentState?.pushNamed(
        route,
        arguments: args,
      );
    }
  }

  static Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    final can = await canLaunchUrl(uri);
    if (!can) {
      return;
    }
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok) {}
  }
}
