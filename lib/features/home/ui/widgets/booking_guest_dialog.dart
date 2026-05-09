import 'package:evento_app/app/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> showBookingGuestDialog({
  required BuildContext context,
  required String title,
  required String bookingId,
  String? message,
  String? eventDate,
  String? paymentStatus,
  required VoidCallback onLogin,
}) async {
  final theme = Theme.of(context);
  await showModalBottomSheet(
    context: context,
    isScrollControlled: false,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.receipt_long_outlined),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Booking Notification'.tr,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (title.isNotEmpty)
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            const SizedBox(height: 8),
            Text('${'Booking ID'.tr}: $bookingId', style: theme.textTheme.bodyMedium),
            if ((eventDate ?? '').isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('${'Event Date'.tr}: $eventDate', style: theme.textTheme.bodyMedium),
            ],
            if ((paymentStatus ?? '').isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('${'Payment Status'.tr}: ${paymentStatus!.toUpperCase()}',
                  style: theme.textTheme.bodyMedium),
            ],
            if ((message ?? '').isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(message!, style: theme.textTheme.bodySmall),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text('Close'.tr),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    onLogin();
                  },
                  child: Text('Login to view'.tr),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

