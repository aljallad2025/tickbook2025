import 'dart:convert';

import 'package:evento_app/app/urls.dart';
import 'package:evento_app/features/events/data/models/event_details_models.dart';
import 'package:evento_app/network_services/core/http_headers.dart';
import 'package:evento_app/utils/net_utils.dart';

class EventDetailsService {
  static Future<EventDetailsPageModel> fetchDetails({
    required int eventId,
    String? languageCode,
  }) async {
    final uri = Uri.parse(AppUrls.eventDetails(eventId));
    final headers = HttpHeadersHelper.base();
    if (languageCode != null) headers['Accept-Language'] = languageCode;
    final response = await NetUtils.getWithRetry(
      uri,
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to load event details: ${response.statusCode}');
    }
    final decoded = json.decode(response.body);
    
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid response format');
    }
    return EventDetailsPageModel.fromJson(decoded);
  }
}
