import 'package:evento_app/app/app_colors.dart';
import 'package:evento_app/features/events/providers/events_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class ActiveFiltersStrip extends StatelessWidget {
  const ActiveFiltersStrip({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EventsProvider>(
      builder: (context, pos, _) {
        final chips = <Widget>[];

        final catLabel = (pos.categoryName ?? '').trim().isNotEmpty
            ? pos.categoryName!
            : (pos.categoryId != null
                  ? '${'Category'.tr} ${pos.categoryId}'
                  : null);
        if (catLabel != null) {
          chips.add(
            _ActiveFilterChip(
              label: catLabel,
              onClear: () => pos.clearCategoryFilter(),
            ),
          );
        }

        if ((pos.eventType ?? '').isNotEmpty) {
          chips.add(
            _ActiveFilterChip(
              label: '${'Type:'.tr} ${pos.eventType?.tr}',
              onClear: () => pos.clearEventType(),
            ),
          );
        }
        if ((pos.country ?? '').isNotEmpty) {
          chips.add(
            _ActiveFilterChip(
              label: '${'Country'.tr}: ${pos.country?.tr}',
              onClear: () => pos.clearCountry(),
            ),
          );
        }
        if ((pos.stateName ?? '').isNotEmpty) {
          chips.add(
            _ActiveFilterChip(
              label: '${'State'.tr}: ${pos.stateName?.tr}',
              onClear: () => pos.clearStateName(),
            ),
          );
        }
        if ((pos.city ?? '').isNotEmpty) {
          chips.add(
            _ActiveFilterChip(
              label: '${'City'.tr}: ${pos.city?.tr}',
              onClear: () => pos.clearCity(),
            ),
          );
        }
        if ((pos.fromDate ?? '').isNotEmpty) {
          chips.add(
            _ActiveFilterChip(
              label: '${'From'.tr}: ${pos.fromDate}',
              onClear: () => pos.clearFromDate(),
            ),
          );
        }
        if ((pos.toDate ?? '').isNotEmpty) {
          chips.add(
            _ActiveFilterChip(
              label: '${'To'.tr}: ${pos.toDate}',
              onClear: () => pos.clearToDate(),
            ),
          );
        }
        if (pos.priceMinSelected != null || pos.priceMaxSelected != null) {
          final min = (pos.priceMinSelected ?? pos.priceMinBound).round();
          final max = (pos.priceMaxSelected ?? pos.priceMaxBound).round();
          chips.add(
            _ActiveFilterChip(
              label: '${'Price'.tr}: \$$min-\$$max',
              onClear: () => pos.clearPriceRange(),
            ),
          );
        }

        if (pos.centerLat != null &&
            pos.centerLon != null &&
            pos.radiusKm != null) {
          final radius = pos.radiusKm!.toStringAsFixed(1);
          final address = (pos.centerAddress ?? '').trim();
          final label = address.isNotEmpty
              ? '${'Nearby'.tr} $radius km from $address'
              : '${'Nearby'.tr} $radius km';
          chips.add(
            _ActiveFilterChip(
              label: label,
              onClear: () => pos.clearGeoRadius(),
            ),
          );
        }

        if (chips.isEmpty) return const SizedBox.shrink();

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Wrap(spacing: 8, children: chips),
        );
      },
    );
  }
}

class _ActiveFilterChip extends StatelessWidget {
  const _ActiveFilterChip({required this.label, required this.onClear});

  final String label;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primaryColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.tr,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onClear,
            child: Icon(Icons.close, size: 16, color: AppColors.primaryColor),
          ),
        ],
      ),
    );
  }
}
