import 'package:evento_app/app/app_text_styles.dart';
import 'package:evento_app/features/events/data/models/event_details_models.dart';
import 'package:flutter/material.dart';

class SummaryBar extends StatelessWidget {
  final double totalPrice;
  final EventDetailsPageModel details;
  final VoidCallback onBuy;
  final bool verifying;
  final String? verifyError;
  const SummaryBar({
    super.key,
    required this.totalPrice,
    required this.details,
    required this.onBuy,
    required this.verifying,
    required this.verifyError,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Price :',
                style: AppTextStyles.bodyLargeGrey.copyWith(fontSize: 16),
              ),
              Text(
                (details.currencySymbolPosition?.toLowerCase() == 'right')
                    ? '${totalPrice.toStringAsFixed(0)}${details.currencySymbol ?? ''}'
                    : '${details.currencySymbol ?? ''}${totalPrice.toStringAsFixed(0)}',
                style: AppTextStyles.bodyLarge.copyWith(fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: verifying ? null : onBuy,
              child: verifying
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Buy Now', style: TextStyle(fontSize: 16)),
            ),
          ),
          if (verifyError != null) ...[
            const SizedBox(height: 8),
            Text(
              verifyError!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ],
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

