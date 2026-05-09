import 'package:evento_app/app/app_text_styles.dart';
import 'package:evento_app/features/events/data/models/event_details_models.dart';
import 'package:evento_app/features/events/ui/widgets/events/event_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';

class RelatedEventsSection extends StatelessWidget {
  const RelatedEventsSection({super.key, required this.details});
  final EventDetailsPageModel details;
  @override
  Widget build(BuildContext context) {
    if (details.relatedEvents.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        Text(
          'Related Events'.tr,
          style: AppTextStyles.headingSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: details.relatedEvents.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final related = details.relatedEvents[index];
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 400),
              child: SlideAnimation(
                verticalOffset: 20,
                child: FadeInAnimation(child: EventCard(event: related)),
              ),
            );
          },
        ),
      ],
    );
  }
}


