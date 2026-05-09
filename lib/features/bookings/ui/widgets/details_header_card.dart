import 'package:evento_app/app/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BookingHeaderCard extends StatelessWidget {
  final String bookingId;
  final String paymentStatusText;
  final Color statusColor;
  final String bookingDateText;
  final String eventDateText;

  const BookingHeaderCard({
    super.key,
    required this.bookingId,
    required this.paymentStatusText,
    required this.statusColor,
    required this.bookingDateText,
    required this.eventDateText,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '${'Booking ID'.tr}: $bookingId',
                  style: AppTextStyles.bodyLarge,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    paymentStatusText.tr.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              bookingDateText.tr,
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              eventDateText.tr,
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
