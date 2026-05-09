import 'package:evento_app/app/app_text_styles.dart';
import 'package:evento_app/app/app_colors.dart';
import 'package:evento_app/features/events/data/models/seat_map_models.dart';
import 'package:evento_app/features/events/providers/seat_plan_provider.dart';
import 'package:evento_app/features/events/ui/widgets/seatplan/seat_chip.dart';
import 'package:flutter/material.dart';

class SeatPickerDialog extends StatefulWidget {
  final SeatSlot slot;
  final SeatPlanProvider provider;
  const SeatPickerDialog({
    super.key,
    required this.slot,
    required this.provider,
  });

  @override
  State<SeatPickerDialog> createState() => _SeatPickerDialogState();
}

class _SeatPickerDialogState extends State<SeatPickerDialog> {
  late Set<int> _localSelected;

  @override
  void initState() {
    super.initState();
    _localSelected = widget.slot.seats
        .where((s) => widget.provider.selectedSeatIds.contains(s.id))
        .map((s) => s.id)
        .toSet();
  }

  @override
  Widget build(BuildContext context) {
    final maxH = MediaQuery.of(context).size.height * 0.5;
    final slot = widget.slot;
    return AlertDialog(
      backgroundColor: Colors.white,
      clipBehavior: Clip.none,
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      alignment: Alignment.center,
      titlePadding: const EdgeInsets.all(16),
      title: Column(
        children: [
          Text(
            'Select Your Seats',
            style: AppTextStyles.headingSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Colors.black26),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxH),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: maxH - 80,
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final seat in slot.seats)
                        SeatChip(
                          label: seat.name,
                          price: seat.payablePrice > 0
                              ? seat.payablePrice
                              : seat.price,
                          disabled: seat.isBooked == 1 || seat.isDeactive == 1,
                          selected: _localSelected.contains(seat.id),
                          onTap: () {
                            if (seat.isBooked == 1 || seat.isDeactive == 1) {
                              return;
                            }
                            setState(() {
                              if (_localSelected.contains(seat.id)) {
                                _localSelected.remove(seat.id);
                              } else {
                                _localSelected.add(seat.id);
                              }
                            });
                            // Immediate provider update for live reflection outside dialog
                            final sp = widget.provider;
                            final alreadySelected = sp.selectedSeatIds.contains(
                              seat.id,
                            );
                            if (alreadySelected &&
                                !_localSelected.contains(seat.id)) {
                              sp.toggleSeat(seat);
                            } else if (!alreadySelected &&
                                _localSelected.contains(seat.id)) {
                              sp.toggleSeat(seat);
                            }
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        Column(
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              onPressed: () {
                final seatById = {for (final s in slot.seats) s.id: s};
                final sp = widget.provider;
                // Remove seats from this slot that are no longer selected
                for (final s in slot.seats) {
                  final wasSelected = sp.selectedSeatIds.contains(s.id);
                  final keep = _localSelected.contains(s.id);
                  if (wasSelected && !keep) {
                    sp.toggleSeat(seatById[s.id]!);
                  }
                }
                // Add newly selected seats for this slot
                for (final id in _localSelected) {
                  if (!sp.selectedSeatIds.contains(id)) {
                    final seat = seatById[id];
                    if (seat != null) sp.toggleSeat(seat);
                  }
                }
                Navigator.of(context).pop();
              },
              child: const Text('Apply', style: TextStyle(fontSize: 16)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      ],
    );
  }
}
