import 'dart:convert';
import 'package:evento_app/app/urls.dart';
import 'package:evento_app/features/support/data/models/support_ticket_details_models.dart';
import 'package:evento_app/network_services/core/http_errors.dart';
import 'package:http/http.dart' as http;
import 'package:evento_app/utils/net_utils.dart';
import 'package:evento_app/network_services/core/http_headers.dart';

class SupportTicketDetailsService {
  static Future<TicketDetailsResponse> fetch({
    required String token,
    required int ticketId,
  }) async {
    http.Response response;
    try {
      final uri = Uri.parse(AppUrls.supportTicketDetails(ticketId));
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
    final decoded = json.decode(response.body) as Map<String, dynamic>;
    return TicketDetailsResponse.fromJson(decoded);
  }

  static Future<Map<String, dynamic>> reply({
    required String token,
    required int ticketId,
    String? message,
    List<int>? attachmentBytes,
    String? attachmentFileName,
    String? attachmentPath,
  }) async {
    http.Response response;
    try {
      final uri = Uri.parse(AppUrls.supportTicketReply);
      final req = http.MultipartRequest('POST', uri);
      req.headers.addAll({
        ...HttpHeadersHelper.base(),
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      });
      req.fields['ticket_id'] = ticketId.toString();
      if ((message ?? '').isNotEmpty) req.fields['reply'] = message!.trim();
      if (attachmentBytes != null && (attachmentFileName ?? '').isNotEmpty) {
        req.files.add(
          http.MultipartFile.fromBytes(
            'file',
            attachmentBytes,
            filename: attachmentFileName,
          ),
        );
      } else if (attachmentPath != null && attachmentPath.isNotEmpty) {
        req.files.add(
          await http.MultipartFile.fromPath(
            'file',
            attachmentPath,
            filename: attachmentFileName,
          ),
        );
      }
      final streamed = await req.send();
      response = await http.Response.fromStream(streamed);
    } catch (e) {
      throw Exception('Network error: $e');
    }
    if (response.statusCode == 401 ||
        response.statusCode == 419 ||
        response.statusCode == 403) {
      throw const AuthRequiredException('Session expired. Please login again.');
    }
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Server responded ${response.statusCode}');
    }
    return json.decode(response.body) as Map<String, dynamic>;
  }
}
