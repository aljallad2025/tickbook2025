import 'package:evento_app/app/app_colors.dart';
import 'package:evento_app/app/app_text_styles.dart';
import 'package:evento_app/features/events/data/models/event_details_models.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:evento_app/features/common/ui/widgets/custom_snack_bar_widget.dart';

class LocationAndTimeRow extends StatelessWidget {
  const LocationAndTimeRow({super.key, required this.event});
  final EventDetailsModel event;

  String _formatSingleDateTime(EventDetailsModel e) {
    final DateTime? date = e.startDate;
    String? timeRaw = e.startTime;
    if (date == null || timeRaw == null || timeRaw.trim().isEmpty) {
      return '';
    }
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
    final m = months[date.month - 1];
    final day = date.day.toString().padLeft(2, '0');
    final year = date.year.toString();

    String timeFormatted = '';
    if (timeRaw.trim().isNotEmpty) {
      timeRaw = timeRaw.trim().toLowerCase();
      if (timeRaw.contains('am') || timeRaw.contains('pm')) {
        timeFormatted = timeRaw.replaceAll(':00 ', ' ');
      } else {
        final parts = timeRaw.split(':');
        int? hh = parts.isNotEmpty ? int.tryParse(parts[0]) : null;
        int? mm = parts.length > 1 ? int.tryParse(parts[1]) : null;
        if (hh != null && mm != null) {
          final am = hh < 12;
          int display = hh % 12;
          if (display == 0) display = 12;
          timeFormatted =
              '${display.toString().padLeft(2, '0')}:${mm.toString().padLeft(2, '0')} ${am ? 'am' : 'pm'}';
        }
      }
    }
    if (timeFormatted.isEmpty) return '';
    return '$m $day, $year, $timeFormatted';
  }

  @override
  Widget build(BuildContext context) {
    final addressRaw = event.address?.trim() ?? '';
    final effectiveAddress = addressRaw.isNotEmpty
        ? addressRaw
        : (event.eventType?.trim().isNotEmpty ?? false)
        ? (event.eventType!.trim().toUpperCase())
        : 'ONLINE';
    final bool isMultiple =
        (event.dateType == 'multiple') && event.dates.isNotEmpty;
    final singleDateStr = _formatSingleDateTime(event);
    final showSingleDate = !isMultiple && singleDateStr.isNotEmpty;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: InkWell(
            onTap: () async {
              if ((event.eventType ?? '').toLowerCase() == 'online') {
                CustomSnackBar.show(context, 'Online event — no map location.');
                return;
              }
              if (event.latitude == null || event.longitude == null) {
                CustomSnackBar.show(
                  iconBgColor: AppColors.snackError,
                  context,
                  'Location coordinates unavailable.',
                );
                return;
              }
              try {
                final enabled = await Geolocator.isLocationServiceEnabled();
                if (!enabled && context.mounted) {
                  CustomSnackBar.show(
                    iconBgColor: AppColors.snackError,
                    context,
                    'Enable location services to view nearby map.',
                  );
                  return;
                }
                var perm = await Geolocator.checkPermission();
                if (perm == LocationPermission.denied) {
                  perm = await Geolocator.requestPermission();
                }
                if (perm == LocationPermission.denied && context.mounted) {
                  CustomSnackBar.show(
                    iconBgColor: AppColors.snackError,
                    context,
                    'Location permission denied.',
                  );
                  return;
                }
                if (perm == LocationPermission.deniedForever &&
                    context.mounted) {
                  CustomSnackBar.show(
                    iconBgColor: AppColors.snackError,
                    context,
                    'Location permission permanently denied.',
                  );
                  return;
                }
                if (!context.mounted) return;
                final controller = DefaultTabController.of(context);
                controller.animateTo(1);
              } catch (e) {
                CustomSnackBar.show(
                  iconBgColor: AppColors.snackError,
                  context,
                  'Location error: $e',
                );
              }
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: AppColors.primaryColor,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    effectiveAddress,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyLargeGrey.copyWith(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        if (showSingleDate)
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: AppColors.primaryColor,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    singleDateStr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyLargeGrey.copyWith(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (isMultiple) Expanded(child: _FirstMultiDateDisplay(event: event)),
      ],
    );
  }
}

class _FirstMultiDateDisplay extends StatelessWidget {
  const _FirstMultiDateDisplay({required this.event});
  final EventDetailsModel event;

  String _fmt(EventMultiDateModel m) {
    DateTime? base = m.startDateTime ?? m.startDate;
    if (base == null) return 'Date';
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
    final mon = months[base.month - 1];
    final day = base.day.toString().padLeft(2, '0');
    final year = base.year.toString();
    String time = (m.startTime ?? '').trim();
    if (time.isNotEmpty &&
        !time.toLowerCase().contains('am') &&
        !time.toLowerCase().contains('pm')) {
      final parts = time.split(':');
      int hh = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0;
      int mm = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
      final am = hh < 12;
      int display = hh % 12;
      if (display == 0) display = 12;
      time =
          '${display.toString().padLeft(2, '0')}:${mm.toString().padLeft(2, '0')} ${am ? 'am' : 'pm'}';
    }
    return '$mon $day, $year${time.isNotEmpty ? ' • $time' : ''}';
  }

  @override
  Widget build(BuildContext context) {
    if (event.dates.isEmpty) return const SizedBox.shrink();
    final first = event.dates.first;
    return Row(
      children: [
        Icon(Icons.access_time, size: 16, color: AppColors.primaryColor),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            _fmt(first),
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
