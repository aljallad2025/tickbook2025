import 'package:evento_app/app/app_text_styles.dart';
import 'package:evento_app/app/status_color.dart';
import 'package:evento_app/features/bookings/data/models/booking_models.dart';
import 'package:evento_app/network_services/core/navigation_service.dart';
import 'package:evento_app/features/bookings/ui/screens/booking_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BookingCard extends StatelessWidget {
  final BookingItemModel item;
  final VoidCallback? onTap;
  final Color? accentColor;
  final String idLabel;

  const BookingCard({
    super.key,
    required this.item,
    this.onTap,
    this.accentColor,
    this.idLabel = 'Booking ID',
  });

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
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
    final d = dt.day.toString().padLeft(2, '0');
    final m = months[dt.month - 1];
    final y = dt.year.toString();
    return '$d $m $y';
  }

  String _extractTime(String raw) {
    if (raw.isEmpty) return '';
    final parts = raw.trim().split(RegExp(r"\s+"));
    if (parts.isEmpty) return '';
    return parts.last;
  }

  @override
  Widget build(BuildContext context) {
    final bookingId = item.bookingId;
    final status = (item.paymentStatus.tr).isEmpty
        ? 'pending'.tr
        : item.paymentStatus.tr;
    final bookingDate = _formatDate(item.createdAt);
    final String eventTitle = (item.eventTitle ?? '').isEmpty
        ? 'Event #${item.eventId}'
        : item.eventTitle!;
    final organizerFull = (item.organizerName ?? '').trim();
    final organizerName = organizerFull.isEmpty
        ? 'Organizer #${item.organizerId ?? ''}'
        : organizerFull;
    final startTime = _extractTime(item.eventDateRaw);

    final effectiveAccent = accentColor ?? Theme.of(context).primaryColor;

    return InkWell(
      onTap:
          onTap ??
          () {
            NavigationService.pushAnimated(
              BookingDetailsScreen(
                bookingId: item.id,
                eventTitle: item.eventTitle ?? '',
              ),
            );
          },
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0.3,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      '${idLabel.tr} : $bookingId',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: getStatusColor(status),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      status[0].toUpperCase() + status.substring(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.event_note,
                        size: 16,
                        color: Colors.grey.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${'Booking Date'.tr}: $bookingDate',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 16,
                    child: VerticalDivider(
                      thickness: 1.5,
                      color: Colors.grey.shade600,
                      width: 0,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(startTime, style: AppTextStyles.bodySmall),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          eventTitle,
                          style: AppTextStyles.headingSmall.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.storefront_rounded,
                        size: 16,
                        color: Colors.grey.shade700,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'By: $organizerName',
                          style: AppTextStyles.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'View Details'.tr,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: effectiveAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.chevron_right_rounded, color: effectiveAccent),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
