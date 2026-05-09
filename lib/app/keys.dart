import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:evento_app/app/urls.dart';
import 'package:evento_app/network_services/core/http_headers.dart';
import 'package:evento_app/utils/net_utils.dart';

class AppKeys {
  // Compile-time/env fallbacks
  static const _embeddedGoogleMaps = '';
  static const _embedStripeKey = '';

  // Google Maps key (no API-provided example yet). Keep env fallback.
  static final googleMaps = const String.fromEnvironment(
    'GOOGLE_API_KEY',
    defaultValue: _embeddedGoogleMaps,
  ).trim();

  // Stripe publishable key fallback (env); prefer async getter below for API-provided key
  static final stripePublishableKey = const String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue: _embedStripeKey,
  ).trim();

  // Razorpay public key fallback (env); prefer async getter below for API-provided key
  static final razorpayKey = const String.fromEnvironment(
    'RAZORPAY_KEY',
    defaultValue: '',
  ).trim();

  // Async getters that use values persisted by BasicService from the get-basic API
  static Future<String?> getStripePublishableKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final v = prefs.getString('stripe_public_key');
      if (v != null && v.trim().isNotEmpty) return v.trim();
    } catch (_) {}
    return stripePublishableKey.isNotEmpty ? stripePublishableKey : null;
  }

  static Future<String?> getRazorpayKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final v = prefs.getString('razorpay_key');
      if (v != null && v.trim().isNotEmpty) return v.trim();
    } catch (_) {}
    return razorpayKey.isNotEmpty ? razorpayKey : null;
  }

  static Future<String?> getGoogleMapKey() async {
    SharedPreferences? prefs;
    try {
      prefs = await SharedPreferences.getInstance();
      final status = prefs.getString('app_google_map_status');
      if (status != null && status.trim() != '1') {
        return null;
      }
      final v = prefs.getString('google_map_api_key');
      if (status == '1' && v != null && v.trim().isNotEmpty) {
        return v.trim();
      }
    } catch (_) {}
    // Remote fallback: fetch status + key from basic API and persist
    try {
      final res = await NetUtils.getWithRetry(
        Uri.parse(AppUrls.basic),
        headers: HttpHeadersHelper.base(),
      );
      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        if (decoded is Map<String, dynamic>) {
          final data = decoded['data'];
          Map<String, dynamic> basic = const {};
          if (data is Map) {
            try {
              basic = Map<String, dynamic>.from(data['basic_data'] ?? const {});
            } catch (_) {
              final m = data['basic_data'];
              if (m is Map) basic = m.cast<String, dynamic>();
            }
          }
          final status =
              (basic['app_google_map_status'] ?? data?['app_google_map_status'])
                  ?.toString()
                  .trim();
          final key =
              (basic['google_map_api_key'] ?? data?['google_map_api_key'])
                  ?.toString()
                  .trim();
          try {
            prefs ??= await SharedPreferences.getInstance();
            if (status != null) {
              await prefs.setString('app_google_map_status', status);
            }
            if (key != null && key.isNotEmpty) {
              await prefs.setString('google_map_api_key', key);
            }
          } catch (_) {}

          if (status == '1' && key != null && key.isNotEmpty) {
            return key;
          }
          if (status != null && status != '1') {
            return null;
          }
        }
      }
    } catch (_) {}

    return googleMaps.isNotEmpty ? googleMaps : null;
  }

  static Future<bool> isGoogleMapEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final status = prefs.getString('app_google_map_status');
      if (status != null) return status.trim() == '1';
    } catch (_) {}

    try {
      final res = await NetUtils.getWithRetry(
        Uri.parse(AppUrls.basic),
        headers: HttpHeadersHelper.base(),
      );
      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        if (decoded is Map<String, dynamic>) {
          final data = decoded['data'];
          Map<String, dynamic> basic = const {};
          if (data is Map) {
            try {
              basic = Map<String, dynamic>.from(data['basic_data'] ?? const {});
            } catch (_) {
              final m = data['basic_data'];
              if (m is Map) basic = m.cast<String, dynamic>();
            }
          }
          final status =
              (basic['app_google_map_status'] ?? data?['app_google_map_status'])
                  ?.toString()
                  .trim();
          if (status != null) return status == '1';
        }
      }
    } catch (_) {}
    return googleMaps.isNotEmpty;
  }
}
