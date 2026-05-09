import 'dart:convert';
import 'package:evento_app/app/urls.dart';
import 'package:evento_app/features/organizers/data/models/organizer_details_model.dart';
import 'package:evento_app/network_services/core/http_errors.dart';
import 'package:http/http.dart' as http;
import 'package:evento_app/utils/net_utils.dart';

class OrganizerDetailsService {
  static Future<OrganizerDetailsPageModel> fetch({
    required String token,
    required int id,
    required bool isAdmin,
  }) async {
    http.Response response;
    try {
      final uri = Uri.parse(AppUrls.organizerDetails(id, isAdmin: isAdmin));
      response = await NetUtils.getWithRetry(
        uri,
        headers: {
          'Accept': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );
    } catch (e) {
      throw Exception('Network error: $e');
    }
    if (response.statusCode == 401 ||
        response.statusCode == 419 ||
        response.statusCode == 403) {
      throw const AuthRequiredException('Session expired. Please login again.');
    }
    if (response.statusCode != 200) {
      throw Exception('Server responded ${response.statusCode}');
    }
    try {
      final decoded = json.decode(response.body) as Map<String, dynamic>;
      return OrganizerDetailsPageModel.fromRoot(decoded);
    } catch (e) {
      throw Exception('Failed to parse organizer details: $e');
    }
  }
}
