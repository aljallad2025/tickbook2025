import 'package:evento_app/app/app_colors.dart';
import 'package:evento_app/app/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:evento_app/app/app_routes.dart';
import 'package:evento_app/features/events/providers/event_details_provider.dart';
import 'package:get/get.dart';

const double _kBottomBarHeight = 120;

class BottomBar extends StatelessWidget {
  const BottomBar({super.key, required this.minPrice});
  final double? minPrice;
  @override
  Widget build(BuildContext context) {
    final det = context.read<EventDetailsProvider>().details;
    final sym = det?.currencySymbol ?? '';
    final pos = (det?.currencySymbolPosition ?? 'left').toLowerCase();
    final minStr = (minPrice == null || (minPrice ?? 0) <= 0)
        ? 'FREE'
        : (pos == 'right'
              ? '${minPrice!.toStringAsFixed(2)}$sym'
              : '$sym${minPrice!.toStringAsFixed(2)}');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: _kBottomBarHeight,
      decoration: const BoxDecoration(color: Colors.white),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${'Starting from'.tr}:',
                style: AppTextStyles.bodyLargeGrey.copyWith(fontSize: 18),
              ),
              Text(
                minStr,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.primaryColor,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                final prov = context.read<EventDetailsProvider>();
                final id = prov.lastEventId;
                Get.toNamed(AppRoutes.tickets, arguments: {'eventId': id});
              },
              child: Text('Book Now'.tr, style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
