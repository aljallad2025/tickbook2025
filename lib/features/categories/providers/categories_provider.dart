import 'package:evento_app/features/categories/models/category_model.dart';
import 'package:evento_app/network_services/core/http_headers.dart';
import 'package:evento_app/app/urls.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CategoriesProvider extends ChangeNotifier {
  bool _loading = false;
  String? _error;
  List<CategoryModel> _items = const [];
  bool _initialized = false;

  bool get loading => _loading;
  String? get error => _error;
  bool get initialized => _initialized;
  List<CategoryModel> get items => List.unmodifiable(_items);

  Future<void> ensureInitialized({String? languageCode}) async {
    if (_initialized) return;
    await fetch(languageCode: languageCode);
  }

  Future<void> fetch({String? languageCode}) async {
    if (_loading) return;
    _setLoading(true);
    _error = null;
    try {
      final uri = Uri.parse('${AppUrls.events}/categories');
      final headers = HttpHeadersHelper.base();
      if (languageCode != null) headers['Accept-Language'] = languageCode;
      final res = await http.get(uri, headers: headers);
      if (res.statusCode != 200) {
        throw Exception('HTTP ${res.statusCode}');
      }
      final decoded = json.decode(res.body);
      List<CategoryModel> parsed = const [];
      if (decoded is Map<String, dynamic>) {
        final data = decoded['data'];
        final cats = (data is Map<String, dynamic>)
            ? data['categories']
            : (decoded['categories'] ?? data);
        if (cats is List) {
          parsed = cats
              .whereType<Map<String, dynamic>>()
              .map(CategoryModel.fromJson)
              .toList();
        }
      }
      _items = parsed;
      _initialized = true;
    } catch (e) {
      _items = const [];
      _initialized = true;
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refresh({String? languageCode}) async {
    await fetch(languageCode: languageCode);
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }
}
