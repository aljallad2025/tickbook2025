import 'package:evento_app/network_services/core/fcm_token_service.dart';

class BookingPayloadBuilder {
  static Map<String, dynamic> build({
    required Map data,
    required List items,
    required double total,
    dynamic customer,
    double couponDiscount = 0.0,
  }) {
    final selTicketsRaw = data['selTickets'];
    final dynamic quantityRaw = data['quantity'];

    int quantityTotal = 0;
    if (quantityRaw is List) {
      final quantityList = quantityRaw.map<int>((e) {
        // if (e is int) return e;
        if (e is num) return e.toInt();
        return int.tryParse(e.toString()) ?? 0;
      }).toList();
      quantityTotal = quantityList.fold<int>(0, (int a, int b) => a + b);
    } else if (quantityRaw is num) {
      quantityTotal = quantityRaw.toInt();
    } else if (quantityRaw != null) {
      final parsed = int.tryParse(quantityRaw.toString());
      if (parsed != null) quantityTotal = parsed;
    }

    List selTickets = [];
    if (selTicketsRaw is List) {
      selTickets = selTicketsRaw.map((e) {
        if (e is Map) return e;
        return {'name': e.toString()};
      }).toList();
    } else if (items.isNotEmpty) {
      for (final it in items) {
        if (it is Map) {
          final m = <String, dynamic>{
            'name': (it['name'] ?? '').toString(),
            'qty': () {
              final q = it['qty'];
              if (q is num) return q.toInt();
              return int.tryParse(q?.toString() ?? '') ?? 0;
            }(),
            'price': () {
              final p = it['unit'];
              if (p is num) return p;
              return double.tryParse(p?.toString() ?? '0') ?? 0;
            }(),
            'early_bird_dicount': 0,
          };
          // If seats list is present on item, include it for server-side clarity
          if (it['seats'] is List) {
            m['seats'] = List.from(it['seats'] as List);
          }
          selTickets.add(m);
        }
      }
    }

    final originalTotal = data['total'] is num
        ? (data['total'] as num).toDouble()
        : (data['price'] is num ? (data['price'] as num).toDouble() : total);

    final String pricingType = (data['pricing_type'] ?? 'normal').toString();
    double? asDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    double firstDouble(List<dynamic> candidates, {double orElse = 0.0}) {
      for (final c in candidates) {
        final d = asDouble(c);
        if (d != null) return d;
      }
      return orElse;
    }

    Map<String, dynamic> payload = {
      'event_id': (data['event_id'] ?? data['eventId'])?.toString(),
      'pricing_type': pricingType,
      'date_type': data['date_type'] ?? 'single',
      'event_date': data['event_date'],
      'quantity': quantityTotal,
      'fname': customer?.fname ?? data['fname'],
      'lname': customer?.lname ?? data['lname'],
      'email': customer?.email ?? data['email'],
      'phone': customer?.phone ?? data['phone'],
      'country': customer?.country ?? data['country'],
      'city': customer?.city ?? data['city'],
      'state': customer?.state ?? data['state'],
      'zip_code': customer?.zipCode ?? data['zip_code'],
      'address': () {
        final addr = (customer?.address ?? data['address'])?.toString().trim();
        if (addr == null || addr.isEmpty) {
          final et = (data['event_type'] ?? data['eventType'] ?? '')
              .toString()
              .trim();
          return et.isNotEmpty ? et.toUpperCase() : 'ONLINE';
        }
        return addr;
      }(),
      'paymentMethod': data['paymentMethod'] ?? 'offline',
      'paymentStatus': data['paymentStatus'] ?? 'pending',
      'gateway': data['gateway'] ?? 'offline',
      'gatewayType': data['gatewayType'] ?? 'offline',
      'fcm_token': data['token'] ?? FcmTokenService.token ?? '',
      'total': originalTotal,
      'discount': () {
        if (couponDiscount > 0) return couponDiscount;
        final d = data['discount'];
        if (d is num) return d.toDouble();
        if (d is String) return double.tryParse(d) ?? 0.0;
        return 0.0;
      }(),
      'tax': () {
        // Prefer explicit tax fields; fallback to percent of subtotal if available
        final explicit = firstDouble([
          data['tax'],
          data['tax_total'],
          data['tax_amount'],
          data['vat'],
          data['vat_amount'],
        ], orElse: double.nan);
        if (!explicit.isNaN) return explicit;
        final subTotal = firstDouble([
          data['sub_total'],
          data['subtotal'],
          data['subTotal'],
          // If subtotal missing, try original total as last resort
          data['total'],
          data['price'],
        ], orElse: double.nan);
        final percent = firstDouble([
          data['tax_percent'],
          data['tax_percentage'],
          data['vat_percent'],
          data['vat_percentage'],
          data['tax_rate'],
          data['vat_rate'],
        ], orElse: double.nan);
        if (!subTotal.isNaN && !percent.isNaN) {
          return (subTotal * percent / 100.0);
        }
        return 0.0;
      }(),
      'total_early_bird_dicount': () {
        final eb = data['total_early_bird_dicount'];
        if (eb is num) return eb.toDouble();
        if (eb is String) return double.tryParse(eb) ?? 0.0;
        return 0.0;
      }(),
      'customer_id': customer?.id ?? data['customer_id'],
      'selTickets': () {
        if (selTicketsRaw is List) {
          return selTicketsRaw
              .map((e) => e is Map ? e : {'name': e.toString()})
              .toList();
        }
        if (selTickets.isNotEmpty) return selTickets;
        return (data['selTickets'] is String ? data['selTickets'] : '');
      }(),
      // Pass through seating details if present
      'seat_data': (data['seat_data'] is List)
          ? (data['seat_data'] as List)
                .whereType<Map>()
                .map((e) => Map<String, dynamic>.from(e))
                .toList()
          : (data['seat_data'] ?? ''),
      'currencyText': data['currencyText'],
      'currencyTextPosition': data['currencyTextPosition'],
      'currencySymbol': data['currencySymbol'],
      'currencySymbolPosition': data['currencySymbolPosition'],
      // Offline extras (if any)
      'offline_gateway_id': data['offline_gateway_id'],
      'offline_has_attachment': data['offline_has_attachment'],
    }..removeWhere((k, v) => v == null);

    return payload;
  }
}
