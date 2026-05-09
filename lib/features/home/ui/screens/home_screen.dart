import 'package:evento_app/app/app_colors.dart';
import 'package:evento_app/app/app_routes.dart';
import 'package:evento_app/app/app_theme_data.dart';
import 'package:evento_app/features/common/ui/widgets/custom_snack_bar_widget.dart';
import 'package:evento_app/features/common/ui/widgets/search_bar_widget.dart';
import 'package:evento_app/features/events/ui/widgets/events/events_filters_sheet.dart';
import 'package:evento_app/features/home/providers/notification_provider.dart';
import 'package:evento_app/features/home/ui/sections/category_section.dart';
import 'package:evento_app/features/home/ui/sections/event_section.dart';
import 'package:evento_app/features/common/ui/widgets/header_text_buttons.dart';
import 'package:evento_app/features/home/ui/widgets/home_appbar.dart';
import 'package:evento_app/features/home/ui/widgets/home_shimmer_animation.dart';
import 'package:evento_app/network_services/core/basic_service.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:evento_app/app/assets_path.dart';
import 'package:evento_app/features/home/providers/home_provider.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:evento_app/features/home/providers/locale_provider.dart';
import 'package:evento_app/features/events/providers/events_provider.dart';
import 'package:evento_app/features/home/providers/nav_provider.dart';
import 'package:evento_app/features/categories/models/category_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const SystemUiOverlayStyle _overlayCollapsed = SystemUiOverlayStyle(
    statusBarColor: Colors.white,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  );

  @override
  Widget build(BuildContext context) {
    context.watch<HomeProvider>();
    final homeProvider = context.read<HomeProvider>();
    if (!homeProvider.initialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!homeProvider.initialized) homeProvider.ensureFetched(context);
      });
    }

    final hasUnread = context.select<NotificationProvider, bool>(
      (np) => np.hasUnread,
    );
    context.watch<LocaleProvider>();

    final appBarInset = kToolbarHeight;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: HomeScreen._overlayCollapsed,
      child: Scaffold(
        appBar: HomeAppBar(hasUnread: hasUnread),
        body: Consumer<HomeProvider>(
          builder: (context, hp, _) {
            if (hp.loading || hp.failed || hp.data == null) {
              return RefreshIndicator.adaptive(
                triggerMode: RefreshIndicatorTriggerMode.anywhere,
                backgroundColor: AppColors.primaryColor,
                color: Colors.white,
                onRefresh: () {
                  _rebootWithLogoReload(context);
                  return context.read<HomeProvider>().refresh();
                },
                displacement: appBarInset,
                edgeOffset: 0,
                child: const HomeShimmerAnimation(),
              );
            }
            final data = hp.data!;

            final categories = data.categories;
            final eventsAll = data.eventsAll;
            final latestEvents = data.latestEvents;
            final titles = data.sectionTitles;

            return RefreshIndicator.adaptive(
              triggerMode: RefreshIndicatorTriggerMode.anywhere,
              backgroundColor: AppColors.primaryColor,
              color: Colors.white,
              onRefresh: () {
                _rebootWithLogoReload(context);
                return context.read<HomeProvider>().refresh();
              },
              displacement: appBarInset,
              edgeOffset: 0,
              child: ListView(
                padding: EdgeInsets.zero,
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                children: [
                  const SizedBox(height: 12),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SearchBarWidget(
                          borderColor: Colors.grey.shade400,
                          backgroundColor: Colors.grey.shade100,
                          textFieldFillColor: Colors.white,
                          iconColor: Colors.grey.shade600,
                          controller: context
                              .read<HomeProvider>()
                              .searchController,
                          showClearButton: context
                              .watch<HomeProvider>()
                              .searchText
                              .isNotEmpty,
                          onClear: () {
                            context.read<HomeProvider>().clearSearchText();
                            FocusScope.of(context).unfocus();
                          },
                          onChanged: (value) =>
                              context.read<HomeProvider>().setSearchText(value),
                          onSubmitted: (value) {
                            final eventsProv = context.read<EventsProvider>();
                            final nav = context.read<NavProvider>();
                            final cats = data.categories;
                            final q = value.trim();
                            final lower = q.toLowerCase();
                            final match = cats.firstWhere(
                              (c) =>
                                  c.name.toLowerCase() == lower ||
                                  c.slug.toLowerCase() == lower,
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

                            void goToEvents() {
                              context.read<HomeProvider>().clearSearchText();
                              if (nav.index != 1) nav.setIndex(1);
                              if (Get.currentRoute != AppRoutes.bottomNav) {
                                Get.toNamed(
                                  AppRoutes.bottomNav,
                                  arguments: {'index': 1},
                                );
                              }
                            }

                            if (match.id != -1) {
                              if (!eventsProv.initialized) {
                                eventsProv.ensureInitialized(perPage: 15).then((
                                  _,
                                ) {
                                  eventsProv.setCategoryFilter(
                                    id: match.id,
                                    name: match.name,
                                    slug: match.slug,
                                  );
                                  eventsProv.clearQuery();
                                });
                              } else {
                                eventsProv.setCategoryFilter(
                                  id: match.id,
                                  name: match.name,
                                  slug: match.slug,
                                );
                                eventsProv.clearQuery();
                              }
                              goToEvents();
                            } else {
                              if (!eventsProv.initialized) {
                                eventsProv.ensureInitialized(perPage: 15).then((
                                  _,
                                ) {
                                  eventsProv.search(value);
                                });
                              } else {
                                eventsProv.search(value);
                              }
                              goToEvents();
                            }
                          },
                          onFilterTap: () {
                            openEventsFilterSheet(
                              context,
                              onApplied: () {
                                final nav = context.read<NavProvider>();
                                if (nav.index != 1) nav.setIndex(1);
                                if (Get.currentRoute != AppRoutes.bottomNav) {
                                  Get.toNamed(
                                    AppRoutes.bottomNav,
                                    arguments: {'index': 1},
                                  );
                                }
                              },
                            );
                          },
                        ),
                      ),
                      Container(
                        height: 200,
                        width: double.infinity,
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey.shade200,
                          image: DecorationImage(
                            image: (() {
                              final bg = data.hero?.backgroundImage ?? '';
                              ImageProvider<Object> provider;
                              if (bg.isNotEmpty &&
                                  (bg.startsWith('http://') ||
                                      bg.startsWith('https://'))) {
                                provider = CachedNetworkImageProvider(bg);
                              } else {
                                provider = const AssetImage(
                                  AssetsPath.errorImage,
                                );
                              }
                              return provider;
                            })(),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                              Colors.black.withValues(alpha: 0.5),
                              BlendMode.srcOver,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                textAlign: TextAlign.center,
                                data.hero?.firstTitle ?? '',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(1, 1),
                                      blurRadius: 4,
                                      color: Colors.black45,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                textAlign: TextAlign.center,
                                data.hero?.secondTitle ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 40,
                                width: 120,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    backgroundColor: AppColors.primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  onPressed: () {
                                    final nav = context.read<NavProvider>();
                                    nav.setIndex(1);
                                    if (Get.currentRoute !=
                                        AppRoutes.bottomNav) {
                                      Get.toNamed(
                                        AppRoutes.bottomNav,
                                        arguments: {'index': 1},
                                      );
                                    }
                                  },
                                  child: Text(
                                    data.hero?.firstButton ?? '',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      if (categories.isNotEmpty &&
                          titles?.categorySectionTitle != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: HeaderTextButtons(
                            title: titles!.categorySectionTitle,
                            onTap: () {
                              Get.toNamed(AppRoutes.allCategories);
                            },
                          ),
                        ),

                      CategoriesSection(categories: categories),

                      if (eventsAll.isNotEmpty && titles != null)
                        EventsSectionWithFilter(
                          data: titles,
                          allEvents: eventsAll,
                          latestEvents: latestEvents,
                          eventsByCategory: data.eventsByCategory,
                          categories: categories,
                          selectedCategoryId: hp.selectedCategoryId,
                          onSelectCategory: hp.selectCategory,
                        ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _rebootWithLogoReload(BuildContext context) async {
    bool ok = false;
    try {
      await BasicService.fetchBasic(forceReload: true);
      await BasicService.ensureBrandingCached(force: true);

      try {
        String? pHex = await BasicService.getCachedPrimaryColorHex();
        Color? parseHex(String? hex) {
          if (hex == null || hex.isEmpty) return null;
          var h = hex.replaceAll('#', '').trim();
          if (h.length == 6) h = 'FF$h';
          try {
            return Color(int.parse(h, radix: 16));
          } catch (_) {
            return null;
          }
        }

        final p = parseHex(pHex);
        if (p != null) {
          AppColors.applyBrand(primary: p);
          Get.changeTheme(AppThemeData.lightTheme);
        }
      } catch (_) {}
      ok = true;
    } catch (_) {
      ok = false;
    }
    if (!context.mounted) return;
    CustomSnackBar.show(
      context,
      ok
          ? 'Branding refreshed.'.tr
          : 'Branding refresh failed; using previous values.'.tr,
    );

    try {
      Get.forceAppUpdate();
    } catch (_) {}
  }
}
