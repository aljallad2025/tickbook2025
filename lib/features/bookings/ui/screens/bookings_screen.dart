import 'package:evento_app/app/app_colors.dart';
import 'package:evento_app/app/app_routes.dart';
import 'package:get/get.dart';
import 'package:evento_app/features/common/ui/widgets/custom_app_bar.dart';
import 'package:evento_app/features/common/ui/widgets/search_bar_widget.dart';
import 'package:evento_app/features/bookings/providers/bookings_provider.dart';
import 'package:evento_app/features/bookings/ui/widgets/booking_card.dart';
import 'package:evento_app/features/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:evento_app/utils/auth_aware.dart';
import 'package:evento_app/features/support/ui/widgets/shimmer_list.dart';

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final token = context.watch<AuthProvider>().token ?? '';
    final p = context.read<BookingsProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!p.initialized || token.isNotEmpty) {
        p.ensureInitialized(token);
      }
    });

    final noToken = token.isEmpty;
    final pageTitle = context.watch<BookingsProvider>().pageTitle;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else {
          Get.offAllNamed(AppRoutes.accountTab);
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(
          title: pageTitle,
          onTap: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Get.offAllNamed(AppRoutes.accountTab);
            }
          },
        ),
        body: noToken
            ? const AuthAware(routeName: '/bookings', child: SizedBox.shrink())
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    SearchBarWidget(
                      borderColor: Colors.grey.shade400,
                      backgroundColor: Colors.grey.shade100,
                      textFieldFillColor: Colors.white,
                      iconColor: Colors.grey.shade600,
                      hintText: 'Search Bookings',
                      onChanged: (q) =>
                          context.read<BookingsProvider>().setQuery(q),
                      showFilterButton: false,
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Consumer<BookingsProvider>(
                        builder: (context, prov, _) {
                          if (token.isNotEmpty && prov.lastToken != token) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              context
                                  .read<BookingsProvider>()
                                  .ensureInitialized(token);
                            });
                            return const ShimmerList();
                          }
                          if (prov.loading) {
                            return const ShimmerList();
                          }

                          if (prov.authRequired) {
                            WidgetsBinding.instance.addPostFrameCallback((
                              _,
                            ) async {
                              final authProv = context.read<AuthProvider>();
                              context
                                  .read<BookingsProvider>()
                                  .clearAuthRequired();
                              if (!authProv.navigatingToLogin) {
                                await authProv.onAuthExpired(
                                  from: const RouteSettings(name: '/bookings'),
                                  message:
                                      'Session expired. Please login again.',
                                );
                              }
                            });
                            return const SizedBox();
                          }

                          final items = prov.bookings;
                          final emptyMsg = prov.error == null
                              ? 'No bookings found'
                              : 'Failed to load';

                          return RefreshIndicator.adaptive(
                            backgroundColor: AppColors.primaryColor,
                            color: Colors.white,
                            triggerMode: RefreshIndicatorTriggerMode.anywhere,
                            onRefresh: () async =>
                                prov.refresh(token), // must return Future<void>
                            child: ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              // keep the list "scrollable" even when empty
                              itemCount: items.isEmpty ? 1 : items.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                if (items.isEmpty) {
                                  // Put your empty state INSIDE the list so pull-to-refresh still works
                                  return SizedBox(
                                    height:
                                        MediaQuery.of(context).size.height *
                                        0.5, // gives drag room
                                    child: Center(
                                      child: Text(
                                        emptyMsg,
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                final item = items[index];
                                return BookingCard(
                                  item: item,
                                  onTap: () {
                                    Get.toNamed(
                                      AppRoutes.bookingDetails,
                                      arguments: {
                                        'bookingId': item.id,
                                        'eventTitle': item.eventTitle ?? '',
                                      },
                                    );
                                  },
                                  accentColor: Colors.deepPurple.shade700,
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
