import 'package:evento_app/features/events/data/models/event_details_models.dart';
import 'package:evento_app/features/events/ui/models/display_row.dart';

int? maxQty(String availType, int? available, String buyType, int? buyMax) {
  final aLimited = (availType).toLowerCase() == 'limited';
  final bLimited = (buyType).toLowerCase() == 'limited';
  if (aLimited && bLimited) {
    if (available == null) return buyMax;
    if (buyMax == null) return available;
    return available < buyMax ? available : buyMax;
  }
  if (aLimited) return available;
  if (bLimited) return buyMax;
  return null;
}

List<DisplayRow> buildDisplayRows(EventDetailsPageModel details) {
  final out = <DisplayRow>[];
  final tickets = details.tickets;
  for (int i = 0; i < tickets.length; i++) {
    final t = tickets[i];
    final pricing = (t.pricingType).toLowerCase();
    if (pricing == 'variation' && t.variations.isNotEmpty) {
      for (int v = 0; v < t.variations.length; v++) {
        final opt = t.variations[v];
        final seating =
            (opt.slotEnable ?? 0) == 1 && (opt.slotUniqueId ?? 0) > 0;
        out.add(
          DisplayRow(
            key: 'var|$i|$v',
            title:
                '${(t.title ?? '').trim().isNotEmpty ? t.title!.trim() : 'Ticket'} - ${opt.name}',
            subtitle: t.description?.trim().isNotEmpty == true
                ? t.description!.trim()
                : null,
            price: opt.price,
            seating: seating,
            noSeat: false,
            maxQty: maxQty(
              opt.ticketAvailableType,
              opt.ticketAvailable,
              opt.maxTicketBuyType,
              opt.vMaxTicketBuy,
            ),
            ticketId: t.ticketId,
            slotUniqueId: opt.slotUniqueId,
          ),
        );
      }
    } else {
      // Support both normal and free seating slots
      final bool normalSeating =
          (t.normalTicketSlotEnable ?? 0) == 1 &&
          (t.normalTicketSlotUniqueId ?? 0) > 0;
      final bool freeSeating =
          (t.freeTicketSlotEnable ?? 0) == 1 &&
          (t.freeTicketSlotUniqueId ?? 0) > 0;
      final bool seating = normalSeating || freeSeating;
      final int? slotId = normalSeating
          ? t.normalTicketSlotUniqueId
          : (freeSeating ? t.freeTicketSlotUniqueId : null);

      out.add(
        DisplayRow(
          key: 'norm|$i|-1',
          title: (t.title?.trim().isNotEmpty ?? false)
              ? t.title!.trim()
              : 'Ticket',
          subtitle: t.description?.trim().isNotEmpty == true
              ? t.description!.trim()
              : null,
          price: t.price,
          seating: seating,
          noSeat: false,
          maxQty: maxQty(
            t.ticketAvailableType,
            t.ticketAvailable,
            t.maxTicketBuyType,
            t.maxBuyTicket,
          ),
          ticketId: t.ticketId,
          slotUniqueId: slotId,
        ),
      );
    }
  }
  return out;
}
