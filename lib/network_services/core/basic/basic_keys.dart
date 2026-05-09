import 'package:evento_app/app/keys.dart';
import 'package:evento_app/network_services/core/basic_service.dart';

class BasicKeys {
  BasicKeys._();

  static Map<String, dynamic>? _basic(Map<String, dynamic>? decoded) =>
      (decoded?['data']?['basic_data'] as Map?)?.cast<String, dynamic>();

  static Future<String?> getStripePublishableKey() async {
    try {
      final decoded = await BasicService.fetchBasic();
      if (decoded is Map<String, dynamic>) {
        final data = decoded['data'];
        if (data is Map<String, dynamic>) {
          final k = data['stripe_public_key']?.toString();
          if (k != null && k.trim().isNotEmpty) return k.trim();
          final basic = _basic(decoded);
          final k2 = basic?['stripe_public_key']?.toString();
          if (k2 != null && k2.trim().isNotEmpty) return k2.trim();
        }
      }
    } catch (_) {}
    final key = AppKeys.stripePublishableKey;
    return key.isEmpty ? null : key;
  }

  static Future<String?> getRazorpayKey() async {
    if (AppKeys.razorpayKey.isNotEmpty) return AppKeys.razorpayKey;
    try {
      final decoded = await BasicService.fetchBasic();
      String fromMap(Map<String, dynamic> m, List<String> ks) {
        for (final k in ks) {
          final v = m[k];
          if (v != null && v.toString().trim().isNotEmpty) {
            return v.toString().trim();
          }
        }
        return '';
      }

      final dataRoot = (decoded?['data'] is Map)
          ? Map<String, dynamic>.from(decoded!['data'] as Map)
          : const <String, dynamic>{};
      final rpInfo = (dataRoot['razorpayInfo'] is Map)
          ? Map<String, dynamic>.from(dataRoot['razorpayInfo'] as Map)
          : const <String, dynamic>{};
      final infoKey = fromMap(rpInfo, const ['key', 'public_key', 'key_id']);
      if (infoKey.isNotEmpty) return infoKey;

      final basic = _basic(decoded);
      if (basic != null) {
        final key = fromMap(basic, const [
          'razorpay_key',
          'razorpay_api_key',
          'razorpay_public_key',
          'razorpay_key_id',
          'rzp_key',
        ]);
        if (key.isNotEmpty) return key;
      }
    } catch (_) {}
    return null;
  }
}

