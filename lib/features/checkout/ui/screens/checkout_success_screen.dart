import 'dart:convert';
import 'package:evento_app/app/app_routes.dart';
import 'package:evento_app/app/status_color.dart';
import 'package:flutter/material.dart';
import 'package:evento_app/features/common/ui/widgets/custom_app_bar.dart';
import 'package:evento_app/app/app_text_styles.dart';
import 'package:evento_app/app/app_colors.dart';
import 'package:evento_app/features/bookings/data/models/booking_models.dart';
import 'package:get/get.dart';
import 'package:evento_app/features/checkout/ui/widgets/checkout_success_header.dart';
import 'package:evento_app/features/checkout/ui/widgets/invoice_button.dart';
import 'package:evento_app/features/checkout/ui/widgets/kv_row.dart';
import 'package:evento_app/features/checkout/ui/widgets/section_title.dart';
import 'package:evento_app/features/checkout/ui/widgets/ticket_variation_tile.dart';

import 'package:evento_app/features/checkout/ui/widgets/ticket_seats_summary.dart';

class CheckoutSuccessScreen extends StatelessWidget {
  final Map<String, dynamic> arguments;
  const CheckoutSuccessScreen({super.key, required this.arguments});

  @override
  Widget build(BuildContext context) {
    final arguments = this.arguments;
    Map<String, dynamic> bookingInfo = <String, dynamic>{};
    final rawBi = arguments['booking_info'];
    if (rawBi is Map) {
      try {
        bookingInfo = Map<String, dynamic>.from(rawBi);
      } catch (_) {
        bookingInfo = {
          for (final e in rawBi.entries) e.key.toString(): e.value,
        };
      }
    } else if (rawBi is String) {
      try {
        final trimmed = rawBi.trim();
        if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
          final decoded = jsonDecode(trimmed);
          if (decoded is Map) {
            bookingInfo = Map<String, dynamic>.from(decoded);
          }
        }
      } catch (_) {}
    }
    if (bookingInfo.isEmpty && arguments['booking_id'] != null) {
      bookingInfo = {
        for (final e in arguments.entries) e.key.toString(): e.value,
      };
    }
    BookingItemModel? bookingModel;
    if (bookingInfo.isNotEmpty) {
      try {
        final candidate = BookingItemModel.fromJson(bookingInfo);
        if (candidate.bookingId.isNotEmpty) {
          bookingModel = candidate;
        }
      } catch (_) {
        bookingModel = null;
      }
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Checkout Success',
        onTap: () => Get.offAllNamed(AppRoutes.bottomNav),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        children: [
          CheckoutSuccessHeader(),
          const SizedBox(height: 16),
          if (bookingModel != null) ...[
            SectionTitle('Booking Summary'),
            Card(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    KvRow('Booking ID', bookingModel.bookingId),
                    KvRow('Event ID', bookingModel.eventId),
                    if (bookingModel.eventTitle != null &&
                        bookingModel.eventTitle!.isNotEmpty)
                      KvRow('Event', bookingModel.eventTitle!),
                    KvRow('Customer', bookingModel.customerFullName),
                    KvRow('Email', bookingModel.email),
                    if (bookingModel.phone.isNotEmpty)
                      KvRow('Phone', bookingModel.phone),
                    if (bookingModel.paymentMethod != null)
                      KvRow('Payment Method', bookingModel.paymentMethod!),
                    const SizedBox(height: 6),
                    KvRow(
                      'Payment Method',
                      bookingModel.paymentStatus.toUpperCase(),
                      color: getStatusColor(bookingModel.paymentStatus),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            SectionTitle('Totals'),
            Card(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    KvRow(
                      'Price',
                      _fmtMoney(
                        bookingModel.price,
                        bookingModel.currencySymbol,
                      ),
                    ),
                    KvRow('Tax', () {
                      String v = bookingModel?.tax ?? '';
                      double? parsed = double.tryParse(
                        v.replaceAll(',', '').trim(),
                      );
                      if (parsed == null || parsed <= 0) {
                        final payload = arguments['payload'];
                        String? alt;
                        if (payload is Map) {
                          final p = payload;
                          alt =
                              (p['tax'] ??
                                      p['tax_total'] ??
                                      p['tax_amount'] ??
                                      p['vat'] ??
                                      p['vat_amount'])
                                  ?.toString();
                        }
                        alt ??=
                            (arguments['tax'] ??
                                    arguments['tax_total'] ??
                                    arguments['tax_amount'] ??
                                    arguments['vat'] ??
                                    arguments['vat_amount'])
                                ?.toString();
                        if (alt != null && alt.trim().isNotEmpty) v = alt;
                      }
                      return _fmtMaybeMoney(v, bookingModel?.currencySymbol);
                    }()),
                    KvRow('Discount', bookingModel.discount),
                    KvRow('Commission', bookingModel.commission),
                    if (bookingModel.earlyBirdDiscount.isNotEmpty)
                      KvRow('Early Bird', bookingModel.earlyBirdDiscount),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            SectionTitle('Tickets'),
            Card(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (bookingModel.variations.isNotEmpty) ...[
                      ...bookingModel.variations.map(
                        (v) => TicketVariationTile(
                          v: v,
                          currencySymbol: bookingModel?.currencySymbol ?? '',
                        ),
                      ),
                    ] else ...[
                      TicketSeatsSummary(
                        payload: arguments['payload'] as Map<String, dynamic>?,
                        currencySymbol:
                            (bookingModel.currencySymbol ??
                            ((arguments['payload'] is Map)
                                ? ((arguments['payload']
                                          as Map)['currencySymbol']
                                      ?.toString())
                                : null)),
                        currencyPosition: ((arguments['payload'] is Map)
                            ? ((arguments['payload']
                                      as Map)['currencySymbolPosition']
                                  ?.toString())
                            : null),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            InvoiceButton(bookingInfo: bookingInfo),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Text(
                'Booking data unavailable. Please return to bookings list or retry.',
                style: AppTextStyles.bodySmall,
              ),
            ),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.receipt_long),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => Get.offNamedUntil(
                    AppRoutes.bookings,
                    ModalRoute.withName(AppRoutes.bottomNav),
                  ),
                  label: const Text('View Bookings'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.home_outlined),
                  onPressed: () => Get.offAllNamed(AppRoutes.bottomNav),
                  label: const Text('Go Home'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _fmtMoney(String v, String? symbol) {
    final s = symbol ?? '\$';
    return '$s$v';
  }

  String _fmtMaybeMoney(String v, String? symbol) {
    final s = symbol ?? '\$';
    final parsed = double.tryParse(v.replaceAll(',', '').trim());
    if (parsed == null) return v;
    return '$s${parsed.toStringAsFixed(2)}';
  }
}
