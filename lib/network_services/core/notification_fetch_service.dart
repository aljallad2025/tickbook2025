import 'dart:convert';
import 'package:evento_app/app/urls.dart';
import 'package:evento_app/network_services/core/http_headers.dart';
import 'package:http/http.dart' as http;

class NotificationFetchService {
  static Future<List<Map<String, dynamic>>> fetch({
    int? userId,
    String? fcmToken,
  }) async {
    final qp = <String, String>{};
    if (userId != null && userId > 0) qp['user_id'] = userId.toString();
    if (fcmToken != null && fcmToken.trim().isNotEmpty) {
      qp['fcm_token'] = fcmToken.trim();
    }
    if (qp.isEmpty) return const [];

    final uri = Uri.parse(
      AppUrls.getNotifications,
    ).replace(queryParameters: qp);
    final headers = HttpHeadersHelper.base();
    final res = await http.get(uri, headers: headers);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      return const [];
    }
    try {
      final decoded = json.decode(res.body);
      if (decoded is Map && decoded['status'] == 'success') {
        final list = decoded['notifications'];
        if (list is List) {
          return list
              .whereType<Map>()
              .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
              .toList(growable: false);
        }
      }
    } catch (e) {
      assert(() { return true; }());
    }
    return const [];
  }
}
