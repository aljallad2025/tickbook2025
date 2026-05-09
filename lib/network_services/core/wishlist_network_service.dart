import 'dart:convert';
import 'package:evento_app/app/urls.dart';
import 'package:evento_app/features/wishlist/data/models/wishlist_model.dart';
import 'package:evento_app/network_services/core/http_errors.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:evento_app/utils/net_utils.dart';
import 'package:evento_app/network_services/core/http_headers.dart';

class WishlistNetworkService {
  static Future<WishlistPageModel> fetch(String token) async {
    http.Response response;
    try {
      response = await NetUtils.getWithRetry(
        Uri.parse(AppUrls.wishlists),
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
      throw AuthRequiredException('Session expired. Please login again.'.tr);
    }
    if (response.statusCode != 200) {
      throw Exception(
        'Server responded ${response.statusCode}: ${response.body}',
      );
    }

    Map<String, dynamic> decoded;
    try {
      decoded = json.decode(response.body) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Invalid JSON: $e');
    }

    final data = decoded['data'];
    if (data is! Map<String, dynamic>) {
      return const WishlistPageModel(pageTitle: '', wishlists: []);
    }
    final title = (data['page_title'] ?? '').toString();
    final listRaw = data['wishlists'];
    final items = (listRaw is List)
        ? listRaw
              .whereType<Map<String, dynamic>>()
              .map(Wishlists.fromJson)
              .toList()
        : <Wishlists>[];
    return WishlistPageModel(pageTitle: title, wishlists: items);
  }

  static Future<Map<String, dynamic>> add({
    required String token,
    required int eventId,
    required int customerId,
  }) async {
    http.Response response;
    try {
      final request =
          http.MultipartRequest('POST', Uri.parse(AppUrls.wishlistsStore))
            ..headers.addAll({
              ...HttpHeadersHelper.base(),
              if (token.isNotEmpty) 'Authorization': 'Bearer $token',
            })
            ..fields.addAll({
              'event_id': eventId.toString(),
              'customer_id': customerId.toString(),
            });
      final streamed = await request.send();
      response = await http.Response.fromStream(streamed);
    } catch (e) {
      throw Exception('Network error: $e');
    }
    if (response.statusCode == 401 ||
        response.statusCode == 419 ||
        response.statusCode == 403) {
      throw AuthRequiredException('Session expired. Please login again.'.tr);
    }
    if (response.statusCode != 200) {
      throw Exception(
        'Server responded ${response.statusCode}: ${response.body}',
      );
    }
    try {
      final decoded = json.decode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      return {'success': true};
    } catch (_) {
      return {'success': true};
    }
  }

  static Future<Map<String, dynamic>> delete({
    required String token,
    required int wishlistId,
    int? eventId,
  }) async {
    http.Response response;
    try {
      final request =
          http.MultipartRequest('POST', Uri.parse(AppUrls.wishlistsDelete))
            ..headers.addAll({
              ...HttpHeadersHelper.base(),
              if (token.isNotEmpty) 'Authorization': 'Bearer $token',
            })
            ..fields.addAll({
              'id': wishlistId.toString(),
              if (eventId != null) 'event_id': eventId.toString(),
            });
      final streamed = await request.send();
      response = await http.Response.fromStream(streamed);
    } catch (e) {
      throw Exception('Network error: $e');
    }
    if (response.statusCode == 401 ||
        response.statusCode == 419 ||
        response.statusCode == 403) {
      throw const AuthRequiredException('Session expired. Please login again.');
    }
    if (response.statusCode != 200) {
      throw Exception(
        'Server responded ${response.statusCode}: ${response.body}',
      );
    }
    try {
      final decoded = json.decode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      return {'success': true};
    } catch (_) {
      return {'success': true};
    }
  }
}
