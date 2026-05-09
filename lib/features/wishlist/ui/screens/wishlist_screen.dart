import 'package:evento_app/app/app_colors.dart';
import 'package:evento_app/features/common/ui/widgets/custom_app_bar.dart';
import 'package:evento_app/features/common/ui/widgets/search_bar_widget.dart';
import 'package:evento_app/features/events/ui/screens/event_details_screen.dart';
import 'package:evento_app/features/wishlist/providers/wishlist_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:evento_app/features/common/ui/widgets/shimmer_widgets.dart';
import 'package:evento_app/network_services/core/navigation_service.dart';
import 'package:evento_app/features/common/ui/widgets/custom_snack_bar_widget.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: context.watch<WishlistProvider>().data?.pageTitle ?? '',
      ),
      body: Consumer<WishlistProvider>(
        builder: (context, wp, _) {
          if (!wp.loading && wp.data == null && wp.error == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<WishlistProvider>().fetch();
            });
          }

          if (wp.loading && wp.data == null) {
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: 6,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, __) => const ShimmerListCard(),
            );
          }
          if (wp.error != null && wp.data == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Failed to load wishlists'.tr,
                  style: TextStyle(color: Colors.red.shade400),
                ),
              ),
            );
          }
          final items = wp.items;
          return RefreshIndicator.adaptive(
            backgroundColor: AppColors.primaryColor,
            color: Colors.white,
            onRefresh: () => context.read<WishlistProvider>().fetch(),
            child: Column(
              children: [
                SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SearchBarWidget(
                    borderColor: Colors.grey.shade400,
                    backgroundColor: Colors.grey.shade100,
                    textFieldFillColor: Colors.white,
                    iconColor: Colors.grey.shade600,
                    hintText: '${'Search'.tr} ${'Wishlist'.tr}',
                    controller: context
                        .read<WishlistProvider>()
                        .searchController,
                    showClearButton: context
                        .watch<WishlistProvider>()
                        .query
                        .isNotEmpty,
                    onChanged: (q) =>
                        context.read<WishlistProvider>().setQuery(q),
                    onSubmitted: (q) =>
                        context.read<WishlistProvider>().setQuery(q),
                    onClear: () {
                      context.read<WishlistProvider>().clearQuery();
                    },
                    showFilterButton: false,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: items.isEmpty
                        ? ListView(
                            children: [
                              SizedBox(height: 120),
                              Center(child: Text('No items in wishlist'.tr)),
                            ],
                          )
                        : ListView.separated(
                            itemCount: items.length,
                            separatorBuilder: (_, __) => SizedBox(height: 4),
                            itemBuilder: (context, index) {
                              final wishlist = items[index];
                              return InkWell(
                                onTap: () {
                                  NavigationService.pushAnimated(
                                    EventDetailsScreen(
                                      eventId: wishlist.eventId,
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Card(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      color: Colors.grey.shade200,
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundImage: NetworkImage(
                                            wishlist.image,
                                          ),
                                          radius: 28,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            wishlist.title,
                                            style: TextStyle(fontSize: 16),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        IconButton(
                                          style: IconButton.styleFrom(
                                            backgroundColor: Colors.red.shade50,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.redAccent,
                                          ),
                                          onPressed: () async {
                                            final prov = context
                                                .read<WishlistProvider>();
                                            await prov.removeFromWishlist(
                                              wishlistId: wishlist.id,
                                              eventId: wishlist.eventId,
                                            );
                                            final res =
                                                prov.deleteResultNotifier.value;
                                            if (res != null &&
                                                context.mounted) {
                                              CustomSnackBar.show(
                                                context,
                                                res.message,
                                              );
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}