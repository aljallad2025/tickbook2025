import 'package:evento_app/features/support/providers/support_ticket_details_provider.dart';
import 'package:evento_app/features/support/providers/support_tickets_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'package:evento_app/features/home/providers/locale_provider.dart';
import 'package:evento_app/features/home/providers/home_provider.dart';
import 'package:evento_app/features/events/providers/events_provider.dart';
import 'package:evento_app/features/events/providers/event_details_provider.dart';
import 'package:evento_app/features/organizers/providers/organizers_provider.dart';
import 'package:evento_app/features/organizers/providers/organizer_details_provider.dart';
import 'package:evento_app/features/bookings/providers/bookings_provider.dart';
import 'package:evento_app/features/bookings/providers/booking_details_provider.dart';
import 'package:evento_app/features/account/providers/account_provider.dart';
import 'package:evento_app/features/account/providers/dashboard_provider.dart';
import 'package:evento_app/features/wishlist/providers/wishlist_provider.dart';
import 'package:evento_app/features/auth/providers/auth_provider.dart';

class LanguageReloadObserver extends StatefulWidget {
  final Widget child;
  const LanguageReloadObserver({super.key, required this.child});

  @override
  State<LanguageReloadObserver> createState() => _LanguageReloadObserverState();
}

class _LanguageReloadObserverState extends State<LanguageReloadObserver> {
  String? _lastLang;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final code = context.read<LocaleProvider>().locale.languageCode;
      _lastLang = code;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LocaleProvider>().locale.languageCode;
    if (_lastLang != null && _lastLang != lang) {
      _lastLang = lang;
      WidgetsBinding.instance.addPostFrameCallback((_) => _refreshAll(context));
    }
    return widget.child;
  }

  Future<void> _refreshAll(BuildContext context) async {
    if (!mounted) return;

    final auth = context.read<AuthProvider>();
    final home = context.read<HomeProvider>();
    final events = context.read<EventsProvider>();
    final organizers = context.read<OrganizersProvider>();
    final eventDetails = context.read<EventDetailsProvider>();
    final organizerDetails = context.read<OrganizerDetailsProvider>();
    final bookings = context.read<BookingsProvider>();
    final bookingDetails = context.read<BookingDetailsProvider>();
    final account = context.read<AccountProvider>();
    final dashboard = context.read<DashboardProvider>();
    T? maybeRead<T>() {
      try {
        return context.read<T>();
      } catch (_) {
        return null;
      }
    }

    final tickets = maybeRead<SupportTicketsProvider>();
    final ticketDetails = maybeRead<SupportTicketDetailsProvider>();
    final wishlist = context.read<WishlistProvider>();

    final token = auth.token ?? '';

    try {
      await home.refresh();
    } catch (_) {}
    try {
      await events.refresh();
    } catch (_) {}
    try {
      await organizers.refresh();
    } catch (_) {}
    try {
      await eventDetails.refresh();
    } catch (_) {}
    try {
      await organizerDetails.refresh();
    } catch (_) {}

    if (token.isNotEmpty) {
      try {
        await bookings.refresh(token);
      } catch (_) {}
      try {
        await bookingDetails.refresh();
      } catch (_) {}
      try {
        await account.refresh(token);
      } catch (_) {}
      try {
        await dashboard.refresh(token);
      } catch (_) {}
      if (tickets != null) {
        try {
          await tickets.refresh(token);
        } catch (_) {}
      }
      if (ticketDetails != null) {
        try {
          await ticketDetails.refresh(token);
        } catch (_) {}
      }
      try {
        await wishlist.fetch();
      } catch (_) {}
    }
  }
}
