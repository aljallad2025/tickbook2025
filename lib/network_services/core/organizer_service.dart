import 'dart:convert';

import 'package:evento_app/app/urls.dart';
import 'package:evento_app/features/organizers/data/models/organizer_model.dart';
import 'package:evento_app/network_services/core/http_headers.dart';
import 'package:evento_app/utils/net_utils.dart';

class OrganizerService {
  Future<List<OrganizersModel>> getOrganizers({String? languageCode}) async {
    final headers = HttpHeadersHelper.base();
    if (languageCode != null && languageCode.trim().isNotEmpty) {
      headers['Accept-Language'] = languageCode.trim();
    }

    final res = await NetUtils.getWithRetry(
      Uri.parse(AppUrls.organizers),
      headers: headers,
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to load organizers: ${res.statusCode}');
    }

    dynamic decoded;
    try {
      decoded = json.decode(res.body);
    } catch (e) {
      throw Exception('Invalid organizers JSON: $e');
    }

    if (decoded is Map<String, dynamic>) {
      final data = decoded['data'];
      final container = (data is Map<String, dynamic>) ? data : decoded;
      final list = container['organizers'] ?? container['items'] ?? container['list'];
      if (list is List) {
        return list
            .whereType<Map<String, dynamic>>()
            .map(OrganizersModel.fromJson)
            .toList();
      }
      return const <OrganizersModel>[];
    }

    return const <OrganizersModel>[];
  }
}
