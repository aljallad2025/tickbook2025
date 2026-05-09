import 'package:flutter/material.dart';
import 'package:evento_app/app/app_text_styles.dart';

class TicketSeatsSummary extends StatelessWidget {
  final Map<String, dynamic>? payload;
  final String? currencySymbol;
  final String? currencyPosition; // 'left' or 'right'
  const TicketSeatsSummary({super.key, this.payload, this.currencySymbol, this.currencyPosition});

  @override
  Widget build(BuildContext context) {
    final list = (payload?['selTickets'] is List)
        ? (payload!['selTickets'] as List).whereType<Map>().toList()
        : const <Map>[];
    if (list.isEmpty) {
      return Text(
        'No ticket variations returned.',
        style: AppTextStyles.bodySmall,
      );
    }
    String fmt(num v) {
      final sym = currencySymbol ?? '';
      final pos = (currencyPosition ?? 'left').toLowerCase();
      final s = v.toStringAsFixed(2);
      return pos == 'right' ? '$s$sym' : '$sym$s';
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final m in list)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        (m['name'] ?? 'Ticket').toString(),
                        style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text('x${m['qty'] ?? 1}', style: AppTextStyles.bodySmall),
                  ],
                ),
                if (m.containsKey('seat_name'))
                  Text('Seat: ${m['seat_name']}', style: AppTextStyles.bodySmall),
                Text('Unit: ${fmt(_num(m['price']))}', style: AppTextStyles.bodySmall),
                if (m.containsKey('payable_price'))
                  Text('Payable: ${fmt(_num(m['payable_price']))}', style: AppTextStyles.bodySmall),
              ],
            ),
          ),
      ],
    );
  }

  num _num(dynamic v) {
    if (v is num) return v;
    final d = double.tryParse(v?.toString() ?? '0');
    return d ?? 0;
  }
}

