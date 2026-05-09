import 'dart:convert';
import 'package:evento_app/app/urls.dart';
import 'package:evento_app/features/events/data/models/location_models.dart';
import 'package:evento_app/network_services/core/http_headers.dart';
import 'package:evento_app/utils/net_utils.dart';

class LocationFilterService {
  static Future<(List<CountryItem>, List<StateItem>, List<CityItem>)> fetch({
    String? languageCode,
  }) async {
    final uri = Uri.parse(AppUrls.events);
    final headers = HttpHeadersHelper.base();
    if (languageCode != null && languageCode.trim().isNotEmpty) {
      headers['Accept-Language'] = languageCode.trim();
    }
    final res = await NetUtils.getWithRetry(uri, headers: headers);
    if (res.statusCode != 200) {
      return (const <CountryItem>[], const <StateItem>[], const <CityItem>[]);
    }
    try {
      final decoded = json.decode(res.body);
      final data = (decoded is Map && decoded['data'] is Map)
          ? Map<String, dynamic>.from(decoded['data'] as Map)
          : (decoded is Map
                ? decoded.cast<String, dynamic>()
                : const <String, dynamic>{});
      final countries = (data['countries'] is List)
          ? (data['countries'] as List)
                .whereType<Map>()
                .map((m) => CountryItem.fromJson(m.cast<String, dynamic>()))
                .toList()
          : const <CountryItem>[];
      final states = (data['states'] is List)
          ? (data['states'] as List)
                .whereType<Map>()
                .map((m) => StateItem.fromJson(m.cast<String, dynamic>()))
                .toList()
          : const <StateItem>[];
      final cities = (data['cities'] is List)
          ? (data['cities'] as List)
                .whereType<Map>()
                .map((m) => CityItem.fromJson(m.cast<String, dynamic>()))
                .toList()
          : const <CityItem>[];
      return (countries, states, cities);
    } catch (_) {
      return (const <CountryItem>[], const <StateItem>[], const <CityItem>[]);
    }
  }
}
