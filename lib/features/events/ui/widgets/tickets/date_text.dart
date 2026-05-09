import 'package:evento_app/features/events/data/models/event_details_models.dart';

String formatEventDate(EventDetailsPageModel details) {
  try {
    final e = details.event;
    final date = e.startDate;
    final t = (e.startTime ?? '').trim();
    if (date == null) return t;
    int hh = 0, mm = 0;
    if (t.isNotEmpty) {
      final parts = t.split(':');
      if (parts.isNotEmpty) hh = int.tryParse(parts[0]) ?? 0;
      if (parts.length > 1) mm = int.tryParse(parts[1]) ?? 0;
    }
    final composed = DateTime(date.year, date.month, date.day, hh, mm);
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
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
    final dow = days[(composed.weekday - 1) % 7];
    final mon = months[composed.month - 1];
    int h = composed.hour % 12;
    if (h == 0) h = 12;
    final m = composed.minute.toString().padLeft(2, '0');
    final ampm = composed.hour >= 12 ? 'pm' : 'am';
    return '$dow, $mon ${composed.day}, ${composed.year} $h:$m$ampm';
  } catch (_) {
    return '';
  }
}

String formatOccurrence(EventMultiDateModel m) {
  try {
    final d = m.startDate;
    final t = (m.startTime ?? '').trim();
    if (d == null) return '';
    int hh = 0, mm = 0;
    if (t.isNotEmpty) {
      final parts = t.split(':');
      if (parts.isNotEmpty) hh = int.tryParse(parts[0]) ?? 0;
      if (parts.length > 1) mm = int.tryParse(parts[1]) ?? 0;
    }
    final composed = DateTime(d.year, d.month, d.day, hh, mm);
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
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
    final dow = days[(composed.weekday - 1) % 7];
    final mon = months[composed.month - 1];
    int h = composed.hour % 12;
    if (h == 0) h = 12;
    final mmin = composed.minute.toString().padLeft(2, '0');
    final ampm = composed.hour >= 12 ? 'pm' : 'am';
    return '$dow, $mon ${composed.day}, ${composed.year} $h:$mmin$ampm';
  } catch (_) {
    return '';
  }
}

String formatEventDateFromOccurrence(
  EventDetailsPageModel details,
  EventMultiDateModel? occ,
) {
  if (occ != null) return formatOccurrence(occ);
  return formatEventDate(details);
}

