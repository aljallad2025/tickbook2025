import 'package:evento_app/app/app_colors.dart';
import 'package:evento_app/features/account/ui/widgets/login_gate.dart';
import 'package:evento_app/features/bookings/data/models/booking_models.dart';
import 'package:evento_app/features/bookings/ui/widgets/booking_card.dart';
import 'package:evento_app/features/common/ui/widgets/custom_app_bar.dart';
import 'package:evento_app/features/common/ui/widgets/header_text_buttons.dart';
import 'package:evento_app/features/common/ui/widgets/info_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:evento_app/features/auth/providers/auth_provider.dart';
import 'package:evento_app/app/app_routes.dart';
import 'package:evento_app/utils/auth_aware.dart';
import 'package:evento_app/features/account/providers/dashboard_provider.dart';
import 'package:get/get.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final token = context.watch<AuthProvider>().token ?? '';

    // Ensure provider is initialized after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      context.read<DashboardProvider>().ensureInitialized(token);
    });

    return Scaffold(
      appBar: CustomAppBar(
        title: context.watch<DashboardProvider>().data?.pageTitle ?? '',
      ),
      body: token.isEmpty
          ? const AuthAware(routeName: '/dashboard', child: LoginGate())
          : Consumer<DashboardProvider>(
              builder: (context, prov, _) {
                if (prov.loading && !prov.initialized) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (prov.authRequired) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    final auth = context.read<AuthProvider>();
                    if (!auth.navigatingToLogin) {
                      auth.onAuthExpired(
                        from: const RouteSettings(name: '/dashboard'),
                        message: prov.error,
                      );
                    }
                  });
                  return const SizedBox.shrink();
                }

                final data = prov.data;
                final user = data?.authUser;
                final List<BookingItemModel> bookings =
                    data?.bookings ?? const [];

                if (prov.loading && data == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (prov.error != null && data == null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Failed to load dashboard',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                  );
                }

                return RefreshIndicator.adaptive(
                  backgroundColor: AppColors.primaryColor,
                  color: Colors.white,
                  onRefresh: () => prov.refresh(token),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InformationCardWidget(
                            showArrow: false,
                            textAlign: TextAlign.start,
                            leftFlex: 3,
                            rightFlex: 6,
                            cardTitle: 'Account Information',
                            infoEntries: [
                              MapEntry(
                                'Name',
                                (user?.fullName ?? '').isEmpty
                                    ? '\u2014'
                                    : user!.fullName,
                              ),
                              MapEntry(
                                'Username',
                                (user?.username ?? '').isEmpty
                                    ? '\u2014'
                                    : user!.username,
                              ),
                              MapEntry(
                                'Email',
                                (user?.email ?? '').isEmpty
                                    ? '\u2014'
                                    : user!.email,
                              ),
                              MapEntry(
                                'Phone',
                                (user?.phone ?? '').isEmpty
                                    ? '\u2014'
                                    : user!.phone,
                              ),
                              MapEntry(
                                'Address',
                                (user?.address ?? '').isEmpty
                                    ? '\u2014'
                                    : user!.address,
                              ),
                              MapEntry(
                                'Country',
                                (user?.country ?? '').isEmpty
                                    ? '\u2014'
                                    : user!.country,
                              ),
                              MapEntry(
                                'City',
                                (user?.city ?? '').isEmpty
                                    ? '\u2014'
                                    : user!.city,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          HeaderTextButtons(
                            title: 'Recent Bookings',
                            onTap: () {
                              Get.toNamed(AppRoutes.bookings);
                            },
                          ),
                          const SizedBox(height: 8),
                          if (bookings.isEmpty)
                            Text(
                              'No recent bookings',
                              style: TextStyle(color: Colors.grey.shade600),
                            )
                          else
                            ...bookings
                                .take(3)
                                .map((b) => BookingCard(item: b)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
