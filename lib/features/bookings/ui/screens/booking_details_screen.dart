import 'package:evento_app/app/app_colors.dart';
import 'package:evento_app/app/status_color.dart';
import 'package:evento_app/features/auth/providers/auth_provider.dart';
import 'package:evento_app/features/bookings/data/models/booking_details_model.dart';
import 'package:evento_app/features/bookings/providers/booking_details_provider.dart';
import 'package:evento_app/features/bookings/ui/screens/ticket_viewer_screen.dart';
import 'package:evento_app/features/bookings/ui/sections/billing_details_section.dart';
import 'package:evento_app/features/bookings/ui/sections/organizer_details_section.dart';
import 'package:evento_app/features/bookings/ui/sections/payment_information_section.dart';
import 'package:evento_app/features/bookings/ui/widgets/details_header_card.dart';
import 'package:evento_app/features/bookings/ui/widgets/section_card.dart';
import 'package:evento_app/features/common/ui/widgets/custom_app_bar.dart';
import 'package:evento_app/features/common/ui/widgets/custom_cpi.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:evento_app/utils/auth_aware.dart';
import 'package:evento_app/features/common/ui/widgets/custom_snack_bar_widget.dart';

class BookingDetailsScreen extends StatelessWidget {
  final int bookingId;
  final String eventTitle;

  const BookingDetailsScreen({
    super.key,
    required this.bookingId,
    required this.eventTitle,
  });

  String _cleanComma(String s) {
    final cleaned = s
        .split(',')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty && part != '-')
        .join(', ');
    return cleaned.isEmpty ? '-' : cleaned;
  }

  String _fmtDate(DateTime? dt) {
    if (dt == null) return '-';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} ${dt.year}';
  }

  String _money(String amount, String? symbol, String? symbolPos) {
    final a = amount.isEmpty ? '0' : amount;
    final sym = symbol ?? '';
    if (sym.isEmpty) return a;
    final left = (symbolPos?.toLowerCase() ?? 'left') == 'left';
    return left ? '$sym$a' : '$a$sym';
  }

  String _taxPercentage(int? v) => v == null ? '' : '  (${v.toString()}%)';
  String _earlyBird(String v) => v.isEmpty ? '' : '  (Early-bird: $v)';

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final token = authProvider.token ?? '';

    if (token.isEmpty) {
      return const Scaffold(
        body: AuthAware(routeName: '/bookings', child: SizedBox.shrink()),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      context.read<BookingDetailsProvider>().ensureInitialized(
        token: token,
        bookingId: bookingId,
      );
    });

    Future<void> refresh() async {
      await context.read<BookingDetailsProvider>().refresh();
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Consumer<BookingDetailsProvider>(
          builder: (context, prov, _) {
            final title = (prov.page != null && prov.page!.pageTitle.isNotEmpty)
                ? prov.page!.pageTitle
                : 'Booking Details'.tr;
            return CustomAppBar(title: title);
          },
        ),
      ),
      body: Consumer<BookingDetailsProvider>(
        builder: (context, prov, _) {
          if (prov.loading && prov.page == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (prov.authRequired && prov.page == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final auth = context.read<AuthProvider>();
              if (!auth.navigatingToLogin) {
                auth.onAuthExpired(
                  from: const RouteSettings(name: '/bookings'),
                  message: prov.error ?? 'Session Expired',
                );
              }
            });
            return const SizedBox.shrink();
          }

          if (prov.error != null && prov.page == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Failed to load booking details'.tr,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
            );
          }

          if (prov.page == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  prov.error ?? 'Failed to load booking details'.tr,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
            );
          }

          final data = prov.page!;
          final bookings = data.booking;
          final org = data.organizer;
          final admin = data.admin;

          final billingAddress = bookings != null
              ? _cleanComma(
                  '${bookings.address}, ${bookings.city}, ${bookings.state}, ${bookings.country}',
                )
              : '-';

          final organizerAddress = org != null
              ? _cleanComma(
                  '${org.address ?? ''}, ${org.city ?? ''}, ${org.state ?? ''}, ${org.country ?? ''}',
                )
              : '-';

          final bookingDateText = bookings != null
              ? '${'Booking Date'.tr}: ${_fmtDate(bookings.createdAt)}'
              : '';
          final eventDateText = bookings != null
              ? '${'Event Start Date'.tr}: ${bookings.eventDateRaw}'
              : '';

          return RefreshIndicator.adaptive(
            backgroundColor: AppColors.primaryColor,
            color: Colors.white,
            onRefresh: refresh,
            child: Stack(
              children: [
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (bookings != null)
                      BookingHeaderCard(
                        bookingId: bookings.bookingId,
                        paymentStatusText: bookings.paymentStatus,
                        statusColor: getStatusColor(bookings.paymentStatus),
                        bookingDateText: bookingDateText,
                        eventDateText: eventDateText,
                      )
                    else
                      SectionCard(
                        title: data.pageTitle.tr.isNotEmpty
                            ? data.pageTitle.tr
                            : 'Booking Details'.tr,
                        children: [
                          Text('No booking details available right now.'.tr),
                        ],
                      ),

                    // View Ticket Button
                    if (bookings != null) _viewTicket(bookings, context),

                    // Billing Details Section
                    if (bookings != null)
                      BillingDetailsSection(
                        name: '${bookings.firstName} ${bookings.lastName}'
                            .trim(),
                        email: bookings.email,
                        phone: bookings.phone,
                        country: bookings.country,
                        city: bookings.city,
                        address: billingAddress,
                        zipCode: bookings.zipCode,
                      ),

                    const SizedBox(height: 12),

                    // Organizer Details Section
                    if (org != null || admin != null)
                      OrganizerDetailsSection(
                        hasOrganizer: org != null,
                        hasAdmin: admin != null,
                        organizerUsername: org?.username ?? '',
                        organizerName: org?.name ?? '',
                        organizerEmail: org?.email ?? '',
                        organizerPhone: org?.phone ?? '',
                        organizerCity: org?.city ?? '',
                        organizerState: org?.state ?? '',
                        organizerCountry: org?.country ?? '',
                        organizerAddress: organizerAddress,
                        adminUsername: admin?.username ?? '',
                        adminFullName: _cleanComma(
                          '${admin?.firstName ?? ''} ${admin?.lastName ?? ''}',
                        ),
                        adminEmail: admin?.email ?? '',
                        adminPhone: admin?.phone ?? '',
                        adminAddress: admin?.address ?? '',
                      ),

                    const SizedBox(height: 12),

                    // Payment Information Section
                    if (bookings != null)
                      PaymentInformationSection(
                        eventTitle: eventTitle,
                        eventId: bookings.eventId,
                        paymentMethod: bookings.paymentMethod ?? '',
                        paymentStatusText: bookings.paymentStatus.toUpperCase(),
                        paymentStatusColor: getStatusColor(
                          bookings.paymentStatus,
                        ),
                        priceText: _money(
                          bookings.price,
                          bookings.currencySymbol,
                          bookings.currencySymbolPosition,
                        ),
                        quantity: bookings.quantity,
                        taxText:
                            _money(
                              bookings.tax,
                              bookings.currencySymbol,
                              bookings.currencySymbolPosition,
                            ) +
                            _taxPercentage(bookings.taxPercentage),
                        discountText:
                            _money(
                              bookings.discount,
                              bookings.currencySymbol,
                              bookings.currencySymbolPosition,
                            ) +
                            _earlyBird(bookings.earlyBirdDiscount),
                      ),
                  ],
                ),
                if (prov.refreshing)
                  Container(
                    color: Colors.black26,
                    child: const Center(child: CustomCPI()),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Padding _viewTicket(BookingDetails bookings, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: ElevatedButton(
        onPressed: (bookings.invoice == null || bookings.invoice!.isEmpty)
            ? null
            : () {
                final url = bookings.invoice!;
                final uri = Uri.tryParse(url);
                if (uri == null) {
                  CustomSnackBar.show(
                    iconBgColor: AppColors.snackError,
                    context,
                    'Invalid invoice URL',
                  );
                  return;
                }
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        TicketViewerScreen(title: 'Ticket', url: url),
                  ),
                );
              },
        child: Text('View Ticket'.tr),
      ),
    );
  }
}
