import 'package:evento_app/features/common/ui/widgets/shimmer_widgets.dart';
import 'package:flutter/material.dart';

class HomeShimmerAnimation extends StatelessWidget {
  const HomeShimmerAnimation({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      children: [
        // Header
        const SizedBox(height: 20),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: ShimmerBox(height: 52, width: 160, borderRadius: 33),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: const ShimmerBox(height: 200, borderRadius: 16),
        ),
        const SizedBox(height: 16),

        // Section title
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: ShimmerBox(height: 20, width: 160, borderRadius: 6),
        ),
        const SizedBox(height: 12),

        // Categories row
        SizedBox(
          height: 120,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (_, __) => const ShimmerCategory(size: 64),
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemCount: 8,
          ),
        ),

        // Latest events title
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: ShimmerBox(height: 20, width: 180, borderRadius: 6),
        ),
        const SizedBox(height: 12),

        // Latest events cards
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.35,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: 4,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (_, i) => const SizedBox(
              width: 260,
              child: ShimmerBox(height: double.infinity, borderRadius: 12),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Events title
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: ShimmerBox(height: 20, width: 180, borderRadius: 6),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.35,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: 6,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (_, i) => const SizedBox(
              width: 260,
              child: ShimmerBox(height: double.infinity, borderRadius: 12),
            ),
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }
}
