import 'dart:convert';
import 'package:evento_app/app/urls.dart';
import 'package:evento_app/network_services/core/http_headers.dart';
import 'package:http/http.dart' as http;

class LanguageInfo {
  final int id;
  final String name;
  final String code;
  final bool rtl;
  final bool isDefault;

  const LanguageInfo({
    required this.id,
    required this.name,
    required this.code,
    required this.rtl,
    required this.isDefault,
  });

  factory LanguageInfo.fromJson(Map<String, dynamic> json) {
    return LanguageInfo(
      id: (json['id'] is int)
          ? json['id'] as int
          : int.tryParse('${json['id']}') ?? 0,
      name: (json['name'] ?? '').toString(),
      code: (json['code'] ?? '').toString(),
      rtl: (json['direction']?.toString() ?? '0') == '1',
      isDefault: (json['is_default']?.toString() ?? '0') == '1',
    );
  }
}

class LanguageListService {
  static Future<List<LanguageInfo>> fetch() async {
    final uri = Uri.parse(AppUrls.basic);
    final res = await http.get(uri, headers: HttpHeadersHelper.base());
    if (res.statusCode != 200) return const [];
    try {
      final decoded = json.decode(res.body);
      if (decoded is Map<String, dynamic>) {
        final data = decoded['data'];
        if (data is Map<String, dynamic>) {
          final langs = data['languages'];
          if (langs is List) {
            return langs
                .whereType<Map<String, dynamic>>()
                .map(LanguageInfo.fromJson)
                .toList();
          }
        }
      }
      return const [];
    } catch (_) {
      return const [];
    }
  }
}
