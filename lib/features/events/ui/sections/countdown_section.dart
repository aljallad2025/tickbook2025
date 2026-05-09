import 'package:evento_app/app/app_text_styles.dart';
import 'package:evento_app/features/events/data/models/event_details_models.dart';
import 'package:evento_app/features/events/providers/event_details_provider.dart';
import 'package:evento_app/features/events/ui/widgets/event_details/countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class CountdownSection extends StatelessWidget {
  const CountdownSection({super.key, required this.event});
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
    final prov = context.watch<EventDetailsProvider>();
    final now = DateTime.now();
    DateTime? startDT = _combine(event.startDate, event.startTime);
    DateTime? rawEnd =
        event.endDateTime ?? _combine(event.endDate, event.endTime);

    // Multi-date override logic
    if ((event.dateType == 'multiple') && event.dates.isNotEmpty) {
      // Selected occurrence or next upcoming.
      EventMultiDateModel? occ = prov.selectedDateOccurrence;
      occ ??= event.dates.firstWhere((m) {
        final s = m.startDateTime ?? _combine(m.startDate, m.startTime);
        return s != null && s.isAfter(now);
      }, orElse: () => event.dates.last);
      startDT =
          occ.startDateTime ??
          _combine(occ.startDate, occ.startTime) ??
          startDT;
      rawEnd = occ.endDateTime ?? _combine(occ.endDate, occ.endTime) ?? rawEnd;
    }

    final bool isRunning =
        (startDT != null && !now.isBefore(startDT)) &&
        (rawEnd != null && now.isBefore(rawEnd));
    final bool isEnded = rawEnd != null && !now.isBefore(rawEnd);
    final label = isEnded
        ? 'Event Ended'
        : isRunning
        ? 'Event running till'
        : 'Event Starts In';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.tr,
          style: AppTextStyles.headingSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        CountdownTimer(
          event: event,
          targetOverride: isRunning ? rawEnd : null,
          startOverride: startDT,
          endOverride: rawEnd,
        ),
      ],
    );
  }
}
