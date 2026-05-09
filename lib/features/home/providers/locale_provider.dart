import 'dart:ui' show Locale;

import 'package:evento_app/network_services/core/http_headers.dart';
import 'package:evento_app/network_services/core/language_service.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:evento_app/network_services/core/language_list_service.dart';

class LanguageItem {
  final String name;
  final String code;
  const LanguageItem(this.name, this.code);
}

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');
  List<LanguageItem> _languages = const [
    LanguageItem('English', 'en'),
    LanguageItem('Arabic', 'ar'),
  ];

  Locale get locale => _locale;
  List<LanguageItem> get languages => _languages;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('app_locale') ?? 'en';
    _fetchLanguages();
    await setLocale(Locale(saved));
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    HttpHeadersHelper.setLanguage(locale.languageCode);
    await LanguageService.ensureLoaded(locale.languageCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_locale', locale.languageCode);
    notifyListeners();
  }

  Future<void> _fetchLanguages() async {
    try {
      final list = await LanguageListService.fetch();
      if (list.isEmpty) return;
      final mapped = list
          .map(
            (e) => LanguageItem(
              e.name.isNotEmpty ? e.name : e.code.toUpperCase(),
              e.code,
            ),
          )
          .toList(growable: false);
      _languages = mapped;
      notifyListeners();
    } catch (_) {
      // Intentionally ignore; language list is optional.
    }
  }
}
