import 'dart:convert';
import 'dart:ui' show Locale;

import 'package:evento_app/app/localization/arabic.dart';
import 'package:evento_app/app/urls.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:evento_app/network_services/core/http_headers.dart';
import 'package:get/get.dart';
import 'package:evento_app/utils/net_utils.dart';

class LanguageService {
  static const _cachePrefix = 'i18n_cache_';
  static final Map<String, Map<String, String>> _maps = {};

  static Map<String, String> mapOf(String languageCode) {
    return _maps[languageCode] ?? const {};
  }

  static Future<void> ensureLoaded(String languageCode) async {
    final code = _normalize(languageCode);
    final prefs = await SharedPreferences.getInstance();

    final cached = prefs.getString('$_cachePrefix$code');
    if (cached != null && cached.isNotEmpty) {
      final map = _asStringMap(jsonDecode(cached));
      if (map.isNotEmpty) {
        _maps[code] = map;
        _injectIntoGetX(code, map);
      }
    }

    final remote = await _fetchFromNetwork(code);
    if (remote.isNotEmpty) {
      _maps[code] = remote;
      await prefs.setString('$_cachePrefix$code', jsonEncode(remote));
      _injectIntoGetX(code, remote);
    }

    if ((_maps[code] == null || _maps[code]!.isEmpty) && code == 'ar') {
      _maps[code] = Map<String, String>.from(arabic);
      _injectIntoGetX(code, _maps[code]!);
    }
  }

  static Future<Map<String, String>> _fetchFromNetwork(
    String languageCode,
  ) async {
    final uri = Uri.parse(AppUrls.getLangUrl(languageCode));
    final headers = HttpHeadersHelper.base();
    final response = await NetUtils.getWithRetry(uri, headers: headers);
    if (response.statusCode != 200) {
      return {};
    }
    try {
      return _asStringMap(jsonDecode(response.body));
    } catch (e) {
      return {};
    }
  }

  static String _normalize(String languageCode) {
    if (languageCode.isEmpty) return 'en';
    return languageCode.split('_').first.split('-').first.toLowerCase();
  }

  static void _injectIntoGetX(String code, Map<String, String> map) {
    try {
      final all = exportAll();
      Get.addTranslations(all.isNotEmpty ? all : {code: map});
      Get.updateLocale(Locale(code));
    } catch (e) {
      // Logging removed. Fallback still applies locale.
      Get.updateLocale(Locale(code));
    }
  }

  static Map<String, Map<String, String>> exportAll() => Map.from(_maps);

  static Map<String, String> _asStringMap(dynamic decoded) {
    if (decoded is! Map) return const {};
    final Map obj = decoded;
    dynamic base = obj;
    if (!(obj.isNotEmpty && obj.values.first is String)) {
      final data = obj['data'];
      final trans = obj['translations'];
      base = (data is Map)
          ? data
          : (trans is Map)
          ? trans
          : obj;
    }
    final Map<dynamic, dynamic> m = base as Map<dynamic, dynamic>;
    return m.map((k, v) => MapEntry(k.toString(), v?.toString() ?? ''));
  }
}
