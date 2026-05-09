import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:evento_app/features/common/ui/widgets/shimmer_widgets.dart';

class DetailsShimmer extends StatelessWidget {
  final double height;
  final double width;
  final double radius;
  const DetailsShimmer({
    super.key,
    required this.height,
    required this.width,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

class HeaderShimmer extends StatelessWidget {
  const HeaderShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0.5,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const ShimmerBox(height: 100, width: 100),
            const SizedBox(height: 12),
            const DetailsShimmer(height: 18, width: 180, radius: 6),
            const SizedBox(height: 16),
            _InfoRowShimmer(),
            const SizedBox(height: 8),
            _InfoRowShimmer(shortValue: true),
            const SizedBox(height: 8),
            _InfoRowShimmer(),
            const SizedBox(height: 8),
            _InfoRowShimmer(),
            const SizedBox(height: 8),
            _InfoRowShimmer(longValue: true),
            const SizedBox(height: 16),
            const DetailsShimmer(height: 44, width: double.infinity, radius: 8),
          ],
        ),
      ),
    );
  }
}

class _InfoRowShimmer extends StatelessWidget {
  final bool shortValue;
  final bool longValue;
  const _InfoRowShimmer({this.shortValue = false, this.longValue = false});

  @override
  Widget build(BuildContext context) {
    final valueWidth = longValue
        ? double.infinity
        : shortValue
        ? 150.0
        : 220.0;
    return Row(
      children: [
        const DetailsShimmer(height: 14, width: 120, radius: 6),
        const SizedBox(width: 8),
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: DetailsShimmer(height: 14, width: valueWidth, radius: 6),
          ),
        ),
      ],
    );
  }
}
