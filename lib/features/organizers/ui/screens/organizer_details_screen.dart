import 'package:evento_app/app/app_colors.dart';
import 'package:evento_app/features/common/ui/widgets/custom_app_bar.dart';
import 'package:evento_app/features/home/ui/widgets/event_card_horizontal.dart';
import 'package:evento_app/features/home/ui/widgets/filter_chip_title.dart';
import 'package:evento_app/features/organizers/ui/widgets/details_shimmer.dart';
import 'package:evento_app/features/organizers/ui/widgets/organizer_details_card.dart';
import 'package:evento_app/features/organizers/providers/organizer_details_provider.dart';
import 'package:flutter/material.dart';
import 'package:evento_app/features/auth/providers/auth_provider.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class OrganizerDetailsScreen extends StatelessWidget {
  final int id;
  final bool isAdmin;
  const OrganizerDetailsScreen({
    super.key,
    required this.id,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    final token = context.read<AuthProvider>().token ?? '';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      context.read<OrganizerDetailsProvider>().ensureInitialized(
        token: token,
        id: id,
        isAdmin: isAdmin,
      );
    });
    return Consumer<OrganizerDetailsProvider>(
      builder: (context, prov, _) {
        final title =
            prov.page == null || (prov.page?.organizer.name?.isEmpty ?? true)
            ? 'Organizer Details'.tr
            : (prov.page!.organizer.name ?? 'Organizer Details'.tr);

        Future<void> refresh() async {
          await context.read<OrganizerDetailsProvider>().refresh();
        }

        final selectedCategoryId = prov.selectedCategoryId;
        if (prov.loading && !prov.initialized) {
          final screenWidth = MediaQuery.of(context).size.width;
          return Scaffold(
            appBar: CustomAppBar(title: title),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Category chips shimmer (top)
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: 6,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, __) =>
                        DetailsShimmer(height: 32, width: 72, radius: 16),
                  ),
                ),
                const SizedBox(height: 12),
                // Events list shimmer (middle)
                SizedBox(
                  height: screenWidth <= 380 ? 320 : 350,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: 4,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (_, __) => DetailsShimmer(
                      height: 330,
                      width: MediaQuery.of(context).size.width * 0.8,
                      radius: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Organizer details card shimmer (bottom)
                const HeaderShimmer(),
              ],
            ),
          );
        }
        if (prov.loading && prov.initialized) {
          final screenWidth = MediaQuery.of(context).size.width;
          return Scaffold(
            appBar: CustomAppBar(title: title),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: 6,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, __) =>
                        DetailsShimmer(height: 32, width: 72, radius: 16),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: screenWidth <= 380 ? 320 : 350,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: 4,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (_, __) =>
                        DetailsShimmer(height: 330, width: 350, radius: 12),
                  ),
                ),
                const SizedBox(height: 16),
                // Organizer details card shimmer (bottom)
                const HeaderShimmer(),
              ],
            ),
          );
        }
        if (prov.page == null) {
          return Scaffold(
            appBar: CustomAppBar(title: title),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  prov.error ?? 'Failed to load organizer details'.tr,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
            ),
          );
        }
        final data = prov.page!;
        final org = data.organizer;
        final allEvents = data.eventsByCategory.values
            .expand((e) => e)
            .toList();
        final displayEvents = selectedCategoryId == null
            ? allEvents
            : (data.eventsByCategory[selectedCategoryId] ?? const []);

        final screenWidth = MediaQuery.of(context).size.width;
        return Scaffold(
          appBar: CustomAppBar(title: title),
          body: RefreshIndicator.adaptive(
            triggerMode: RefreshIndicatorTriggerMode.anywhere,
            backgroundColor: AppColors.primaryColor,
            color: Colors.white,
            onRefresh: refresh,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (displayEvents.isNotEmpty) ...[
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      itemCount: data.categories.length + 1,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          final selected = selectedCategoryId == null;
                          return FilterChipTile(
                            label: 'All',
                            selected: selected,
                            onTap: () => context
                                .read<OrganizerDetailsProvider>()
                                .setSelectedCategory(null),
                          );
                        }
                        final cat = data.categories[index - 1];
                        final selected = selectedCategoryId == cat.id;
                        return FilterChipTile(
                          label: cat.name.tr,
                          selected: selected,
                          onTap: () => context
                              .read<OrganizerDetailsProvider>()
                              .setSelectedCategory(cat.id),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                if (displayEvents.isNotEmpty)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final orientation = MediaQuery.of(context).orientation;
                      int columns;
                      if (width >= 1200) {
                        columns = 3;
                      } else if (width >= 900) {
                        columns = 3;
                      } else if (width >= 600 ||
                          orientation == Orientation.landscape) {
                        columns = 2;
                      } else {
                        columns = 1;
                      }

                      const spacing = 16.0;

                      if (columns == 1) {
                        return SizedBox(
                          height: screenWidth <= 380 ? 320 : 350,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: displayEvents.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: spacing),
                            itemBuilder: (context, index) =>
                                EventCardHorizontal(
                                  event: displayEvents[index],
                                ),
                          ),
                        );
                      }

                      // Multi-column grid for larger screens/landscape
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(top: 0, bottom: 0),
                        itemCount: displayEvents.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: spacing,
                          mainAxisSpacing: spacing,
                          mainAxisExtent: screenWidth <= 380 ? 320 : 350,
                        ),
                        itemBuilder: (context, index) => EventCardHorizontal(
                          event: displayEvents[index],
                          width: double.infinity,
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 16),
                OrganizerDetailsCard(org: org),
              ],
            ),
          ),
        );
      },
    );
  }
}
