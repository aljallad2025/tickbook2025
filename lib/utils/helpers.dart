int? asInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is String) return int.tryParse(v);
  return null;
}

double? asDouble(dynamic v) {
  if (v == null) return null;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  if (v is String) return double.tryParse(v);
  return null;
}

DateTime? asDateTime(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  // Handle integer timestamps (seconds or milliseconds)
  if (v is int) {
    // Heuristic: 10-digit -> seconds, 13-digit -> milliseconds
    final len = v.toString().length;
    if (len == 10) return DateTime.fromMillisecondsSinceEpoch(v * 1000);
    return DateTime.fromMillisecondsSinceEpoch(v);
  }
  if (v is String) {
    final s = v.trim();
    // Try ISO parse first
    DateTime? parsed = DateTime.tryParse(s);
    if (parsed != null) return parsed;

    // Common backend format: 'YYYY-MM-DD HH:MM:SS' -> replace space with 'T'
    if (s.contains(' ') && s.contains('-') && s.contains(':')) {
      final withT = s.replaceFirst(' ', 'T');
      parsed = DateTime.tryParse(withT);
      if (parsed != null) return parsed;
    }

    // Numeric string timestamps
    final digits = s.replaceAll(RegExp(r'\D'), '');
    if (digits.isNotEmpty) {
      try {
        if (digits.length == 13) return DateTime.fromMillisecondsSinceEpoch(int.parse(digits));
        if (digits.length == 10) return DateTime.fromMillisecondsSinceEpoch(int.parse(digits) * 1000);
      } catch (e) {
        assert(() { return true; }());
      }
    }
  }
  return null;
}
