import 'dart:convert';
import 'package:evento_app/features/checkout/ui/widgets/booking_payload_builder.dart';
import 'package:evento_app/network_services/core/booking_create_service.dart';
import 'package:evento_app/network_services/core/checkout_services.dart';
import 'package:evento_app/features/account/data/models/customer_model.dart';
import 'package:evento_app/features/bookings/data/models/booking_models.dart';

class CheckoutBookingModel {
  Future<
    (
      bool success,
      String? error,
      Map<String, dynamic> info,
      Map<String, dynamic> payload,
    )
  >
  create({
    required Map<String, dynamic> rawData,
    required List items,
    required double total,
    required CustomerModel? customer,
    required double couponDiscount,
    required String token,
  }) async {
    final payload = BookingPayloadBuilder.build(
      data: rawData,
      items: items,
      total: total,
      customer: customer,
      couponDiscount: couponDiscount,
    );

    // If offline payment proof is attached, use multipart upload.
    final attachPath = rawData['attachment_path']?.toString();
    if (attachPath != null && attachPath.isNotEmpty) {
      final fields = <String, String>{
        for (final e in payload.entries)
          e.key: () {
            final v = e.value;
            if (v is List || v is Map) {
              try {
                return jsonEncode(v);
              } catch (_) {
                return v.toString();
              }
            }
            return v.toString();
          }(),
      };
      try {
        final r = await CheckoutService.paymentProcess(
          fields,
          bearerToken: token,
          filePaths: {'attachment': attachPath},
        );
        final bool status =
            (r['status'] == true || r['success'] == true || r['status'] == 1);
        final String message = r['message']?.toString() ?? '';
        final info = (r['booking_info'] is Map)
            ? Map<String, dynamic>.from(r['booking_info'] as Map)
            : <String, dynamic>{};
        if (!status) {
          return (
            false,
            message.isNotEmpty ? message : 'Booking failed',
            <String, dynamic>{},
            payload,
          );
        }
        // Validate
        try {
          if (info.isNotEmpty) {
            BookingItemModel.fromJson(info);
          }
        } catch (_) {}
        return (true, null, info, payload);
      } catch (e) {
        return (false, e.toString(), <String, dynamic>{}, payload);
      }
    }

    final res = await BookingCreateService.create(
      payload: payload,
      token: token,
    );
    if (!res.status) {
      return (
        false,
        res.message.trim().isNotEmpty ? res.message : 'Booking failed',
        <String, dynamic>{}, // typed empty map
        payload,
      );
    }
    final Map<String, dynamic> info = res.bookingInfo != null
        ? Map<String, dynamic>.from(res.bookingInfo!)
        : <String, dynamic>{};

    // Validate
    if (info.isNotEmpty) {
      BookingItemModel.fromJson(info);
    }

    return (true, null, info, payload);
  }

  static String extractBookingId(Map<String, dynamic> src) {
    try {
      final direct = src['booking_id'] ?? src['id'] ?? src['bookingId'];
      if (direct != null && direct.toString().trim().isNotEmpty) {
        return direct.toString().trim();
      }
      final data = src['data'];
      if (data is Map) {
        final nested = data['booking_id'] ?? data['id'] ?? data['bookingId'];
        if (nested != null && nested.toString().trim().isNotEmpty) {
          return nested.toString().trim();
        }
      } else if (data is String && data.trim().isNotEmpty) {
        return data.trim();
      }
    } catch (_) {}
    return '';
  }
}
