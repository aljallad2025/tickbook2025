import 'package:get/get.dart';
import 'package:evento_app/network_services/core/language_service.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys {
    final all = LanguageService.exportAll();
    if (all.isNotEmpty) return all;
    return const {'en': {}, 'ar': {}};
  }
}
