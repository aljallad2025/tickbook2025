import 'dart:convert';

import 'package:evento_app/app/urls.dart';
import 'package:evento_app/network_services/core/basic/basic_branding.dart';
import 'package:evento_app/network_services/core/basic/basic_gateways.dart';
import 'package:evento_app/network_services/core/basic/basic_keys.dart';
import 'package:evento_app/network_services/core/http_headers.dart';
import 'package:evento_app/utils/net_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BasicService {
  BasicService._();

  static final ValueNotifier<int> brandingVersion =
      BasicBranding.brandingVersion;

  static Map<String, dynamic>? _cachedBasic;
  static DateTime? _fetchedAt;

  static const _cacheTtl = Duration(minutes: 10);

  static Map<String, dynamic>? _basic(Map<String, dynamic>? decoded) =>
      (decoded?['data']?['basic_data'] as Map?)?.cast<String, dynamic>();

  static Future<Map<String, dynamic>?> _fetchRemote() async {
    try {
      final uri = Uri.parse(AppUrls.basic);
      final res = await NetUtils.getWithRetry(
        uri,
        headers: HttpHeadersHelper.base(),
      );
      if (res.statusCode != 200) return null;
      final decoded = json.decode(res.body);
      if (decoded is Map<String, dynamic>) return decoded;
      return null;
    } catch (_) {
      return null;
    }
  }

  // Gateways facade
  static Future<List<Map<String, String>>> getOnlineGateways({
    bool forceReload = false,
  }) => BasicGateways.getOnlineGateways(forceReload: forceReload);

  static Future<List<Map<String, String>>> getOfflineGateways({
    bool forceReload = false,
  }) => BasicGateways.getOfflineGateways(forceReload: forceReload);

  static Future<void> _persistBrandingUrls(Map<String, dynamic> decoded) =>
      BasicBranding.persistBrandingUrls(decoded);

  // Branding facade
  static Future<void> ensureBrandingCached({bool force = false}) =>
      BasicBranding.ensureBrandingCached(force: force);

  static Future<Uint8List?> getCachedBrandingBytes(String type) =>
      BasicBranding.getCachedBrandingBytes(type);

  static Future<Map<String, dynamic>?> fetchBasic({
    bool forceReload = false,
  }) async {
    final now = DateTime.now();
    if (!forceReload &&
        _cachedBasic != null &&
        _fetchedAt != null &&
        now.difference(_fetchedAt!) < _cacheTtl) {
      return _cachedBasic;
    }
    final remote = await _fetchRemote();
    if (remote != null) {
      _cachedBasic = remote;
      _fetchedAt = now;
      await _persistBrandingUrls(remote);
      return remote;
    }
    return _cachedBasic;
  }

  static Future<String?> getCachedPrimaryColorHex() =>
      BasicBranding.getCachedPrimaryColorHex();

  // Removed unused getBrandingUrl()

  static Future<String> getBaseCurrencyText({
    bool allowRemote = true,
    bool forceReload = false,
  }) async {
    if (forceReload) {
      try {
        final decoded = await fetchBasic(forceReload: true);
        final data = _basic(decoded);
        final s = data?['base_currency_text']?.toString();
        if (s != null && s.trim().isNotEmpty) {
          try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('base_currency_text', s.trim());
          } catch (_) {}
          return s.trim();
        }
      } catch (_) {}
    }
    try {
      final fromMem = _basic(_cachedBasic)?['base_currency_text']?.toString();
      if (fromMem != null && fromMem.trim().isNotEmpty) return fromMem.trim();
    } catch (_) {}
    try {
      final prefs = await SharedPreferences.getInstance();
      final s = prefs.getString('base_currency_text');
      if (s != null && s.trim().isNotEmpty) return s.trim();
    } catch (_) {}
    if (allowRemote) {
      try {
        final decoded = await fetchBasic();
        final data = _basic(decoded);
        final s = data?['base_currency_text']?.toString();
        if (s != null && s.trim().isNotEmpty) {
          try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('base_currency_text', s.trim());
          } catch (_) {}
          return s.trim();
        }
      } catch (_) {}
    }
    return 'USD';
  }

  // Keys facade
  static Future<String?> getStripePublishableKey() =>
      BasicKeys.getStripePublishableKey();

  static Future<String?> getRazorpayKey() => BasicKeys.getRazorpayKey();

  static Future<double> getGoogleMapRadiusKm({
    bool allowRemote = true,
    bool forceReload = false,
  }) async {
    double? parseMetersToKm(dynamic v) {
      try {
        if (v == null) return null;
        final s = v.toString().trim();
        if (s.isEmpty) return null;
        final meters = double.tryParse(s);
        if (meters == null) return null;
        return (meters / 1000.0);
      } catch (_) {
        return null;
      }
    }

    if (forceReload) {
      try {
        final decoded = await fetchBasic(forceReload: true);
        final km = parseMetersToKm(_basic(decoded)?['google_map_radius']);
        if (km != null && km > 0) {
          try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('google_map_radius', (km * 1000).toString());
          } catch (_) {}
          return km;
        }
      } catch (_) {}
    }

    try {
      final km = parseMetersToKm(_basic(_cachedBasic)?['google_map_radius']);
      if (km != null && km > 0) return km;
    } catch (_) {}

    try {
      final prefs = await SharedPreferences.getInstance();
      final metersStr = prefs.getString('google_map_radius');
      final km = parseMetersToKm(metersStr);
      if (km != null && km > 0) return km;
    } catch (_) {}

    if (allowRemote) {
      try {
        final decoded = await fetchBasic();
        final km = parseMetersToKm(_basic(decoded)?['google_map_radius']);
        if (km != null && km > 0) {
          try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('google_map_radius', (km * 1000).toString());
          } catch (_) {}
          return km;
        }
      } catch (_) {}
    }

    return 100.0;
  }
}
