import 'package:evento_app/features/auth/providers/auth_provider.dart';
import 'package:evento_app/features/events/data/models/event_details_models.dart';
import 'package:evento_app/features/events/providers/tickets_provider.dart';
import 'package:evento_app/features/events/ui/models/display_row.dart';
import 'package:evento_app/features/events/ui/widgets/tickets/date_text.dart';

import 'package:evento_app/network_services/core/checkout_verify_service.dart';
import 'package:evento_app/network_services/core/fcm_token_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

List<Map<String, dynamic>> _buildCheckoutItems(
  TicketsProvider tp,
  EventDetailsPageModel details,
) {
  final items = <Map<String, dynamic>>[];
  tp.qty.forEach((key, qty) {
    if (qty <= 0) return;
    final parts = key.split('|');
    if (parts.length < 3) return;
    final int tIdx = int.tryParse(parts[1]) ?? -1;
    final int vIdx = int.tryParse(parts[2]) ?? -1;
    if (tIdx < 0 || tIdx >= details.tickets.length) return;
    final t = details.tickets[tIdx];
    final isVar = parts[0] == 'var';
    double unit;
    String name;
    if (isVar && vIdx >= 0 && vIdx < (t.variations.length)) {
      final vList = t.variations;
      final v = vList[vIdx];
      unit = v.price.toDouble();
      final ticketTitle = (t.title?.trim().isNotEmpty ?? false)
          ? t.title!.trim()
          : 'Ticket Title';
      name = '$ticketTitle - ${v.name}';
    } else {
      unit = t.price.toDouble();
      name = (t.title?.trim().isNotEmpty ?? false)
          ? t.title!.trim()
          : 'Ticket Title';
    }
    items.add({'name': name, 'qty': qty, 'unit': unit, 'subtotal': unit * qty});
  });
  tp.seatSelections.forEach((key, sel) {
    if (sel.seatIds.isEmpty) return;
    String name = 'Seating';
    final parts = key.split('|');
    if (parts.length >= 3) {
      final int tIdx = int.tryParse(parts[1]) ?? -1;
      final int vIdx = int.tryParse(parts[2]) ?? -1;
      if (tIdx >= 0 && tIdx < details.tickets.length) {
        final t = details.tickets[tIdx];
        final ticketTitle = (t.title?.trim().isNotEmpty ?? false)
            ? t.title!.trim()
            : 'Ticket Title';
        if (parts[0] == 'var' && vIdx >= 0 && vIdx < (t.variations.length)) {
          final v = t.variations[vIdx];
          name = '$ticketTitle - ${v.name} (Seating)';
        } else {
          name = '$ticketTitle (Seating)';
        }
      }
    }
    final qty = sel.seatIds.length;
    // Derive a reasonable per-seat unit for display. If multiple seats with
    // mixed pricing are selected, this shows the average unit price.
    final double unit = qty > 0 ? (sel.total / qty) : sel.total;
    items.add({
      'name': name,
      'qty': qty,
      'unit': unit,
      'subtotal': sel.total,
      'seats': sel.seatNames,
    });
  });
  return items;
}

Future<Map<String, dynamic>> verifyAndBuildCheckoutPayload({
  required BuildContext context,
  required EventDetailsPageModel details,
  required List<DisplayRow> rows,
  EventMultiDateModel? selectedOccur,
}) async {
  final tp = context.read<TicketsProvider>();

  final items = _buildCheckoutItems(tp, details);
  final seatData = <Map<String, dynamic>>[];
  for (final s in tp.seatSelections.values) {
    for (final m in s.seatDetails) {
      seatData.add(Map<String, dynamic>.from(m));
    }
  }
  // Build selTickets array (server-friendly), including per-seat entries
  final selTickets = <Map<String, dynamic>>[];
  // Map rows by key for quick lookups
  final rowByKey = {for (final r in rows) r.key: r};
  // Non-seating quantities -> as ticket entries
  tp.qty.forEach((key, qty) {
    if (qty <= 0) return;
    final row = rowByKey[key];
    if (row == null) return;
    if (row.seating) return; // seating handled below per seat
    selTickets.add({
      'ticket_id': row.ticketId,
      'early_bird_dicount': 0,
      'name': row.title,
      'qty': qty,
      'price': row.price,
    });
  });
  // Seating selections per seat -> one entry per seat with required fields
  tp.seatSelections.forEach((key, sel) {
    if (sel.seatDetails.isEmpty) return;
    final row = rowByKey[key];
    final displayName = row?.title ?? 'Seating';
    for (final m in sel.seatDetails) {
      final seatId = m['id'];
      final seatName = m['name'];
      final slotId = m['slot_id'];
      final slotName = m['slot_name'];
      final slotUniqueId = m['slot_unique_id'];
      final eventId = m['event_id'] ?? details.event.id;
      final ticketId = m['ticket_id'] ?? row?.ticketId;
      final price = (m['price'] is num)
          ? (m['price'] as num).toDouble()
          : double.tryParse(m['price']?.toString() ?? '0') ?? 0.0;
      final payable = (m['payable_price'] is num)
          ? (m['payable_price'] as num).toDouble()
          : double.tryParse(m['payable_price']?.toString() ?? '0') ?? price;
      final discount = (m['discount'] is num)
          ? (m['discount'] as num).toDouble()
          : double.tryParse(m['discount']?.toString() ?? '0') ?? 0.0;
      selTickets.add({
        'ticket_id': ticketId,
        'early_bird_dicount': 0,
        'name': displayName,
        'qty': 1,
        'price': price,
        'discount': discount,
        'payable_price': payable,
        'seat_id': seatId,
        'seat_name': seatName,
        'slot_id': slotId,
        'slot_name': slotName,
        'slot_unique_id': slotUniqueId,
        'event_id': eventId,
        's_type': m['s_type'] ?? 0,
      });
    }
  });
  final qtyArray = <int>[];
  for (final r in rows) {
    qtyArray.add(tp.qty[r.key] ?? 0);
  }
  final bool anyVarQty = tp.qty.keys.any(
    (k) => k.startsWith('var') && (tp.qty[k] ?? 0) > 0,
  );
  final bool anyVarSeats = tp.seatSelections.keys.any(
    (k) => k.startsWith('var'),
  );
  bool anyFreeQty = false;
  tp.qty.forEach((key, q) {
    if (q <= 0) return;
    final parts = key.split('|');
    final int tIdx = int.tryParse(parts[1]) ?? -1;
    final int vIdx = int.tryParse(parts[2]) ?? -1;
    if (tIdx < 0 || tIdx >= details.tickets.length) {
      return;
    }
    final t = details.tickets[tIdx];
    if (parts[0] == 'var') {
      if (vIdx >= 0 && vIdx < t.variations.length) {
        if (t.variations[vIdx].price <= 0) {
          anyFreeQty = true;
        }
      }
    } else {
      if (t.pricingType.toLowerCase() == 'free' || t.price <= 0) {
        anyFreeQty = true;
      }
    }
  });
  bool anyFreeSeats = false;
  tp.seatSelections.forEach((key, sel) {
    if (sel.seatIds.isEmpty) return;
    final parts = key.split('|');
    final int tIdx = int.tryParse(parts[1]) ?? -1;
    final int vIdx = int.tryParse(parts[2]) ?? -1;
    if (tIdx < 0 || tIdx >= details.tickets.length) return;
    final t = details.tickets[tIdx];
    if (parts[0] == 'var') {
      if (vIdx >= 0 && vIdx < t.variations.length) {
        // Seating total decides, but assume free if ticket variation price <= 0
        if (t.variations[vIdx].price <= 0) anyFreeSeats = true;
      }
    } else {
      if (t.price <= 0) anyFreeSeats = true;
    }
  });
  final String pricingType = (() {
    if (anyVarQty || anyVarSeats) {
      return 'variation';
    }
    if (anyFreeQty || anyFreeSeats) return 'free';
    final hasSeats = tp.seatSelections.values.any((s) => s.seatIds.isNotEmpty);
    if (hasSeats) return 'seating';
    return 'normal';
  })();

  final int scalarQty = qtyArray.fold<int>(0, (a, b) => a + b);
  final String eventTypeStr = (details.event.eventType ?? '').toLowerCase();
  final bool sendArrayQty = eventTypeStr == 'venue';
  final dynamic quantityField = sendArrayQty
      ? qtyArray.map((e) => e.toString()).toList()
      : scalarQty;

  final verifyPayload = <String, dynamic>{
    'event_guest_checkout_status': 1,
    'event_id': details.event.id.toString(),
    'pricing_type': pricingType,
    'seat_data': seatData.isEmpty ? '' : seatData,
    'quantity': quantityField,
  };

  final CheckoutVerifyResult verifyRes = await CheckoutVerifyService.verify(
    verifyPayload,
  );
  if (!verifyRes.success) {
    final msg = verifyRes.message.isNotEmpty
        ? verifyRes.message
        : 'Verification failed';
    throw Exception(msg);
  }

  final verifiedQty = verifyRes.quantityScalar;
  if (!context.mounted) return <String, dynamic>{};
  double verifiedTotal = verifyRes.total == 0.0
      ? context.read<TicketsProvider>().computeTotal(details)
      : verifyRes.total;
  final double? verifiedSubTotal = verifyRes.subTotal == 0.0
      ? null
      : verifyRes.subTotal;

  double? numD(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  final raw = verifyRes.data;
  double? verifiedTax;
  double? verifiedTaxPercentUi; // normalized percent for UI (0-100)
  final percentVal = numD(
    raw['tax_percent'] ?? raw['taxPercentage'] ?? raw['tax_rate'],
  );
  final maybeTax = numD(raw['tax'] ?? raw['vat']);
  final typeStr = (raw['tax_type'] ?? raw['type'] ?? '')
      .toString()
      .toLowerCase();
  final isPercentFlag =
      raw['tax_is_percent'] == true ||
      raw['is_percent'] == true ||
      typeStr.contains('percent');
  final base = verifiedSubTotal ?? verifiedTotal;
  if (percentVal != null) {
    final rate = percentVal <= 1 ? percentVal : percentVal / 100.0;
    verifiedTax = base * rate;
    verifiedTaxPercentUi = percentVal <= 1 ? (percentVal * 100.0) : percentVal;
  } else if (maybeTax != null) {
    if (isPercentFlag || maybeTax <= 100) {
      final rate = maybeTax <= 1 ? maybeTax : maybeTax / 100.0;
      verifiedTax = base * rate;
      verifiedTaxPercentUi = maybeTax <= 1 ? (maybeTax * 100.0) : maybeTax;
    } else {
      verifiedTax = maybeTax;
    }
  }
  final double? verifiedFees = () {
    final cands = [
      raw['fees_total'],
      raw['fees'],
      raw['service_charge'],
      raw['platform_fee'],
      raw['processing_fee'],
      raw['convenience_fee'],
      raw['booking_fee'],
      raw['charge'],
    ];
    double sum = 0;
    bool any = false;
    for (final v in cands) {
      final d = (v is num)
          ? v.toDouble()
          : (v is String ? double.tryParse(v) : null);
      if (d != null) {
        sum += d;
        any = true;
      }
    }
    return any ? sum : null;
  }();
  final double? verifiedGrandTotal = (raw['grand_total'] is num)
      ? (raw['grand_total'] as num).toDouble()
      : null;
  if (verifiedGrandTotal != null && verifiedGrandTotal > 0) {
    verifiedTotal = verifiedGrandTotal;
  } else {
    final b = verifiedSubTotal ?? verifiedTotal;
    verifiedTotal = b + (verifiedTax ?? 0) + (verifiedFees ?? 0);
  }

  final customer = context.read<AuthProvider>().customerModel;
  final String eventDateRaw = () {
    if (selectedOccur?.startDate != null) {
      try {
        return DateFormat('yyyy-MM-dd').format(selectedOccur!.startDate!);
      } catch (_) {
        final d = selectedOccur!.startDate!;
        return DateTime(
          d.year,
          d.month,
          d.day,
        ).toIso8601String().split('T').first;
      }
    }
    final d = details.event.startDate;
    if (d != null) {
      try {
        return DateFormat('yyyy-MM-dd').format(d);
      } catch (_) {
        return DateTime(
          d.year,
          d.month,
          d.day,
        ).toIso8601String().split('T').first;
      }
    }
    return '';
  }();

  final payload = <String, dynamic>{
    'eventTitle': details.event.title,
    'eventDateText': formatEventDateFromOccurrence(details, selectedOccur),
    'event_type': details.event.eventType,
    'event_id': details.event.id.toString(),
    'date_type': details.event.dateType ?? 'single',
    'event_date': eventDateRaw,
    'items': items,
    'selTickets': selTickets,
    'total': verifiedTotal,
    'seat_data': seatData,
    'quantity': verifiedQty,
    'quantity_array': qtyArray,
    'ticket_logo': details.event.ticketLogo,
    'ticket_image': details.event.ticketImage,
    'ticket_logo_text': details.event.name,
    'ticket_email': customer?.email ?? '',
    'ticket_phone': customer?.phone ?? '',
    'fname': customer?.fname ?? '',
    'lname': customer?.lname ?? '',
    'email': customer?.email ?? '',
    'phone': customer?.phone ?? '',
    'country': customer?.country ?? '',
    'state': customer?.state ?? '',
    'city': customer?.city ?? '',
    'zip_code': customer?.zipCode ?? '',
    'address': customer?.address ?? (details.event.eventType ?? 'ONLINE'),
    'fcm_token': FcmTokenService.token ?? '',
    'grand_total': verifiedTotal,
    if (verifiedSubTotal != null) 'sub_total': verifiedSubTotal,
    if (verifiedTax != null) 'tax_total': verifiedTax,
    if (verifiedTaxPercentUi != null) 'tax_percent': verifiedTaxPercentUi,
    if (verifiedFees != null) 'fees_total': verifiedFees,
    'early_bird_discount': 0,
    'total_early_bird_dicount': 0,
    'currencySymbol': details.currencySymbol,
    'currencySymbolPosition': details.currencySymbolPosition,
    'currencyText': details.currencyText,
  }..removeWhere((k, v) => v == null);

  return payload;
}
