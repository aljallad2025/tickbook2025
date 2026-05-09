import 'dart:convert';
import 'package:evento_app/app/urls.dart';
import 'package:evento_app/network_services/core/http_errors.dart';
import 'package:http/http.dart' as http;
import 'package:evento_app/network_services/core/http_headers.dart';

class SupportTicketStoreService {
  static Future<Map<String, dynamic>> create({
    required String token,
    required String subject,
    required String email,
    required String description,
    String? attachmentPath,
    String? attachmentFileName,
    List<int>? attachmentBytes,
  }) async {
    http.Response response;
    try {
      final uri = Uri.parse(AppUrls.supportTicketStore);
      final req = http.MultipartRequest('POST', uri);
      req.headers.addAll({
        ...HttpHeadersHelper.base(),
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      });
      req.fields['subject'] = subject;
      req.fields['email'] = email;
      req.fields['description'] = description;
      if (attachmentBytes != null && (attachmentFileName ?? '').isNotEmpty) {
        req.files.add(
          http.MultipartFile.fromBytes(
            'attachment',
            attachmentBytes,
            filename: attachmentFileName,
          ),
        );
      } else if (attachmentPath != null && attachmentPath.isNotEmpty) {
        req.files.add(
          await http.MultipartFile.fromPath(
            'attachment',
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
    final decoded = json.decode(response.body) as Map<String, dynamic>;
    return decoded;
  }
}
