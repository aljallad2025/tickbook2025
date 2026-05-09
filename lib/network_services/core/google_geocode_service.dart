import 'dart:convert';
import 'package:latlong2/latlong.dart' as ll;
import 'package:evento_app/utils/net_utils.dart';

class GoogleGeocodeService {
  GoogleGeocodeService(this.apiKey);
  final String apiKey;

  bool get enabled => apiKey.trim().isNotEmpty;

  Future<GeocodeResult?> reverse(double lat, double lon) async {
    if (!enabled) return null;
    final uri = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lon&key=$apiKey',
    );
    final res = await NetUtils.getWithRetry(uri);
    if (res.statusCode != 200) return null;
    final data = json.decode(res.body);
    if (data['status'] != 'OK') return null;
    final results = (data['results'] as List);
    if (results.isEmpty) return null;
    // Prefer ROOFTOP result
    results.sort((a, b) {
      String tA = (a['geometry']['location_type'] ?? '') as String;
      String tB = (b['geometry']['location_type'] ?? '') as String;
      int score(String t) => t == 'ROOFTOP'
          ? 3
          : t == 'RANGE_INTERPOLATED'
          ? 2
          : 1;
      return score(tB).compareTo(score(tA));
    });
    return GeocodeResult.fromJson(results.first);
  }

  Future<GeocodeResult?> forward(String address) async {
    if (!enabled || address.trim().isEmpty) return null;
    final uri = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeQueryComponent(address)}&key=$apiKey',
    );
    final res = await NetUtils.getWithRetry(uri);
    if (res.statusCode != 200) return null;
    final data = json.decode(res.body);
    if (data['status'] != 'OK') return null;
    final results = (data['results'] as List);
    if (results.isEmpty) return null;
    return GeocodeResult.fromJson(results.first);
  }
}

class GeocodeResult {
  GeocodeResult({
    required this.formattedAddress,
    required this.lat,
    required this.lon,
    required this.locationType,
  });
  final String formattedAddress;
  final double lat;
  final double lon;
  final String locationType;

  ll.LatLng get point => ll.LatLng(lat, lon);

  factory GeocodeResult.fromJson(Map<String, dynamic> json) {
    final loc = json['geometry']['location'] as Map<String, dynamic>;
    return GeocodeResult(
      formattedAddress: json['formatted_address'] ?? '',
      lat: (loc['lat'] as num).toDouble(),
      lon: (loc['lng'] as num).toDouble(),
      locationType: json['geometry']['location_type'] ?? '',
    );
  }
}
