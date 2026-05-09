import 'dart:convert';

import 'package:evento_app/network_services/core/http_headers.dart';
import 'package:evento_app/utils/net_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BasicBranding {
  BasicBranding._();

  static final ValueNotifier<int> brandingVersion = ValueNotifier<int>(0);

  static Map<String, String> _keys(String type) {
    final isFav = type == 'favicon';
    return {
      'json': isFav ? 'mobile_favicon' : 'mobile_app_logo',
      'url': isFav ? 'mobile_favicon_url' : 'mobile_app_logo_url',
      'b64': isFav ? 'mobile_favicon_b64' : 'mobile_app_logo_b64',
    };
  }

  static Future<void> persistBrandingUrls(Map<String, dynamic> decoded) async {
    try {
      final data = (decoded['data']?['basic_data'] as Map?)
          ?.cast<String, dynamic>();
      final rootData = (decoded['data'] is Map)
          ? Map<String, dynamic>.from(decoded['data'] as Map)
          : const <String, dynamic>{};
      if (data == null && rootData.isEmpty) return;
      final prefs = await SharedPreferences.getInstance();
      final logo = data?['mobile_app_logo']?.toString();
      final fav = data?['mobile_favicon']?.toString();
      final primary = data?['mobile_primary_colour']?.toString();
      final baseCurrencyText = data?['base_currency_text']?.toString();
      final stripePk = rootData['stripe_public_key']?.toString();
      final razorpayInfo = (rootData['razorpayInfo'] is Map)
          ? Map<String, dynamic>.from(rootData['razorpayInfo'] as Map)
          : const <String, dynamic>{};
      final razorKey = (razorpayInfo['key'] ?? razorpayInfo['public_key'])
          ?.toString();
      final googleMapStatus =
          (data?['app_google_map_status'] ?? rootData['app_google_map_status'])
              ?.toString();
      final googleMapKey =
          (data?['google_map_api_key'] ?? rootData['google_map_api_key'])
              ?.toString();
      if (logo != null && logo.isNotEmpty) {
        await prefs.setString('mobile_app_logo_url', logo);
      }
      if (fav != null && fav.isNotEmpty) {
        await prefs.setString('mobile_favicon_url', fav);
      }
      if (primary != null && primary.isNotEmpty) {
        await prefs.setString('mobile_primary_colour', primary);
      }
      if (baseCurrencyText != null && baseCurrencyText.isNotEmpty) {
        await prefs.setString('base_currency_text', baseCurrencyText);
      }
      if (stripePk != null && stripePk.isNotEmpty) {
        await prefs.setString('stripe_public_key', stripePk);
      }
      if (razorKey != null && razorKey.isNotEmpty) {
        await prefs.setString('razorpay_key', razorKey);
      }
      if (googleMapStatus != null) {
        await prefs.setString('app_google_map_status', googleMapStatus);
      }
      if (googleMapKey != null && googleMapKey.isNotEmpty) {
        await prefs.setString('google_map_api_key', googleMapKey);
      }
    } catch (_) {}
  }

  static Future<Uint8List?> downloadBytes(String url) async {
    try {
      final res = await NetUtils.getWithRetry(
        Uri.parse(url),
        headers: HttpHeadersHelper.base(),
      );
      if (res.statusCode == 200 && res.bodyBytes.isNotEmpty) {
        return res.bodyBytes;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<void> persistBrandingBytes({
    required String type,
    required Uint8List bytes,
    required String url,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final k = _keys(type);
      await prefs.setString(k['b64']!, base64Encode(bytes));
      await prefs.setString(k['url']!, url);
      // Track which URL these bytes correspond to; enables change detection.
      await prefs.setString('${k['url']!}_cached', url);
    } catch (_) {}
    try {
      brandingVersion.value++;
    } catch (_) {}
  }

  static Future<void> ensureBrandingCached({bool force = false}) async {
    // Caller should pass decoded basic map; we read from persisted store if exists
    try {
      final prefs = await SharedPreferences.getInstance();
      // No-op if we don't yet know URLs and not forcing
      // Actual URLs are persisted via persistBrandingUrls() during fetchBasic()
      for (final type in const ['logo', 'favicon']) {
        final k = _keys(type);
        final currentUrl = prefs.getString(k['url']!) ?? '';
        final cachedForUrl = prefs.getString('${k['url']!}_cached') ?? '';
        final storedB64 = prefs.getString(k['b64']!);
        final needsDownload =
            force ||
            (storedB64 == null || storedB64.isEmpty) ||
            (currentUrl.isNotEmpty && currentUrl != cachedForUrl);
        if (needsDownload && currentUrl.isNotEmpty) {
          final bytes = await downloadBytes(currentUrl);
          if (bytes != null && bytes.isNotEmpty) {
            await persistBrandingBytes(
              type: type,
              bytes: bytes,
              url: currentUrl,
            );
          }
        }
      }
    } catch (_) {}
  }

  static Future<Uint8List?> getCachedBrandingBytes(String type) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _keys(type)['b64']!;
      final b64 = prefs.getString(key);
      if (b64 == null || b64.isEmpty) return null;
      return base64Decode(b64);
    } catch (_) {
      return null;
    }
  }

  static Future<String?> getCachedPrimaryColorHex() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hex = prefs.getString('mobile_primary_colour');
      if (hex == null || hex.isEmpty) return null;
      return hex;
    } catch (_) {
      return null;
    }
  }
}
