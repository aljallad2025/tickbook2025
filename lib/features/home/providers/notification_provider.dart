import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:evento_app/network_services/core/notification_fetch_service.dart';
import 'package:evento_app/network_services/core/fcm_token_service.dart';

enum NotificationFilter { all, read, unread }

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type;
  final DateTime timestamp;
  final Map<String, dynamic>? payload; // original/sanitized data for actions
  bool isRead;
  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
    this.payload,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'body': body,
    'type': type,
    'timestamp': timestamp.toIso8601String(),
    'isRead': isRead,
    'payload': payload,
  };

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    DateTime parseTs(dynamic v) {
      if (v is String) {
        try {
          return DateTime.parse(v);
        } catch (_) {}
      }
      return DateTime.now();
    }

    Map<String, dynamic>? payload;
    final p = map['payload'];
    if (p is Map) {
      payload = p.map((k, v) => MapEntry(k.toString(), v));
    }

    return NotificationModel(
      id:
          map['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: map['title']?.toString() ?? 'Notification',
      body: map['body']?.toString() ?? '',
      type: map['type']?.toString() ?? 'General',
      timestamp: parseTs(map['timestamp']),
      isRead: map['isRead'] == true,
      payload: payload,
    );
  }
}

class NotificationProvider extends ChangeNotifier {
  static const String _prefsKey = 'notifications_store_v1';
  int _tabIndex = 0;
  final List<NotificationModel> _all = [];
  NotificationFilter _filter = NotificationFilter.all;
  bool _refreshing = false;

  NotificationFilter get filter => _filter;
  bool get hasUnread => _all.any((n) => !n.isRead);
  int get tabIndex => _tabIndex;
  bool get refreshing => _refreshing;
  List<NotificationModel> get notifications {
    switch (_filter) {
      case NotificationFilter.read:
        return _all.where((n) => n.isRead).toList(growable: false);
      case NotificationFilter.unread:
        return _all.where((n) => !n.isRead).toList(growable: false);
      case NotificationFilter.all:
        return List.unmodifiable(_all);
    }
  }

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null || raw.isEmpty) return;
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        _all
          ..clear()
          ..addAll(
            decoded.whereType<Map>().map(
              (m) => NotificationModel.fromMap(m.cast<String, dynamic>()),
            ),
          );
        notifyListeners();
      }
    } catch (_) {
      // ignore corrupted store
    }
    // Try to fetch existing notifications from server (best-effort, non-blocking)
    // ignore: unawaited_futures
    _syncFromServerIfPossible();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _all.map((e) => e.toMap()).toList(growable: false);
      await prefs.setString(_prefsKey, jsonEncode(list));
    } catch (_) {}
  }

  void setFilter(NotificationFilter f) {
    _filter = f;
    notifyListeners();
  }


  void setTab(int index) {
    if (_tabIndex == index) return;
    _tabIndex = index;
    notifyListeners();
  }

  Future<void> markAllAsRead() async {
    for (final n in _all) {
      n.isRead = true;
    }
    notifyListeners();
    await _persist();
  }

  Future<void> removeNotification(NotificationModel model) async {
    _all.removeWhere((n) => n.id == model.id);
    notifyListeners();
    await _persist();
  }

  void markAsRead(NotificationModel model) {
    final idx = _all.indexWhere((n) => n.id == model.id);
    if (idx == -1) return;
    if (_all[idx].isRead) return;
    _all[idx].isRead = true;
    notifyListeners();
    _persist();
  }

  void addFromRemoteData(Map<String, dynamic> data) {
    final Map<String, dynamic> payload = {};
    data.forEach((key, value) {
      payload[key.toString()] = value;
    });

    final id =
        (payload['id']?.toString() ??
        DateTime.now().millisecondsSinceEpoch.toString());
    final title =
        (payload['title'] ?? payload['button_name'] ?? payload['subject'])
            ?.toString() ??
        'Notification';
    final body =
        (payload['body'] ?? payload['message'] ?? payload['content'])
            ?.toString() ??
        '';
    final type = payload['type']?.toString() ?? 'General';

    _all.removeWhere((n) => n.id == id);
    // Skip if a very similar notification already exists (matches title/body and close timestamp)
    if (_existsSimilar(title: title, body: body, timestamp: DateTime.now())) {
      notifyListeners();
      _persist();
      return;
    }
    final n = NotificationModel(
      id: id,
      title: title,
      body: body,
      type: type,
      timestamp: DateTime.now(),
      payload: payload,
      isRead: false,
    );

    _all.insert(0, n);
    notifyListeners();
    _persist();
  }

  // ---- Dedupe helpers ----
  static String _norm(String s) => s.replaceAll(RegExp(r"\s+"), ' ').trim().toLowerCase();
  // reserved for future, helps build canonical keys if needed
  // ignore: unused_element
  static String _minuteKey(DateTime dt) =>
      '${dt.toUtc().year.toString().padLeft(4, '0')}'
      '${dt.toUtc().month.toString().padLeft(2, '0')}'
      '${dt.toUtc().day.toString().padLeft(2, '0')}'
      '${dt.toUtc().hour.toString().padLeft(2, '0')}'
      '${dt.toUtc().minute.toString().padLeft(2, '0')}';

  bool _existsSimilar({required String title, required String body, DateTime? timestamp, String? createdAt}) {
    final t = _norm(title);
    final b = _norm(body);
    DateTime? targetTs = timestamp;
    if ((targetTs == null) && createdAt != null && createdAt.trim().isNotEmpty) {
      try {
        targetTs = DateTime.parse(createdAt);
      } catch (_) {}
    }
    for (final n in _all) {
      if (_norm(n.title) != t) continue;
      if (_norm(n.body) != b) continue;
      if (targetTs == null) {
        // Titles and bodies match; consider duplicate regardless of time
        return true;
      }
      final diff = n.timestamp.difference(targetTs).inMinutes.abs();
      if (diff <= 10) return true; // treat as same within 10 minutes window
    }
    return false;
  }

  // Public trigger to re-fetch from server
  Future<void> refreshFromServer() async {
    if (_refreshing) return;
    _refreshing = true;
    notifyListeners();
    try {
      await _syncFromServerIfPossible();
    } finally {
      _refreshing = false;
      notifyListeners();
    }
  }

  Future<void> _syncFromServerIfPossible() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final customerRaw = prefs.getString('auth_customer');
      int? userId;
      if (customerRaw != null && customerRaw.isNotEmpty) {
        final c = jsonDecode(customerRaw);
        if (c is Map && c['id'] != null) {
          userId = int.tryParse(c['id'].toString());
        }
      }
      final token = FcmTokenService.token;

      // If neither userId nor token is available, skip syncing.
      if ((userId == null || userId <= 0) && (token == null || token.isEmpty)) {
        return;
      }

      final items = await NotificationFetchService.fetch(
        userId: (userId != null && userId > 0) ? userId : null,
        fcmToken: (token != null && token.isNotEmpty) ? token : null,
      );
      if (items.isEmpty) return;
      bool changed = false;
      for (final m in items) {
        final title = m['message_title']?.toString() ??
            m['title']?.toString() ??
            'Notification';
        final body = m['message_description']?.toString() ??
            m['message']?.toString() ??
            '';
        DateTime ts;
        final created = m['created_at']?.toString();
        if (created != null) {
          try {
            ts = DateTime.parse(created);
          } catch (_) {
            ts = DateTime.now();
          }
        } else {
          ts = DateTime.now();
        }
        final id = '${created ?? ''}|$title|$body';
        // Skip if same ID already exists OR similar content already present
        if (_all.any((n) => n.id == id) || _existsSimilar(title: title, body: body, timestamp: ts, createdAt: created)) {
          continue;
        }
        _all.insert(
          0,
          NotificationModel(
            id: id,
            title: title,
            body: body,
            type: 'General',
            timestamp: ts,
            payload: m.map((k, v) => MapEntry(k.toString(), v)),
            isRead: false,
          ),
        );
        changed = true;
      }
      if (changed) {
        _all.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        notifyListeners();
        await _persist();
      }
    } catch (_) {}
  }
}
