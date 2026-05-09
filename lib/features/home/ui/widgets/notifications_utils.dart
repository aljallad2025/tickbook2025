import 'package:evento_app/features/home/data/models/fcm_notification_model.dart';
import 'package:evento_app/features/home/providers/notification_provider.dart';
import 'package:intl/intl.dart';

bool isBookingNotification(NotificationModel n) {
  // Prefer structured FCM data parsing first
  try {
    final model = FcmNotificationModel.fromJson({
      'id': n.id,
      'title': n.title,
      'body': n.body,
      'data': n.payload ?? const <String, dynamic>{},
    });
    if (model.data.isBookingNotification) return true;
  } catch (_) {
    // ignore and fallback to heuristics
  }

  // Heuristic fallback for legacy or non-standard payloads
  final tokens = [
    'book',
    'booking',
    'order',
    'ticket',
    'reservation',
    'checkout',
    'payment',
  ];
  String lc(String? s) => (s ?? '').toLowerCase();
  bool containsAny(String s) => tokens.any((t) => s.contains(t));

  if (containsAny(lc(n.type))) return true;
  if (containsAny(lc(n.title)) || containsAny(lc(n.body))) return true;

  final p = n.payload ?? const <String, dynamic>{};
  final route = lc(p['route']?.toString());
  final url = lc((p['button_url'] ?? p['url'] ?? p['link'])?.toString());
  final message = lc(p['message']?.toString());
  final btnName = lc(p['button_name']?.toString());
  final category = lc(p['category']?.toString());
  final module = lc(p['module']?.toString());
  if (containsAny(route) ||
      containsAny(url) ||
      containsAny(message) ||
      containsAny(btnName) ||
      containsAny(category) ||
      containsAny(module)) {
    return true;
  }

  final keyHit = p.keys
      .map((k) => k.toString().toLowerCase())
      .any(
        (k) =>
            k.contains('booking') ||
            k.contains('order') ||
            k.contains('ticket') ||
            k.contains('reservation'),
      );
  if (keyHit) return true;

  return false;
}

String timeAgo(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inSeconds < 60) return "${diff.inSeconds} sec ago";
  if (diff.inMinutes < 60) return "${diff.inMinutes} min ago";
  if (diff.inHours < 24) return "${diff.inHours} hour ago";
  if (diff.inDays == 1) return "Yesterday";
  if (diff.inDays < 7) return "${diff.inDays} days ago";
  return DateFormat('dd MMM, yyyy').format(dt);
}

