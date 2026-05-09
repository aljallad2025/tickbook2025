import 'package:evento_app/features/events/providers/events_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DatePickersRow extends StatelessWidget {
  final String? fromDate;
  final String? toDate;
  final Future<void> Function(BuildContext, {required bool isFrom}) pickDate;

  const DatePickersRow({
    super.key,
    required this.fromDate,
    required this.toDate,
    required this.pickDate,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => pickDate(context, isFrom: true),
            child: Text(fromDate == null ? 'From Date'.tr : 'From: $fromDate'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton(
            onPressed: () => pickDate(context, isFrom: false),
            child: Text(toDate == null ? 'To Date'.tr : 'To: $toDate'),
          ),
        ),
      ],
    );
  }
}

class PriceRangeSlider extends StatelessWidget {
  final EventsProvider provider;
  final double? priceStart;
  final double? priceEnd;
  final ValueChanged<RangeValues> onChanged;

  const PriceRangeSlider({
    super.key,
    required this.provider,
    required this.priceStart,
    required this.priceEnd,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final minBound = provider.priceMinBound;
    final maxBound = provider.priceMaxBound;

    if (maxBound <= minBound) return const SizedBox.shrink();

    final currentStart = (priceStart ?? minBound).clamp(minBound, maxBound);
    final currentEnd = (priceEnd ?? maxBound).clamp(minBound, maxBound);
    final divisions = (maxBound - minBound).round() == 0
        ? null
        : (maxBound - minBound).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${'Price:'.tr} \$${currentStart.round()} - \$${currentEnd.round()}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        RangeSlider(
          values: RangeValues(currentStart, currentEnd),
          min: minBound,
          max: maxBound,
          divisions: divisions,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
