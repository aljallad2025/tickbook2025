import 'package:evento_app/app/app_theme_data.dart';
import 'package:evento_app/features/auth/providers/auth_provider.dart';
import 'package:evento_app/features/events/providers/event_details_provider.dart';
import 'package:evento_app/features/events/providers/events_provider.dart';
import 'package:evento_app/features/bookings/providers/bookings_provider.dart';
import 'package:evento_app/features/bookings/providers/booking_details_provider.dart';
import 'package:evento_app/features/home/providers/home_provider.dart';
import 'package:evento_app/features/home/providers/notification_provider.dart';
import 'package:evento_app/features/home/providers/nav_provider.dart';
import 'package:evento_app/features/account/providers/account_provider.dart';
import 'package:evento_app/features/account/providers/dashboard_provider.dart';
import 'package:evento_app/features/organizers/providers/organizers_provider.dart';
import 'package:evento_app/features/organizers/providers/organizer_details_provider.dart';
import 'package:evento_app/features/support/providers/support_ticket_details_provider.dart';
import 'package:evento_app/features/support/providers/support_tickets_provider.dart';
import 'package:evento_app/features/wishlist/providers/wishlist_provider.dart';
import 'package:evento_app/features/home/data/models/fcm_notification_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:evento_app/network_services/core/navigation_service.dart';
import 'package:provider/provider.dart';
import 'package:evento_app/app/app_routes.dart';
import 'package:evento_app/features/home/providers/locale_provider.dart';
import 'package:evento_app/app/localization/app_translations.dart';
import 'package:evento_app/app/localization/language_reload_observer.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform, kIsWeb;

class EventoApp extends StatelessWidget {
  const EventoApp({super.key});
  static bool _fcmBridgeInitialized = false;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()..init()),
        ChangeNotifierProvider(create: (_) => EventsProvider()),
        ChangeNotifierProvider(create: (_) => BookingsProvider()),
        ChangeNotifierProvider(create: (_) => BookingDetailsProvider()),
        ChangeNotifierProvider(create: (_) => NavProvider()),
        ChangeNotifierProvider(create: (_) => AccountProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => OrganizersProvider()),
        ChangeNotifierProvider(create: (_) => OrganizerDetailsProvider()),
        ChangeNotifierProvider(create: (_) => SupportTicketDetailsProvider()),
        ChangeNotifierProvider(create: (_) => SupportTicketsProvider()),
        ChangeNotifierProvider(create: (_) => EventDetailsProvider()),

        ChangeNotifierProvider(
          create: (ctx) => WishlistProvider(auth: ctx.read<AuthProvider>()),
        ),
        ChangeNotifierProvider(create: (_) => LocaleProvider()..init()),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, lp, _) => LanguageReloadObserver(
          child: Builder(
            builder: (ctx) {
              if (!_fcmBridgeInitialized) {
                _fcmBridgeInitialized = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!ctx.mounted) return;

                  final isApple =
                      !kIsWeb &&
                      (defaultTargetPlatform == TargetPlatform.iOS ||
                          defaultTargetPlatform == TargetPlatform.macOS);
                  if (isApple) {
                    return;
                  }

                  // Helper function to create notification data from FCM
                  Map<String, dynamic> createNotificationData(RemoteMessage m) {
                    try {
                      // Parse using FCM notification model for proper structure
                      final fcmNotification = FcmNotificationModel.fromJson({
                        'id': m.messageId,
                        'from': m.from,
                        'title': m.notification?.title ?? m.data['title'],
                        'body': m.notification?.body ?? m.data['body'],
                        'data': m.data,
                      });

                      // Convert back to map for notification provider with normalized essentials
                      final notificationData = <String, dynamic>{
                        'id': fcmNotification.id,
                        'title': fcmNotification.title,
                        'body': fcmNotification.body,
                        'type': fcmNotification.data.type ?? 'General',
                        'from': fcmNotification.from,

                        // Booking/event fields (normalized)
                        if (fcmNotification.data.bookingId != null)
                          'booking_id': fcmNotification.data.bookingId,
                        if (fcmNotification.data.eventId != null)
                          'event_id': fcmNotification.data.eventId,
                        if (fcmNotification.data.eventTitle != null)
                          'event_title': fcmNotification.data.eventTitle,

                        // Navigation fields
                        if (fcmNotification.data.buttonUrl != null)
                          'button_url': fcmNotification.data.buttonUrl,
                        if (fcmNotification.data.buttonName != null)
                          'button_name': fcmNotification.data.buttonName,
                        if (fcmNotification.data.route != null)
                          'route': fcmNotification.data.route,
                        if (fcmNotification.data.args != null)
                          'args': fcmNotification.data.args,
                        if (fcmNotification.data.message != null)
                          'message': fcmNotification.data.message,

                        // Also include raw FCM data for completeness
                        ...m.data,
                      };

                      return notificationData;
                    } catch (e) {
                      // Fallback to simple data structure
                      return {
                        'id': m.messageId,
                        'title': m.notification?.title ?? m.data['title'],
                        'body': m.notification?.body ?? m.data['body'],
                        'type': m.data['type'] ?? 'General',
                        ...m.data,
                      };
                    }
                  }

                  FirebaseMessaging.onMessage.listen((m) {
                    if (!ctx.mounted) return;
                    final data = createNotificationData(m);
                    ctx.read<NotificationProvider>().addFromRemoteData(data);
                  });
                  FirebaseMessaging.onMessageOpenedApp.listen((m) {
                    if (!ctx.mounted) return;
                    final data = createNotificationData(m);
                    ctx.read<NotificationProvider>().addFromRemoteData(data);
                  });
                  FirebaseMessaging.instance.getInitialMessage().then((m) {
                    if (m == null) return;
                    if (!ctx.mounted) return;
                    final data = createNotificationData(m);
                    ctx.read<NotificationProvider>().addFromRemoteData(data);
                  });
                });
              }
              return GetMaterialApp(
                debugShowCheckedModeBanner: false,
                theme: AppThemeData.lightTheme,
                navigatorKey: NavigationService.navigatorKey,
                getPages: AppRoutes.pages,
                initialRoute: AppRoutes.splash,
                locale: lp.locale,
                translations: AppTranslations(),
                fallbackLocale: const Locale('en'),
                builder: (context, child) => GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                  child: child,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
