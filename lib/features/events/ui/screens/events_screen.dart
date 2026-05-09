import 'package:evento_app/app/app_colors.dart';
import 'package:evento_app/features/categories/models/category_model.dart';
import 'package:evento_app/features/common/ui/widgets/search_bar_widget.dart';
import 'package:evento_app/features/events/providers/events_provider.dart';
import 'package:evento_app/features/events/ui/widgets/events/event_card.dart';
import 'package:evento_app/features/home/ui/widgets/event_card_horizontal.dart';
import 'package:evento_app/features/events/ui/widgets/events/events_app_bar.dart';
import 'package:evento_app/features/events/ui/widgets/events/events_filters_sheet.dart';
import 'package:evento_app/features/events/ui/widgets/events/events_shimmer.dart';
import 'package:evento_app/features/events/ui/widgets/events/filter_chips.dart';
import 'package:evento_app/features/home/providers/home_provider.dart';
import 'package:get/get.dart';
import 'package:evento_app/features/events/data/models/event_item_model.dart';
import 'package:evento_app/features/home/providers/notification_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final eventsProvider = context.read<EventsProvider>();

    final queryText =
        context.select<EventsProvider, String?>((p) => p.query) ?? '';
    final searchController = TextEditingController(text: queryText)
      ..selection = TextSelection.fromPosition(
        TextPosition(offset: queryText.length),
      );
    final bool showClear = queryText.isNotEmpty;
    final args = Get.arguments;
    if (args is Map) {
      int? catId;
      String? catName;
      if (args['categoryId'] is int) catId = args['categoryId'] as int;
      if (args['categoryName'] is String) {
        catName = args['categoryName'] as String;
      }
      String? catSlug;
      if (args['categorySlug'] is String) {
        catSlug = args['categorySlug'] as String;
      }

      final wantFilter =
          (catName != null && catName.trim().isNotEmpty) || catId != null;
      if (wantFilter) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          eventsProvider.setCategoryFilter(
            id: catId,
            name: catName,
            slug: catSlug,
          );
        });
      }
    }

    if (!eventsProvider.initialized) {
      final hasActive =
          (eventsProvider.query?.isNotEmpty ?? false) ||
          (eventsProvider.categoryId != null) ||
          ((eventsProvider.categoryName ?? '').trim().isNotEmpty) ||
          ((eventsProvider.categorySlug ?? '').trim().isNotEmpty) ||
          ((eventsProvider.country ?? '').isNotEmpty) ||
          ((eventsProvider.stateName ?? '').isNotEmpty) ||
          ((eventsProvider.city ?? '').isNotEmpty) ||
          ((eventsProvider.eventType ?? '').isNotEmpty) ||
          ((eventsProvider.fromDate ?? '').isNotEmpty) ||
          ((eventsProvider.toDate ?? '').isNotEmpty) ||
          (eventsProvider.priceMinSelected != null) ||
          (eventsProvider.priceMaxSelected != null);

      if (!hasActive) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!eventsProvider.initialized) {
            eventsProvider.ensureInitialized(perPage: 15);
          }
        });
      }
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: EventAppBar(
          hasUnread: context.select<NotificationProvider, bool>(
            (p) => p.hasUnread,
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SearchBarWidget(
                    borderColor: Colors.grey.shade400,
                    backgroundColor: Colors.grey.shade100,
                    textFieldFillColor: Colors.white,
                    iconColor: Colors.grey.shade600,
                    controller: searchController,
                    showClearButton: showClear,
                    onChanged: (value) =>
                        context.read<EventsProvider>().setQuery(value),
                    onSubmitted: (value) {
                      final eventsProv = context.read<EventsProvider>();
                      final hp = context.read<HomeProvider>();
                      final cats =
                          hp.data?.categories ?? const <CategoryModel>[];
                      final q = value.trim();
                      final match = cats.firstWhere(
                        (c) =>
                            c.name.toLowerCase() == q.toLowerCase() ||
                            c.slug.toLowerCase() == q.toLowerCase(),
                        orElse: () => CategoryModel(
                          id: -1,
                          name: '',
                          languageId: 0,
                          image: '',
                          slug: '',
                          status: 1,
                          serialNumber: 0,
                          isFeatured: 'no',
                          createdAt: DateTime.now(),
                          updatedAt: DateTime.now(),
                        ),
                      );
                      if (match.id != -1) {
                        eventsProv.setCategoryFilter(
                          id: match.id,
                          name: match.name,
                          slug: match.slug,
                        );
                        eventsProv.clearQuery();
                      } else {
                        eventsProv.search(value);
                      }
                    },
                    onClear: () {
                      searchController.clear();
                      context.read<EventsProvider>().clearQuery();
                      FocusScope.of(context).unfocus();
                    },
                    onFilterTap: () => _openFilterSheet(context),
                  ),
                  const SizedBox(height: 8),
                  const ActiveFiltersStrip(),
                ],
              ),
            ),
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  final p = context.read<EventsProvider>();
                  if (notification.metrics.pixels >=
                          notification.metrics.maxScrollExtent - 300 &&
                      !p.loadingMore &&
                      p.hasMore) {
                    p.loadMore();
                  }
                  return false;
                },
                child: Consumer<EventsProvider>(
                  builder: (context, p, _) {
                    if (p.loading || p.failed || !p.initialized) {
                      return RefreshIndicator.adaptive(
                        triggerMode: RefreshIndicatorTriggerMode.anywhere,
                        backgroundColor: AppColors.primaryColor,
                        color: Colors.white,
                        onRefresh: () async =>
                            context.read<EventsProvider>().init(perPage: 15),
                        child: const EventsShimmerList(),
                      );
                    }

                    final events = p.events;
                    if (events.isEmpty) {
                      return RefreshIndicator.adaptive(
                        triggerMode: RefreshIndicatorTriggerMode.anywhere,
                        backgroundColor: AppColors.primaryColor,
                        color: Colors.white,
                        onRefresh: () async =>
                            context.read<EventsProvider>().init(perPage: 15),
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          children: [
                            const SizedBox(height: 120),
                            Center(
                              child: Text(
                                'No Events Found'.tr,
                                style:
                                    TextStyle(color: Colors.grey.shade500),
                              ),
                            ),
                            const SizedBox(height: 120),
                          ],
                        ),
                      );
                    }

                    return Stack(
                      children: [
                        _eventsGrid(context, events),
                        if (p.loadingMore)
                          const Positioned(
                            bottom: 12,
                            left: 0,
                            right: 0,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openFilterSheet(BuildContext context) => openEventsFilterSheet(context);
  RefreshIndicator _eventsGrid(
    BuildContext context,
    final List<EventItemModel> events,
  ) {
    return RefreshIndicator.adaptive(
      triggerMode: RefreshIndicatorTriggerMode.anywhere,
      backgroundColor: AppColors.primaryColor,
      color: Colors.white,
      onRefresh: () async => context.read<EventsProvider>().init(perPage: 15),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final orientation = MediaQuery.of(context).orientation;
          int columns;
          if (width >= 1200) {
            columns = 3;
          } else if (width >= 900) {
            columns = 3;
          } else if (width >= 600 || orientation == Orientation.landscape) {
            columns = 2;
          } else {
            columns = 1;
          }

          const horizontalPadding = 16.0;
          const verticalPadding = 8.0;
          const spacing = 16.0;

          if (columns == 1) {
            return AnimationLimiter(
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                itemCount: events.length,
                separatorBuilder: (_, __) => const SizedBox(height: spacing),
                itemBuilder: (context, index) {
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 350),
                    child: SlideAnimation(
                      verticalOffset: 20,
                      child: FadeInAnimation(
                        // Portrait phones: use compact horizontal row card
                        child: EventCard(event: events[index]),
                      ),
                    ),
                  );
                },
              ),
            );
          }

          // Fixed card height across large screens and landscape
          const fixedCardHeight = 380.0;

          return SizedBox(
            child: AnimationLimiter(
              child: GridView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                itemCount: events.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: spacing,
                  mainAxisSpacing: spacing,
                  mainAxisExtent: fixedCardHeight,
                ),
                itemBuilder: (context, index) {
                  return AnimationConfiguration.staggeredGrid(
                    position: index,
                    columnCount: columns,
                    duration: const Duration(milliseconds: 350),
                    child: SlideAnimation(
                      verticalOffset: 20,
                      child: FadeInAnimation(
                        child: EventCardHorizontal(
                          event: events[index],
                          width: double.infinity,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
