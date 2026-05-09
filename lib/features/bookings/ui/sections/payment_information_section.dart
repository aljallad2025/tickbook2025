import 'package:evento_app/app/app_colors.dart';
import 'package:evento_app/network_services/core/navigation_service.dart';
import 'package:evento_app/features/bookings/ui/widgets/section_card.dart';
import 'package:evento_app/features/events/ui/screens/event_details_screen.dart';
import 'package:flutter/material.dart';

import '../widgets/info_row.dart';

class PaymentInformationSection extends StatelessWidget {
  final String eventTitle;
  final String eventId;
  final String paymentMethod;
  final String paymentStatusText;
  final Color paymentStatusColor;
  final String priceText;
  final String quantity;
  final String taxText;
  final String discountText;

  const PaymentInformationSection({
    super.key,
    required this.eventTitle,
    required this.eventId,
    required this.paymentMethod,
    required this.paymentStatusText,
    required this.paymentStatusColor,
    required this.priceText,
    required this.quantity,
    required this.taxText,
    required this.discountText,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Payment Info',
      children: [
        if (eventTitle.isNotEmpty)
          infoRow(
            'Event',
            eventTitle,
            onTap: () {
              final id = int.tryParse(eventId) ?? 0;
              NavigationService.pushAnimated(EventDetailsScreen(eventId: id));
            },
            vColor: AppColors.primaryColor,
            fontWeight: FontWeight.w600,
          ),
        if (paymentMethod.isNotEmpty) infoRow('Payment Method', paymentMethod),
        infoRow(
          'Payment Status',
          paymentStatusText,
          vColor: paymentStatusColor,
        ),
        if (priceText.isNotEmpty) infoRow('Price', priceText),
        if (quantity.isNotEmpty) infoRow('Quantity', quantity),
        if (taxText.trim().isNotEmpty) infoRow('Tax', taxText),
        if (discountText.trim().isNotEmpty) infoRow('Discount', discountText),
      ],
    );
  }
}
