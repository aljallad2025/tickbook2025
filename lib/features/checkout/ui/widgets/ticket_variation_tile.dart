import 'package:flutter/material.dart';
import 'package:evento_app/app/app_text_styles.dart';
import 'package:evento_app/features/bookings/data/models/booking_models.dart';

class TicketVariationTile extends StatelessWidget {
  final TicketVariation v;
  final String? currencySymbol;
  const TicketVariationTile({super.key, required this.v, required this.currencySymbol});
  @override
  Widget build(BuildContext context) {
    final sym = currencySymbol ?? '\$';
    final unit = (v.payablePrice ?? v.price);
    final total = unit * v.qty;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  v.name.isNotEmpty ? v.name : 'Ticket',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text('x${v.qty}', style: AppTextStyles.bodySmall),
            ],
          ),
          const SizedBox(height: 4),
          Text('Unit: $sym${unit.toStringAsFixed(2)}', style: AppTextStyles.bodySmall),
          Text(
            'Subtotal: $sym${total.toStringAsFixed(2)}',
            style: AppTextStyles.bodySmall,
          ),
          if ((v.seatName ?? '').isNotEmpty)
            Text('Seat: ${v.seatName}', style: AppTextStyles.bodySmall),
          if (v.earlyBirdDiscount > 0)
            Text(
              'Early Bird: ${v.earlyBirdDiscount}',
              style: AppTextStyles.bodySmall,
            ),
          if (v.uniqueId.isNotEmpty)
            Text(
              'UID: ${v.uniqueId}',
              style: AppTextStyles.bodySmall.copyWith(color: Colors.black54),
            ),
        ],
      ),
    );
  }
}
