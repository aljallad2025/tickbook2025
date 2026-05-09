import 'package:evento_app/app/app_text_styles.dart';
import 'package:evento_app/features/events/data/models/event_details_models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TitleAndStatus extends StatelessWidget {
  const TitleAndStatus({super.key, required this.event});
  final EventDetailsModel event;

  DateTime? _combine(DateTime? d, String? t) {
    if (d == null) return null;
    int hour = 0, minute = 0;
    if (t != null && t.trim().isNotEmpty) {
      var s = t.trim().toLowerCase();
      final am = s.contains('am');
      final pm = s.contains('pm');
      s = s.replaceAll('am', '').replaceAll('pm', '').trim();
      final parts = s.split(':');
      if (parts.isNotEmpty) {
        hour = int.tryParse(parts[0].replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      }
      if (parts.length > 1) {
        minute = int.tryParse(parts[1].replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      }
      if (pm && hour < 12) hour += 12;
      if (am && hour == 12) hour = 0;
    } else {
      hour = d.hour;
      minute = d.minute;
    }
    return DateTime(d.year, d.month, d.day, hour, minute);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final startDT = _combine(event.startDate, event.startTime);
    final DateTime? endDT =
        event.endDateTime ?? _combine(event.endDate, event.endTime);
    final bool isRunning =
        (startDT != null && !now.isBefore(startDT)) &&
            (endDT != null && now.isBefore(endDT));
    final bool isEnded = endDT != null && !now.isBefore(endDT);
    final label = isEnded
        ? 'Ended'
        : isRunning
        ? 'Running'
        : 'Upcoming';

    final Color bg = isEnded
        ? Colors.red.shade50
        : isRunning
        ? Colors.green.shade50
        : Colors.blue.shade50;
    final Color fg = isEnded
        ? Colors.red.shade700
        : isRunning
        ? Colors.green.shade700
        : Colors.blue.shade700;
    final Color bd = isEnded
        ? Colors.red.shade200
        : isRunning
        ? Colors.green.shade200
        : Colors.blue.shade200;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            event.title,
            style: AppTextStyles.headingSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: bd),
          ),
          child: Text(
            label.tr,
            style: AppTextStyles.bodyLargeGrey.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ),
      ],
    );
  }
}