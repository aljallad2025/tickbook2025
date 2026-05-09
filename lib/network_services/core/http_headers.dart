import 'package:evento_app/network_services/core/auth_services.dart';

class HttpHeadersHelper {
  static String _languageCode = 'en';

  static String get languageCode => _languageCode;

  static void setLanguage(String code) {
    if (code.trim().isEmpty) return;
    _languageCode = code.split('_').first.split('-').first.toLowerCase();
  }

  static Map<String, String> _core() => {
    'Accept': 'application/json',
    'Accept-Language': _languageCode,
  };

  static Map<String, String> base() {
    return Map<String, String>.from(_core());
  }

  static Map<String, String> auth() {
    final h = Map<String, String>.from(_core());
    final token = AuthServices.token;
    if (token != null && token.isNotEmpty) {
      h['Authorization'] = 'Bearer $token';
    }
    return h;
  }
}
