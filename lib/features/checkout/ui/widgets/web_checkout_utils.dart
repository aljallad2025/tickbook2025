class WebCheckoutUtils {
  const WebCheckoutUtils._();

  static bool looksPaidString(String s) {
    final up = s.toLowerCase();
    return up.contains('paid') ||
        up.contains('success') ||
        up.contains('completed') ||
        up.contains('captured') ||
        up.contains('approved') ||
        up.contains('settlement') ||
        up.contains('capture');
  }

  static bool isTruthy(dynamic x) {
    if (x is bool) return x;
    if (x is num) return x == 1 || x > 0;
    if (x is String) {
      return looksPaidString(x) || x.toLowerCase() == 'true' || x == '1';
    }
    return false;
  }

  static bool evaluatePaid(dynamic v) {
    if (v is Map) {
      for (final e in v.entries) {
        final k = e.key.toString().toLowerCase();
        final val = e.value;
        if (k.contains('status') && val is String && looksPaidString(val)) {
          return true;
        }
        if (k == 'success' || k == 'paid' || k == 'ok') {
          if (isTruthy(val)) return true;
        }
        if (evaluatePaid(val)) return true;
      }
      return false;
    }
    if (v is List) {
      for (final item in v) {
        if (evaluatePaid(item)) return true;
      }
      return false;
    }
    if (v is String) return looksPaidString(v);
    return isTruthy(v);
  }

  static String buildStatusUrl(String template, String invoiceId) {
    var url = template.replaceAll('{invoiceId}', invoiceId);
    url = url.replaceAll('{txnId}', invoiceId);
    return url;
  }
}
