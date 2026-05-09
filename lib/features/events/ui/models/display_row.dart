class DisplayRow {
  final String key;
  final String title;
  final String? subtitle;
  final double price;
  final bool seating;
  final bool noSeat;
  final int? maxQty;
  final int ticketId;
  final int? slotUniqueId;
  const DisplayRow({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.seating,
    required this.noSeat,
    required this.maxQty,
    required this.ticketId,
    required this.slotUniqueId,
  });
}

