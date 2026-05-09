import 'dart:convert';
import 'package:evento_app/app/urls.dart';
import 'package:evento_app/features/events/data/models/event_item_model.dart';
import 'package:evento_app/network_services/core/http_headers.dart';
import 'package:evento_app/utils/net_utils.dart';

class EventsFetchResult {
  final List<EventItemModel> items;
  final String? currencySymbol;
  final String? currencySymbolPosition;
  final String? currencyText;
  const EventsFetchResult({
    required this.items,
    this.currencySymbol,
    this.currencySymbolPosition,
    this.currencyText,
  });
}

class EventsServices {
  static Future<EventsFetchResult> fetchEvents({
    int? page,
    int? perPage,
    String? languageCode,
    // Optional filters
    String? categoryName,
    int? categoryId,
    String? categorySlug,
    String? keyword,
    String? country,
    String? state,
    String? city,
    String? date,
    String? from,
    String? to,
    String? eventType,
    double? minPrice,
    double? maxPrice,
    double? centerLat,
    double? centerLon,
    double? radiusKm,
  }) async {
    final base = Uri.parse(AppUrls.events);
    final params = <String, String>{};
    if (page != null) params['page'] = '$page';
    if (perPage != null) params['per_page'] = '$perPage';
    // Be generous with API parameter names to match various backends
    if (categorySlug != null && categorySlug.trim().isNotEmpty) {
      params['category'] = categorySlug;
      params['category_slug'] = categorySlug;
    }
    if (categoryId != null) {
      params['category_id'] = '$categoryId';
      params['event_category_id'] = '$categoryId';
    }
    if (categoryName != null && categoryName.trim().isNotEmpty) {
      params['category_name'] = categoryName;
    }
    if (keyword != null && keyword.trim().isNotEmpty) {
      params['keyword'] = keyword;
      params['search'] = keyword;
      params['q'] = keyword;
    }
    if (country != null && country.trim().isNotEmpty) {
      params['country'] = country;
    }
    if (state != null && state.trim().isNotEmpty) params['state'] = state;
    if (city != null && city.trim().isNotEmpty) params['city'] = city;
    if (date != null && date.trim().isNotEmpty) params['date'] = date;
    if (from != null && from.trim().isNotEmpty) params['from'] = from;
    if (to != null && to.trim().isNotEmpty) params['to'] = to;
    if (eventType != null && eventType.trim().isNotEmpty) {
      params['event_type'] = eventType;
    }
    if (minPrice != null) {
      final v = minPrice.toString();
      params['min'] = v;
      params['min_price'] = v;
      params['price_min'] = v;
    }
    if (maxPrice != null) {
      final v = maxPrice.toString();
      params['max'] = v;
      params['max_price'] = v;
      params['price_max'] = v;
    }
    if (centerLat != null && centerLon != null) {
      params['center_lat'] = centerLat.toString();
      params['center_lon'] = centerLon.toString();
    }
    if (radiusKm != null) {
      params['radius_km'] = radiusKm.toString();
      params['radius'] = radiusKm.toString();
    }

    final uri = params.isEmpty ? base : base.replace(queryParameters: params);
    final headers = HttpHeadersHelper.base();
    if (languageCode != null) headers['Accept-Language'] = languageCode;
    final response = await NetUtils.getWithRetry(
      uri,
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to load events: ${response.statusCode}');
    }
    final decoded = json.decode(response.body);

    if (decoded is Map<String, dynamic>) {
      dynamic container = decoded['data'];
      container ??= decoded;

      String? symbol;
      String? symbolPos;
      String? currencyText;
      if (container is Map<String, dynamic>) {
        final map = container;
        symbol = (map['base_currency_symbol'] ?? map['currency_symbol'])
            ?.toString();
        symbolPos =
            (map['base_currency_symbol_position'] ??
                    map['currency_symbol_position'])
                ?.toString();
        currencyText = (map['base_currency_text'] ?? map['currency_text'])
            ?.toString();

        final dynamic events = map['events'];
        if (events is List) {
          return EventsFetchResult(
            items: events
                .whereType<Map<String, dynamic>>()
                .map(EventItemModel.fromJson)
                .toList(),
            currencySymbol: symbol,
            currencySymbolPosition: symbolPos,
            currencyText: currencyText,
          );
        }
        if (events is Map<String, dynamic>) {
          final dynamic list =
              events['data'] ?? events['list'] ?? events['items'];
          if (list is List) {
            return EventsFetchResult(
              items: list
                  .whereType<Map<String, dynamic>>()
                  .map(EventItemModel.fromJson)
                  .toList(),
              currencySymbol: symbol,
              currencySymbolPosition: symbolPos,
              currencyText: currencyText,
            );
          }
        }
      }
      return EventsFetchResult(
        items: const <EventItemModel>[],
        currencySymbol: symbol,
        currencySymbolPosition: symbolPos,
        currencyText: currencyText,
      );
    }
    return const EventsFetchResult(items: <EventItemModel>[]);
  }
}
