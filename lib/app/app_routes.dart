import 'package:evento_app/features/account/ui/screens/update_profile_screen.dart';
import 'package:evento_app/features/auth/ui/screens/otp_verify_screen.dart';
import 'package:evento_app/features/auth/ui/screens/reset_password_screen.dart';
import 'package:evento_app/features/account/ui/screens/update_password.dart';
import 'package:evento_app/features/checkout/ui/screens/checkout_success_screen.dart';
import 'package:evento_app/features/checkout/ui/screens/checkout_webview.dart';
import 'package:get/get.dart';
import 'package:evento_app/features/categories/ui/screens/all_categories_screen.dart';
import 'package:evento_app/features/account/ui/screens/dashboard_screen.dart';
import 'package:evento_app/features/auth/ui/screens/login_screen.dart';
import 'package:evento_app/features/auth/ui/screens/signup_screen.dart';
import 'package:evento_app/features/auth/ui/screens/splash_screen.dart';
import 'package:evento_app/features/bookings/ui/screens/booking_details_screen.dart';
import 'package:evento_app/features/bookings/ui/screens/bookings_screen.dart';
import 'package:evento_app/features/events/ui/screens/event_details_screen.dart';
import 'package:evento_app/features/events/ui/screens/events_screen.dart';
import 'package:evento_app/features/events/ui/screens/tickets_screen.dart';
import 'package:evento_app/features/events/ui/screens/seat_plan_screen.dart';
import 'package:evento_app/features/events/providers/tickets_provider.dart';
import 'package:evento_app/features/events/providers/seat_plan_provider.dart';
import 'package:provider/provider.dart';
import 'package:evento_app/features/home/ui/screens/bottom_nav.dart';
import 'package:evento_app/features/organizers/ui/screens/organizers.dart';
import 'package:evento_app/features/organizers/ui/screens/organizer_details_screen.dart';
import 'package:evento_app/features/wishlist/ui/screens/wishlist_screen.dart';
import 'package:evento_app/features/support/ui/screens/support_tickets.dart';
import 'package:evento_app/features/support/ui/screens/ticket_details.dart';
import 'package:evento_app/features/support/providers/support_tickets_provider.dart';
import 'package:evento_app/features/support/providers/support_ticket_details_provider.dart';
import 'package:evento_app/features/home/ui/screens/notifications_screen.dart';
import 'package:evento_app/features/account/ui/screens/settings_screen.dart';
import 'package:evento_app/features/checkout/ui/screens/checkout_screen.dart';
import 'package:evento_app/features/auth/ui/screens/checkout_login_screen.dart';

class AppRoutes {
  AppRoutes._();

  // Route names
  static const String root = '/';
  static const String splash = '/splash';
  static const String bottomNav = '/home';
  static const String accountTab = '/account';
  static const String dashboard = '/dashboard';
  static const String bookings = '/bookings';
  static const String bookingDetails = '/bookingDetails';
  static const String wishlist = '/wishlist';
  static const String supportTickets = '/supportTickets';
  static const String supportTicketDetails = '/supportTicketDetails';
  static const String events = '/events';
  static const String organizers = '/organizers';
  static const String allCategories = '/categories/all';
  static const String organizerDetails = '/organizerDetails';
  static const String eventDetails = '/eventDetails';
  static const String tickets = '/tickets';
  static const String seatPlan = '/seatPlan';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String updateProfile = '/editProfile';
  static const String updatePassword = '/updatePassword';
  static const String otpVerify = '/auth/otp-verify';
  static const String resetPassword = '/auth/reset-password';
  static const String notifications = '/notifications';
  static const String settings = '/settings';
  static const String checkout = '/checkout';
  static const String checkoutLogin = '/checkoutLogin';
  static const String checkoutSuccess = '/checkoutSuccess';
  static const String checkoutWebView = '/checkoutWebView';
  static const String authorizeNetWebView = '/authorizeNetWebView';

  // GetX pages
  static final List<GetPage<dynamic>> pages = [
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(
      name: bottomNav,
      page: () {
        final args = Get.arguments;
        int index = 0;
        if (args is int) {
          index = args;
        } else if (args is Map && args['index'] is int) {
          index = args['index'] as int;
        }
        return BottomNavBar(initialIndex: index);
      },
    ),
    GetPage(name: accountTab, page: () => const BottomNavBar(initialIndex: 3)),
    GetPage(name: dashboard, page: () => const DashboardScreen()),
    GetPage(name: bookings, page: () => const BookingsScreen()),
    GetPage(
      name: bookingDetails,
      page: () {
        final a = Get.arguments;
        int id = 0;
        String eventTitle = '';
        if (a is int) {
          id = a;
        } else if (a is String) {
          id = int.tryParse(a) ?? 0;
        } else if (a is Map) {
          if (a['id'] is int) {
            id = a['id'] as int;
          } else if (a['id'] is String) {
            id = int.tryParse(a['id'] as String) ?? 0;
          } else if (a['bookingId'] is int) {
            id = a['bookingId'] as int;
          } else if (a['bookingId'] is String) {
            id = int.tryParse(a['bookingId'] as String) ?? 0;
          } else if (a['booking_id'] is String) {
            id = int.tryParse(a['booking_id'] as String) ?? 0;
          }
          if (a['eventTitle'] is String) {
            eventTitle = a['eventTitle'] as String;
          } else if (a['event_title'] is String) {
            eventTitle = a['event_title'] as String;
          }
        }
        return BookingDetailsScreen(bookingId: id, eventTitle: eventTitle);
      },
    ),
    GetPage(name: wishlist, page: () => const WishlistScreen()),
    GetPage(
      name: supportTickets,
      page: () => ChangeNotifierProvider(
        create: (_) => SupportTicketsProvider(),
        child: const SupportTickets(),
      ),
    ),
    GetPage(
      name: supportTicketDetails,
      page: () {
        final a = Get.arguments;
        int id = 0;
        if (a is int) {
          id = a;
        } else if (a is String) {
          id = int.tryParse(a) ?? 0;
        } else if (a is Map) {
          if (a['id'] is int) {
            id = a['id'] as int;
          } else if (a['ticketId'] is int) {
            id = a['ticketId'] as int;
          } else if (a['id'] is String) {
            id = int.tryParse(a['id'] as String) ?? 0;
          } else if (a['ticketId'] is String) {
            id = int.tryParse(a['ticketId'] as String) ?? 0;
          }
        }
        return ChangeNotifierProvider(
          create: (_) => SupportTicketDetailsProvider(),
          child: TicketDetails(ticketId: id),
        );
      },
    ),
    GetPage(name: events, page: () => const EventsScreen()),
    GetPage(name: organizers, page: () => const Organizers()),
    GetPage(name: notifications, page: () => NotificationsScreen()),
    GetPage(name: settings, page: () => const SettingsScreen()),
    GetPage(name: allCategories, page: () => const AllCategoriesScreen()),
    GetPage(
      name: organizerDetails,
      page: () {
        final args = Get.arguments;
        int id = 0;
        bool isAdmin = false;
        if (args is Map) {
          if (args['id'] is int) id = args['id'] as int;
          if (args['isAdmin'] is bool) isAdmin = args['isAdmin'] as bool;
        } else if (args is int) {
          id = args;
        }
        return OrganizerDetailsScreen(id: id, isAdmin: isAdmin);
      },
    ),
    GetPage(
      name: eventDetails,
      page: () {
        final args = Get.arguments;
        int eventId = 0;
        if (args is int) {
          eventId = args;
        } else if (args is Map && args['eventId'] is int) {
          eventId = args['eventId'] as int;
        }
        return EventDetailsScreen(eventId: eventId);
      },
    ),
    GetPage(name: checkout, page: () => const CheckoutScreen()),
    GetPage(name: checkoutLogin, page: () => CheckoutLoginScreen()),
    GetPage(name: checkoutWebView, page: () => const CheckoutWebView()),
    GetPage(
      name: authorizeNetWebView,
      page: () => const CheckoutWebView(),
    ),
    GetPage(
      name: checkoutSuccess,
      page: () {
        final rawArgs = Get.arguments;
        Map<String, dynamic> castArgs;
        if (rawArgs is Map) {
          try {
            castArgs = Map<String, dynamic>.from(rawArgs);
          } catch (_) {
            castArgs = {
              for (final e in (rawArgs).entries) e.key.toString(): e.value,
            };
          }
        } else {
          castArgs = <String, dynamic>{};
        }
        return CheckoutSuccessScreen(arguments: castArgs);
      },
    ),
    GetPage(
      name: tickets,
      page: () {
        final args = Get.arguments;
        int eventId = 0;
        if (args is int) {
          eventId = args;
        } else if (args is Map && args['eventId'] is int) {
          eventId = args['eventId'] as int;
        }
        return ChangeNotifierProvider(
          create: (_) => TicketsProvider(),
          child: TicketsScreen(eventId: eventId),
        );
      },
    ),
    GetPage(
      name: seatPlan,
      page: () {
        final a = Get.arguments;
        int eventId = 0;
        int ticketId = 0;
        int slotUniqueId = 0;
        if (a is Map) {
          eventId = a['eventId'] is int
              ? a['eventId'] as int
              : int.tryParse('${a['eventId'] ?? 0}') ?? 0;
          ticketId = a['ticketId'] is int
              ? a['ticketId'] as int
              : int.tryParse('${a['ticketId'] ?? 0}') ?? 0;
          slotUniqueId = a['slotUniqueId'] is int
              ? a['slotUniqueId'] as int
              : int.tryParse('${a['slotUniqueId'] ?? 0}') ?? 0;
        }
        return ChangeNotifierProvider(
          create: (_) => SeatPlanProvider(
            eventId: eventId,
            ticketId: ticketId,
            slotUniqueId: slotUniqueId,
          )..init(),
          child: SeatPlanScreen(
            eventId: eventId,
            ticketId: ticketId,
            slotUniqueId: slotUniqueId,
          ),
        );
      },
    ),
    GetPage(
      name: login,
      page: () {
        final args = Get.arguments;
        final redirectToHome = (args is Map && args['redirectToHome'] == true);
        final popOnSuccess = (args is Map && args['popOnSuccess'] == true);
        return LoginScreen(
          redirectToHome: redirectToHome,
          popOnSuccess: popOnSuccess,
        );
      },
    ),
    GetPage(name: signup, page: () => SignUpScreen()),
    GetPage(name: updateProfile, page: () => const UpdateProfileScreen()),
    GetPage(name: updatePassword, page: () => const UpdatePassword()),
    GetPage(name: otpVerify, page: () => const OtpVerifyScreen()),
    GetPage(name: resetPassword, page: () => const ResetPasswordScreen()),
  ];
}
