import 'package:evento_app/app/app_colors.dart';
import 'package:evento_app/app/app_routes.dart';
import 'package:evento_app/app/assets_path.dart';
import 'package:evento_app/features/common/ui/widgets/custom_icons.dart';
import 'package:evento_app/features/common/ui/widgets/network_app_logo.dart';
import 'package:evento_app/features/common/ui/widgets/search_bar_widget.dart';
import 'package:evento_app/features/home/providers/notification_provider.dart';
import 'package:evento_app/features/organizers/providers/organizers_provider.dart';
import 'package:evento_app/features/organizers/ui/widgets/org_card_shimmer.dart';
import 'package:evento_app/features/organizers/ui/widgets/org_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class Organizers extends StatelessWidget {
  const Organizers({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OrganizersProvider>(
      builder: (context, prov, _) {
        if (!prov.initialized) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<OrganizersProvider>().ensureInitialized();
          });
        }
        final loading = prov.loading || prov.failed || !prov.initialized;
        final list = prov.items;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
            titleSpacing: 0,
            title: Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  children: [
                    const SizedBox(width: 16),
                    NetworkAppLogo(height: 30),
                    const Spacer(),
                    Stack(
                      children: [
                        CustomIcon(
                          svg: AssetsPath.notificationSvg,
                          onTap: () {
                            Get.toNamed(AppRoutes.notifications);
                          },
                        ),
                        if (context.select<NotificationProvider, bool>(
                          (provider) => provider.hasUnread,
                        ))
                          Positioned(
                            right: 6,
                            top: 6,
                            child: CircleAvatar(
                              radius: 6,
                              backgroundColor: AppColors.primaryColor,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
              ],
            ),
          ),
          body: RefreshIndicator.adaptive(
            backgroundColor: AppColors.primaryColor,
            color: Colors.white,
            triggerMode: RefreshIndicatorTriggerMode.anywhere,
            onRefresh: () => context.read<OrganizersProvider>().refresh(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SearchBarWidget(
                      borderColor: Colors.grey.shade400,
                      backgroundColor: Colors.grey.shade100,
                      textFieldFillColor: Colors.white,
                      iconColor: Colors.grey.shade600,
                      hintText: '${'Search'.tr} ${'Organizers'.tr}',
                      controller: context
                          .read<OrganizersProvider>()
                          .searchController,
                      showClearButton: context
                          .watch<OrganizersProvider>()
                          .query
                          .isNotEmpty,
                      onChanged: prov.setQuery,
                      onSubmitted: prov.setQuery,
                      onClear: () {
                        prov.clearQuery();
                      },
                      showFilterButton: false,
                    ),
                    SizedBox(height: 16),
                    loading
                        ? SizedBox(
                            height: 18,
                            width: 180,
                            child: Shimmer.fromColors(
                              baseColor: Colors.grey.shade300,
                              highlightColor: Colors.grey.shade100,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                          )
                        : Text(
                            '${'Total organizer showing'.tr}: ${list.where((organizer) => organizer.status != '0').length}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                    SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth;
                        final orientation = MediaQuery.of(context).orientation;
                        int cols;
                        if (width >= 1200) {
                          cols = 4;
                        } else if (width >= 900) {
                          cols = 3;
                        } else if (width >= 600 ||
                            orientation == Orientation.landscape) {
                          cols = 3;
                        } else if (width >= 360) {
                          cols = 2;
                        } else {
                          cols = 1;
                        }
                        const mainSpacing = 8.0;
                        const crossSpacing = 8.0;

                        if (loading) {
                          return MasonryGridView.count(
                            crossAxisCount: cols,
                            mainAxisSpacing: mainSpacing,
                            crossAxisSpacing: crossSpacing,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: 6,
                            itemBuilder: (context, index) =>
                                const OrgCardShimmer(),
                          );
                        }
                        return MasonryGridView.count(
                          crossAxisCount: cols,
                          mainAxisSpacing: mainSpacing,
                          crossAxisSpacing: crossSpacing,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: list.length,
                          itemBuilder: (context, index) {
                            final organizer = list[index];
                            return Visibility(
                              visible: organizer.status == '1',
                              replacement: const SizedBox.shrink(),
                              child: OrgCardWidget(organizers: organizer),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
