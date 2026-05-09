import 'package:evento_app/app/app_colors.dart';
import 'package:evento_app/app/app_text_styles.dart';
import 'package:evento_app/features/common/ui/widgets/custom_app_bar.dart';
import 'package:evento_app/features/common/ui/widgets/custom_cpi.dart';
import 'package:evento_app/features/events/data/models/seat_map_models.dart';
import 'package:evento_app/features/events/providers/event_details_provider.dart';
import 'package:evento_app/features/events/providers/seat_plan_provider.dart';
import 'package:evento_app/features/events/ui/widgets/seatplan/legend_dot.dart';
import 'package:evento_app/features/events/ui/widgets/seatplan/map_with_slots.dart';
import 'package:evento_app/features/events/ui/widgets/seatplan/seat_picker_dialog.dart';
import 'package:evento_app/features/common/ui/widgets/custom_snack_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SeatPlanScreen extends StatelessWidget {
  final int eventId;
  final int ticketId;
  final int slotUniqueId;
  const SeatPlanScreen({
    super.key,
    required this.eventId,
    required this.ticketId,
    required this.slotUniqueId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Select Your Seats'),
      body: Consumer<SeatPlanProvider>(
        builder: (context, prov, _) {
          if (prov.loading) return const Center(child: CustomCPI());
          final resp = prov.response;
          if (resp == null || (resp.success == false || resp.slots.isEmpty)) {
            final msg = prov.error ?? resp?.message ?? 'No Seat Available';
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(msg, style: AppTextStyles.bodyLarge),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              Container(
                color: Colors.white,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selected :',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      prov.selectedSeatIds.isEmpty
                          ? 'No seat selected yet'
                          : prov.selectedSeatIds
                                .map((e) => prov.seatNames[e] ?? e.toString())
                                .join(', '),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: MapWithSlots(
                  imageUrl: resp.slotImage,
                  slots: resp.slots,
                  onSlotTap: (slot) => _openSeatPicker(context, slot),
                  onReload: () => _reload(context),
                  selectedSeatIds: context
                      .read<SeatPlanProvider>()
                      .selectedSeatIds,
                ),
              ),
              const SizedBox(height: 8),

              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                width: double.infinity,
                child: Column(
                  children: [
                    Row(
                      children: [
                        const LegendDot(color: Colors.orange),
                        const SizedBox(width: 4),
                        const Text('Selected'),
                        const SizedBox(width: 16),
                        const LegendDot(color: Colors.grey),
                        const SizedBox(width: 4),
                        const Text('Not available'),
                        const Spacer(),
                        Builder(
                          builder: (ctx) {
                            final det = ctx
                                .read<EventDetailsProvider>()
                                .details;
                            final sym = det?.currencySymbol ?? '';
                            final pos = (det?.currencySymbolPosition ?? 'left')
                                .toLowerCase();
                            final amt = prov.totalPrice.toStringAsFixed(2);
                            final text = pos == 'right'
                                ? '$amt$sym'
                                : '$sym$amt';
                            return Text(
                              text,
                              style: AppTextStyles.headingSmall,
                              textDirection: TextDirection.ltr,
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: prov.selectedSeatIds.isEmpty
                          ? null
                          : () {
                              final selectedIds = prov.selectedSeatIds.toSet();
                              final seatDetails = <Map<String, dynamic>>[];
                              for (final slot in resp.slots) {
                                for (final seat in slot.seats) {
                                  if (!selectedIds.contains(seat.id)) continue;
                                  seatDetails.add({
                                    'id': seat.id,
                                    'name': seat.name,
                                    'price': seat.price,
                                    'payable_price': seat.payablePrice,
                                    'discount': 0,
                                    's_type': seat.seatType,
                                    'slot_id': seat.slotId,
                                    'slot_name': slot.slotName,
                                    'event_id': slot.eventId,
                                    'ticket_id': slot.ticketId,
                                    'slot_unique_id': slot.slotUniqueId,
                                  });
                                }
                              }
                              Navigator.of(context).pop({
                                'seatIds': selectedIds.toList(),
                                'seatNames': selectedIds
                                    .map(
                                      (e) => prov.seatNames[e] ?? e.toString(),
                                    )
                                    .toList(),
                                'seatDetails': seatDetails,
                                'total': prov.totalPrice,
                              });
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        disabledBackgroundColor: Colors.grey.shade400,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Select Tickets'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

  void _reload(BuildContext context, {bool keepSelection = false}) {
    context.read<SeatPlanProvider>().reload(keepSelection: keepSelection);
    CustomSnackBar.show(context, 'Refreshing seats...');
  }

  void _openSeatPicker(BuildContext context, SeatSlot slot) {
    if (slot.slotType == 2) {
      final available = slot.seats
          .where((s) => s.isBooked == 0 && s.isDeactive == 0)
          .toList();
      if (available.isEmpty) {
        CustomSnackBar.show(
          iconBgColor: AppColors.snackError,
          context,
          'No seat available in this slot',
        );
        return;
      }
      final sp = context.read<SeatPlanProvider>();
      if (sp.hasAnySelectedInSlot(slot)) {
        sp.deselectAllInSlot(slot);
        CustomSnackBar.show(
          iconBgColor: AppColors.snackError,
          context,
          'Deselected all seats in ${slot.slotName}',
        );
      } else {
        sp.selectAllAvailableInSlot(slot);
        CustomSnackBar.show(
          iconBgColor: AppColors.snackSuccess,
          context,
          'Selected all ${available.length} seats in ${slot.slotName}',
        );
      }
      return;
    }
    final prov = context.read<SeatPlanProvider>();
    showDialog(
      context: context,
      builder: (_) => SeatPickerDialog(slot: slot, provider: prov),
    );
  }
}
