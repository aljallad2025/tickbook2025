import 'package:evento_app/utils/helpers.dart';

class TicketModel {
  final int ticketId;
  final int? eventId;
  final String eventType;
  final String? title;
  final String ticketAvailableType;
  final int? ticketAvailable;
  final String maxTicketBuyType;
  final int? maxBuyTicket;
  final String? description;
  final String pricingType;
  final double price;
  final double fPrice;
  final String earlyBirdDiscount;
  final double? earlyBirdDiscountAmount;
  final String? earlyBirdDiscountType;
  final DateTime? earlyBirdDiscountDate;
  final String? earlyBirdDiscountTime;
  final List<TicketOption> variations;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  final int? normalTicketSlotEnable;
  final int? normalTicketSlotUniqueId;
  final int? freeTicketSlotEnable;
  final int? freeTicketSlotUniqueId;
  final double? slotSeatMinPrice;

  const TicketModel({
    required this.ticketId,
    required this.eventType,
    required this.ticketAvailableType,
    required this.maxTicketBuyType,
    required this.pricingType,
    required this.price,
    required this.fPrice,
    required this.earlyBirdDiscount,
    required this.variations,
    this.eventId,
    this.title,
    this.ticketAvailable,
    this.maxBuyTicket,
    this.description,
    this.earlyBirdDiscountAmount,
    this.earlyBirdDiscountType,
    this.earlyBirdDiscountDate,
    this.earlyBirdDiscountTime,
    this.createdAt,
    this.updatedAt,
    this.normalTicketSlotEnable,
    this.normalTicketSlotUniqueId,
    this.freeTicketSlotEnable,
    this.freeTicketSlotUniqueId,
    this.slotSeatMinPrice,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    final variationsRaw = json['variations'];
    final variations = variationsRaw is List
        ? variationsRaw
              .whereType<Map<String, dynamic>>()
              .map(TicketOption.fromJson)
              .toList()
        : <TicketOption>[];

    return TicketModel(
      ticketId: asInt(json['id']) ?? 0,
      eventId: asInt(json['event_id']),
      eventType: (json['event_type'] ?? '').toString(),
      title: json['title']?.toString(),
      ticketAvailableType: (json['ticket_available_type'] ?? '').toString(),
      ticketAvailable: asInt(json['ticket_available']),
      maxTicketBuyType: (json['max_ticket_buy_type'] ?? '').toString(),
      maxBuyTicket: asInt(json['max_buy_ticket']),
      description: json['description']?.toString(),
      pricingType: (json['pricing_type'] ?? '').toString(),
      price: asDouble(json['price']) ?? 0.0,
      fPrice: asDouble(json['f_price']) ?? 0.0,
      earlyBirdDiscount: (json['early_bird_discount'] ?? '').toString(),
      earlyBirdDiscountAmount: asDouble(json['early_bird_discount_amount']),
      earlyBirdDiscountType: json['early_bird_discount_type']?.toString(),
      earlyBirdDiscountDate: asDateTime(json['early_bird_discount_date']),
      earlyBirdDiscountTime: json['early_bird_discount_time']?.toString(),
      variations: variations,
      createdAt: asDateTime(json['created_at']),
      updatedAt: asDateTime(json['updated_at']),
      normalTicketSlotEnable: asInt(json['normal_ticket_slot_enable']),
      normalTicketSlotUniqueId: asInt(json['normal_ticket_slot_unique_id']),
      freeTicketSlotEnable: asInt(json['free_tickete_slot_enable']),
      freeTicketSlotUniqueId: asInt(json['free_tickete_slot_unique_id']),
      slotSeatMinPrice: asDouble(json['slot_seat_min_price']),
    );
  }
}

class TicketOption {
  final String name;
  final double price;
  final String ticketAvailableType;
  final int? ticketAvailable;
  final String maxTicketBuyType;
  final int? vMaxTicketBuy;
  final int? slotEnable;
  final int? slotUniqueId;
  final double? slotSeatMinPrice;

  const TicketOption({
    required this.name,
    required this.price,
    required this.ticketAvailableType,
    required this.maxTicketBuyType,
    this.ticketAvailable,
    this.vMaxTicketBuy,
    this.slotEnable,
    this.slotUniqueId,
    this.slotSeatMinPrice,
  });

  factory TicketOption.fromJson(Map<String, dynamic> json) => TicketOption(
    name: (json['name'] ?? '').toString(),
    price: asDouble(json['price']) ?? 0.0,
    ticketAvailableType: (json['ticket_available_type'] ?? '').toString(),
    ticketAvailable: asInt(json['ticket_available']),
    maxTicketBuyType: (json['max_ticket_buy_type'] ?? '').toString(),
    vMaxTicketBuy: asInt(json['v_max_ticket_buy']),
    slotEnable: asInt(json['slot_enable']),
    slotUniqueId: asInt(json['slot_unique_id']),
    slotSeatMinPrice: asDouble(json['slot_seat_min_price']),
  );
}
