import 'dart:convert';

import 'package:evento_app/utils/helpers.dart';

class BookingsResponseModel {
  final String pageTitle;
  final List<BookingItemModel> bookings;

  BookingsResponseModel({required this.pageTitle, required this.bookings});

  /// Flexible parser that supports multiple response shapes from API:
  /// 1) { data: { page_title, bookings: [] } }
  /// 2) { page_title, bookings: [] }
  /// 3) [ {..booking..}, ... ]
  factory BookingsResponseModel.fromAny(dynamic root) {
    String pageTitle = '';
    List<dynamic> list = const [];

    if (root is Map<String, dynamic>) {
      final data = root['data'];
      if (data is Map<String, dynamic>) {
        pageTitle = data['page_title']?.toString() ?? '';
        final raw = data['bookings'];
        if (raw is List) list = raw;
      } else {
        // No nested data wrapper
        pageTitle = root['page_title']?.toString() ?? '';
        final raw = root['bookings'];
        if (raw is List) list = raw;
      }
    } else if (root is List) {
      list = root;
    }

    return BookingsResponseModel(
      pageTitle: pageTitle,
      bookings: list
          .whereType<Map<String, dynamic>>()
          .map(BookingItemModel.fromJson)
          .toList(),
    );
  }
}

class BookingItemModel {
  final int id;
  final String bookingId;
  final String eventId;
  final String? organizerId;
  final String? eventTitle;
  final String? organizerName;
  final String? thumbnail;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String address;
  final String city;
  final String country;
  final String state;
  final String zipCode;
  final String eventDateRaw;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String paymentStatus;
  final String? paymentMethod;
  final String? currencyText;
  final String? currencySymbol;
  final String price;
  final String quantity;
  final String tax;
  final String discount;
  final String commission;
  final String earlyBirdDiscount;
  final List<TicketVariation> variations;

  BookingItemModel({
    required this.id,
    required this.bookingId,
    required this.eventId,
    required this.organizerId,
    required this.eventTitle,
    required this.organizerName,
    required this.thumbnail,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    required this.country,
    required this.state,
    required this.zipCode,
    required this.eventDateRaw,
    required this.createdAt,
    required this.updatedAt,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.currencyText,
    required this.currencySymbol,
    required this.price,
    required this.quantity,
    required this.tax,
    required this.discount,
    required this.commission,
    required this.earlyBirdDiscount,
    required this.variations,
  });

  factory BookingItemModel.fromJson(Map<String, dynamic> json) {
    // variation comes as JSON-encoded string
    final rawVariation = json['variation'];
    List<TicketVariation> variations = const [];
    if (rawVariation != null) {
      try {
        final decoded = rawVariation is String
            ? jsonDecode(rawVariation)
            : rawVariation;
        if (decoded is List) {
          variations = decoded
              .whereType<Map<String, dynamic>>()
              .map(TicketVariation.fromJson)
              .toList();
        }
      } catch (_) {}
    }

    return BookingItemModel(
      id: asInt(json['id']) ?? 0,
      bookingId: json['booking_id']?.toString() ?? '',
      eventId: json['event_id']?.toString() ?? '',
      organizerId: json['organizer_id']?.toString(),
      eventTitle: json['event_title']?.toString(),
      organizerName: json['organizer_name']?.toString(),
      thumbnail: json['thumbnail']?.toString(),
      firstName: json['fname']?.toString() ?? '',
      lastName: json['lname']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      zipCode: json['zip_code']?.toString() ?? '',
      eventDateRaw: json['event_date']?.toString() ?? '',
      createdAt: asDateTime(json['created_at']),
      updatedAt: asDateTime(json['updated_at']),
      paymentStatus: json['paymentStatus']?.toString() ?? '',
      paymentMethod: json['paymentMethod']?.toString(),
      currencyText: json['currencyText']?.toString(),
      currencySymbol: json['currencySymbol']?.toString(),
      price: json['price']?.toString() ?? '',
      quantity: json['quantity']?.toString() ?? '',
      tax: (() {
        final v = json['tax'] ??
            json['tax_total'] ??
            json['tax_amount'] ??
            json['vat'] ??
            json['shop_tax'];
        return v?.toString() ?? '';
      })(),
      discount: json['discount']?.toString() ?? '',
      commission: json['commission']?.toString() ?? '',
      earlyBirdDiscount: json['early_bird_discount']?.toString() ?? '',
      variations: variations,
    );
  }

  String get customerFullName => ('$firstName $lastName').trim();
}

class TicketVariation {
  final int ticketId;
  final int earlyBirdDiscount;
  final String name;
  final int qty;
  final double price;
  final int scanStatus;
  final String uniqueId;
  // Seating-related (optional)
  final int? seatId;
  final String? seatName;
  final int? slotId;
  final String? slotName;
  final int? slotUniqueId;
  final int? eventId;
  final int? sType;
  final double? payablePrice;
  final double? discount;

  const TicketVariation({
    required this.ticketId,
    required this.earlyBirdDiscount,
    required this.name,
    required this.qty,
    required this.price,
    required this.scanStatus,
    required this.uniqueId,
    this.seatId,
    this.seatName,
    this.slotId,
    this.slotName,
    this.slotUniqueId,
    this.eventId,
    this.sType,
    this.payablePrice,
    this.discount,
  });

  factory TicketVariation.fromJson(Map<String, dynamic> json) => TicketVariation(
        ticketId: asInt(json['ticket_id']) ?? 0,
        earlyBirdDiscount: asInt(json['early_bird_dicount']) ?? 0,
        name: json['name']?.toString() ?? '',
        qty: asInt(json['qty']) ?? 0,
        price: asDouble(json['price']) ?? 0,
        scanStatus: asInt(json['scan_status']) ?? 0,
        uniqueId: json['unique_id']?.toString() ?? '',
        seatId: asInt(json['seat_id']),
        seatName: json['seat_name']?.toString(),
        slotId: asInt(json['slot_id']),
        slotName: json['slot_name']?.toString(),
        slotUniqueId: asInt(json['slot_unique_id']),
        eventId: asInt(json['event_id']),
        sType: asInt(json['s_type']),
        payablePrice: asDouble(json['payable_price']),
        discount: asDouble(json['discount']),
      );
}
