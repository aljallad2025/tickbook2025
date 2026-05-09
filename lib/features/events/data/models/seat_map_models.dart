import 'package:evento_app/utils/helpers.dart';

class SeatMapResponse {
  final bool success;
  final String? message;
  final String slotImage; // url
  final String pricingType;
  final List<SeatSlot> slots;

  const SeatMapResponse({
    required this.success,
    required this.message,
    required this.slotImage,
    required this.pricingType,
    required this.slots,
  });

  factory SeatMapResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? (json['data'] as Map<String, dynamic>)
        : json;
    final slotsRaw = data['slots'];
    return SeatMapResponse(
      success: (json['success'] == null)
          ? true
          : (json['success'] == true || json['success'] == 'true'),
      message: (json['message'] ?? data['message'])?.toString(),
      slotImage: (data['slot_image'] ?? '').toString(),
      pricingType: (data['pricing_type'] ?? '').toString(),
      slots: slotsRaw is List
          ? slotsRaw
                .whereType<Map<String, dynamic>>()
                .map(SeatSlot.fromJson)
                .toList()
          : const <SeatSlot>[],
    );
  }
}

class SeatSlot {
  final int id;
  final int eventId;
  final int ticketId;
  final String slotName;
  final int slotType;
  final int slotUniqueId;
  final double posX;
  final double posY;
  final double width;
  final double height;
  final double round;
  final double rotate;
  final String backgroundColor;
  final String? borderColor;
  final double fontSize;
  final List<SeatItem> seats;
  final int isBooked;

  const SeatSlot({
    required this.id,
    required this.eventId,
    required this.ticketId,
    required this.slotName,
    required this.slotType,
    required this.slotUniqueId,
    required this.posX,
    required this.posY,
    required this.width,
    required this.height,
    required this.round,
    required this.rotate,
    required this.backgroundColor,
    required this.borderColor,
    required this.fontSize,
    required this.seats,
    required this.isBooked,
  });

  factory SeatSlot.fromJson(Map<String, dynamic> json) => SeatSlot(
    id: asInt(json['id']) ?? 0,
    eventId: asInt(json['event_id']) ?? 0,
    ticketId: asInt(json['ticket_id']) ?? 0,
    slotName: (json['slot_name'] ?? '').toString(),
    slotType: asInt(json['slot_type']) ?? 0,
    slotUniqueId: asInt(json['slot_unique_id']) ?? 0,
    posX: asDouble(json['slot_pos_x']) ?? 0,
    posY: asDouble(json['slot_pos_y']) ?? 0,
    width: asDouble(json['slot_width']) ?? 0,
    height: asDouble(json['slot_height']) ?? 0,
    round: asDouble(json['slot_round']) ?? 0,
    rotate: asDouble(json['slot_rotate']) ?? 0,
    backgroundColor: (json['slot_background_color'] ?? '').toString(),
    borderColor: json['slot_border_color']?.toString(),
    fontSize: asDouble(json['slot_font_size']) ?? 12,
    seats: (json['seats'] is List)
        ? (json['seats'] as List)
              .whereType<Map<String, dynamic>>()
              .map(SeatItem.fromJson)
              .toList()
        : const <SeatItem>[],
    isBooked: asInt(json['is_booked']) ?? 0,
  );
}

class SeatItem {
  final int id;
  final int slotId;
  final String name;
  final double price;
  final int isDeactive;
  final int isBooked;
  final double payablePrice;
  final int seatType;

  const SeatItem({
    required this.id,
    required this.slotId,
    required this.name,
    required this.price,
    required this.isDeactive,
    required this.isBooked,
    required this.payablePrice,
    required this.seatType,
  });

  factory SeatItem.fromJson(Map<String, dynamic> json) => SeatItem(
    id: asInt(json['id']) ?? 0,
    slotId: asInt(json['slot_id']) ?? 0,
    name: (json['name'] ?? '').toString(),
    price: asDouble(json['price']) ?? 0,
    isDeactive: asInt(json['is_deactive']) ?? 0,
    isBooked: asInt(json['is_booked']) ?? 0,
    payablePrice: asDouble(json['payable_price']) ?? 0,
    seatType: asInt(json['seat_type']) ?? 0,
  );
}
