import 'dart:convert';
import 'package:evento_app/app/urls.dart';
import 'package:http/http.dart' as http;
import 'package:evento_app/network_services/core/http_headers.dart';

class PasswordService {
  static Future<Map<String, dynamic>> updatePassword(
    String token,
    Map<String, String> fields,
  ) async {
    final uri = Uri.parse(AppUrls.updatePassword);
    final req = http.MultipartRequest('POST', uri);
  req.headers.addAll(HttpHeadersHelper.base());
    if (token.isNotEmpty) req.headers['Authorization'] = 'Bearer $token';
    fields.forEach((k, v) => req.fields[k] = v);
    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return json.decode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to update password: ${res.statusCode} ${res.body}');
  }
}
