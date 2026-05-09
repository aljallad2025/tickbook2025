import 'package:evento_app/features/categories/models/category_model.dart';
import 'package:evento_app/features/events/data/models/event_item_model.dart';
import 'package:evento_app/features/home/data/models/section_titles_model.dart';
import 'package:evento_app/app/app_routes.dart';
import 'package:get/get.dart';
import 'package:evento_app/features/home/providers/nav_provider.dart';
import 'package:evento_app/features/home/ui/widgets/event_card_horizontal.dart';
import 'package:evento_app/features/home/ui/widgets/filter_chip_title.dart';
import 'package:evento_app/features/common/ui/widgets/header_text_buttons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class EventsSectionWithFilter extends StatelessWidget {
  const EventsSectionWithFilter({
    super.key,
    required this.data,
    required this.allEvents,
    required this.latestEvents,
    required this.eventsByCategory,
    required this.categories,
    required this.selectedCategoryId,
    required this.onSelectCategory,
  });

  final SectionTitlesModel data;
  final List<EventItemModel> allEvents;
  final List<EventItemModel> latestEvents;
  final Map<int, List<EventItemModel>> eventsByCategory;
  final List<CategoryModel> categories;
  final int? selectedCategoryId;
  final ValueChanged<int?> onSelectCategory;

  @override
  Widget build(BuildContext context) {
    final displayEvents = selectedCategoryId == null
        ? allEvents
        : (eventsByCategory[selectedCategoryId] ?? const []);
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (data.featuresSectionTitle.isNotEmpty &&
            latestEvents.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: HeaderTextButtons(
              title: data.featuresSectionTitle,
              onTap: () {
                final nav = context.read<NavProvider>();
                nav.setIndex(1);
                if (Get.currentRoute != AppRoutes.bottomNav) {
                  Get.toNamed(AppRoutes.bottomNav, arguments: {'index': 1});
                }
              },
            ),
          ),
          SizedBox(
            height: screenWidth <= 380 ? 370 : 400,
            child: AnimationLimiter(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: latestEvents.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (_, i) => AnimationConfiguration.staggeredList(
                  position: i,
                  duration: const Duration(milliseconds: 350),
                  child: SlideAnimation(
                    horizontalOffset: 24,
                    child: FadeInAnimation(
                      child: EventCardHorizontal(event: latestEvents[i]),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],

        if (data.eventSectionTitle.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: HeaderTextButtons(
              title: data.eventSectionTitle.tr,
              onTap: () {
                final nav = context.read<NavProvider>();
                nav.setIndex(1);
                if (Get.currentRoute != AppRoutes.bottomNav) {
                  Get.toNamed(AppRoutes.bottomNav, arguments: {'index': 1});
                }
              },
            ),
          ),

        SizedBox(
          height: 40,
          child: AnimationLimiter(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: categories.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 280),
                  child: SlideAnimation(
                    horizontalOffset: 16,
                    child: FadeInAnimation(
                      child: Builder(
                        builder: (context) {
                          if (index == 0) {
                            final selected = selectedCategoryId == null;
                            return FilterChipTile(
                              label: 'All'.tr,
                              selected: selected,
                              onTap: () => onSelectCategory(null),
                            );
                          }
                          final cat = categories[index - 1];
                          final selected = selectedCategoryId == cat.id;
                          return FilterChipTile(
                            label: cat.name,
                            selected: selected,
                            onTap: () => onSelectCategory(cat.id),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        const SizedBox(height: 12),
        // Events list
        SizedBox(
          height: screenWidth <= 380 ? 370 : 400,
          child: displayEvents.isEmpty
              ? Center(
                  child: Text(
                    'No events'.tr,
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                )
              : AnimationLimiter(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: displayEvents.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (_, i) => AnimationConfiguration.staggeredList(
                      position: i,
                      duration: const Duration(milliseconds: 350),
                      child: SlideAnimation(
                        horizontalOffset: 24,
                        child: FadeInAnimation(
                          child: EventCardHorizontal(event: displayEvents[i]),
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
