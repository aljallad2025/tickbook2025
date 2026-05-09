import 'package:evento_app/network_services/core/basic_service.dart';

class BasicGateways {
  BasicGateways._();

  static Map<String, dynamic> _dataRoot(Map<String, dynamic>? decoded) {
    if (decoded == null) return const <String, dynamic>{};
    final d = decoded['data'];
    if (d is Map) {
      try {
        return Map<String, dynamic>.from(d);
      } catch (_) {
        final entries = d.entries;
        return {for (final e in entries) e.key.toString(): e.value};
      }
    }
    return const <String, dynamic>{};
  }

  static Future<List<Map<String, String>>> getOnlineGateways({
    bool forceReload = false,
  }) async {
    final decoded = await BasicService.fetchBasic(forceReload: forceReload);
    final root = _dataRoot(decoded);
    final raw = root['online_gateways'];
    if (raw is List) {
      final out = <Map<String, String>>[];
      for (final e in raw) {
        if (e is Map) {
          final m = Map<String, dynamic>.from(e);
          final keyword = (m['keyword'] ?? m['slug'] ?? m['code'] ?? '')
              .toString();
          final name = (m['name'] ?? keyword).toString();
          if (keyword.trim().isEmpty) continue;
          out.add({
            'keyword': keyword.trim().toLowerCase(),
            'name': name.trim(),
          });
        }
      }
      return out;
    }
    return const <Map<String, String>>[];
  }

  static Future<List<Map<String, String>>> getOfflineGateways({
    bool forceReload = false,
  }) async {
    final decoded = await BasicService.fetchBasic(forceReload: forceReload);
    final root = _dataRoot(decoded);
    final raw = root['offline_gateways'];
    if (raw is List) {
      final out = <Map<String, String>>[];
      for (final e in raw) {
        if (e is Map) {
          final m = Map<String, dynamic>.from(e);
          final id = (m['id'] ?? '').toString();
          final name = (m['name'] ?? '').toString();
          final instructions = (m['instructions'] ?? '').toString();
          final shortDesc = (m['short_description'] ?? '').toString();
          final hasAttachment =
              (m['has_attachment'] ?? m['hasAttachment'] ?? '0').toString();
          if (name.trim().isEmpty) continue;
          out.add({
            'id': id,
            'name': name.trim(),
            'instructions': instructions,
            'short_description': shortDesc,
            'has_attachment': hasAttachment,
          });
        }
      }
      return out;
    }
    return const <Map<String, String>>[];
  }
}
