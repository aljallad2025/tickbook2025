
import 'package:evento_app/features/common/ui/widgets/shimmer_widgets.dart';
import 'package:flutter/material.dart';

class EventsShimmerList extends StatelessWidget {
  const EventsShimmerList({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      itemCount: 8,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200, width: 0.5),
          ),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(width: 120, height: 96, child: ShimmerBox()),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(4, 12, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBox(
                        height: 16,
                        borderRadius: 4,
                        width: width * 0.6,
                      ),
                      const SizedBox(height: 6),
                      ShimmerBox(
                        height: 12,
                        borderRadius: 4,
                        width: width * 0.4,
                      ),
                      const SizedBox(height: 6),
                      ShimmerBox(
                        height: 12,
                        borderRadius: 4,
                        width: width * 0.3,
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
