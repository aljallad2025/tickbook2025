import 'package:evento_app/app/app_colors.dart';
import 'package:flutter/material.dart';

class SeatChip extends StatelessWidget {
  final String label;
  final double price;
  final bool disabled;
  final bool selected;
  final VoidCallback onTap;
  const SeatChip({
    super.key,
    required this.label,
    required this.price,
    required this.disabled,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = disabled
        ? Colors.grey.shade500
        : (selected ? Colors.orange : AppColors.primaryColor);
    final fg = Colors.white;
    return InkWell(
      onTap: disabled ? null : onTap,
      child: Container(
        alignment: Alignment.center,
        height: 40,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.black12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: fg,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text('\$${price.toStringAsFixed(0)}', style: TextStyle(color: fg)),
          ],
        ),
      ),
    );
  }
}
