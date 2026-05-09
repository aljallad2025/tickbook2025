import 'package:flutter/material.dart';
import 'package:evento_app/app/app_text_styles.dart';

class TicketTile extends StatelessWidget {
  final String displayTitle;
  final String? subtitle;
  final String priceText;
  final bool seatingEnabled;
  final bool noSeat;
  final Widget? trailing;
  const TicketTile({
    super.key,
    required this.displayTitle,
    required this.subtitle,
    required this.priceText,
    required this.seatingEnabled,
    required this.noSeat,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      displayTitle,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              priceText,
              maxLines: 1,
              overflow: TextOverflow.fade,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(subtitle!, style: AppTextStyles.bodySmall),
        ],
        if (noSeat) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3CD),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFFFFEEBA)),
            ),
            child: Text(
              'No Seat Available',
              style: AppTextStyles.bodySmall.copyWith(color: Colors.black87),
            ),
          ),
        ],
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: trailing ?? const SizedBox.shrink(),
        ),
      ],
    );
  }
}
