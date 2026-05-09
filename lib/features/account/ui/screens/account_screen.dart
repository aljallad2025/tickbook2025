import 'package:evento_app/app/app_routes.dart';
import 'package:evento_app/app/app_text_styles.dart';
import 'package:evento_app/features/account/ui/widgets/dashborad_list_card.dart';
import 'package:evento_app/features/account/ui/widgets/login_gate.dart';
import 'package:evento_app/features/account/ui/widgets/profile_card.dart';
import 'package:evento_app/features/common/ui/widgets/custom_app_bar.dart';
import 'package:evento_app/features/home/ui/screens/bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:evento_app/features/auth/providers/auth_provider.dart';
import 'package:evento_app/utils/auth_aware.dart';
import 'package:evento_app/features/account/providers/account_provider.dart';
import 'package:evento_app/network_services/core/navigation_service.dart';
import 'package:evento_app/features/common/ui/widgets/custom_snack_bar_widget.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  List<Map<String, dynamic>> get dashboardItems => [
    {'title': 'Dashboard', 'icon': FontAwesomeIcons.gauge},
    {'title': 'Event Bookings', 'icon': FontAwesomeIcons.calendarDays},
    {'title': 'Wishlist', 'icon': FontAwesomeIcons.solidHeart},
    {'title': 'Support Tickets', 'icon': FontAwesomeIcons.solidEnvelope},
    {'title': 'Edit Profile', 'icon': FontAwesomeIcons.solidUser},
    {'title': 'Change Password', 'icon': FontAwesomeIcons.lock},
    {'title': 'Logout', 'icon': FontAwesomeIcons.rightFromBracket},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Account Information',
        onTap: () {
          NavigationService.pushAnimated(BottomNavBar());
        },
      ),
      body: Builder(
        builder: (context) {
          final auth = context.watch<AuthProvider>();
          final token = auth.token ?? '';
          if (token.isEmpty) {
            return const AuthAware(routeName: '/account', child: LoginGate());
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            context.read<AccountProvider>().ensureInitialized(token);
          });

          return Consumer<AccountProvider>(
            builder: (context, prov, _) {
              if (prov.lastToken != token && !prov.loading) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  context.read<AccountProvider>().ensureInitialized(token);
                });
                return const Center(child: CircularProgressIndicator());
              }

              if (prov.authRequired) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  prov.clearAuthRequired();
                  final authProv = context.read<AuthProvider>();
                  if (!authProv.navigatingToLogin) {
                    authProv.onAuthExpired(
                      from: const RouteSettings(name: '/account'),
                      message: 'Session expired. Please login again.',
                    );
                  }
                });
                return const SizedBox.shrink();
              }

              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            const ProfileCard(),
                            const SizedBox(height: 16),
                            DashboardListCard(
                              items: dashboardItems,
                              onItemTap: (ctx, title) {
                                switch (title) {
                                  case 'Dashboard':
                                    Get.toNamed(AppRoutes.dashboard);
                                    break;
                                  case 'Event Bookings':
                                    Get.toNamed(AppRoutes.bookings);
                                    break;
                                  case 'Wishlist':
                                    Get.toNamed(AppRoutes.wishlist);
                                    break;
                                  case 'Support Tickets':
                                    Get.toNamed(AppRoutes.supportTickets);
                                    break;
                                  case 'Edit Profile':
                                    Get.toNamed(AppRoutes.updateProfile);
                                    break;
                                  case 'Change Password':
                                    Get.toNamed(AppRoutes.updatePassword);
                                    break;
                                  case 'Logout':
                                    _showLogoutDialog(context);
                                }
                              },
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Settings'.tr,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () => Get.toNamed(AppRoutes.settings),
                              borderRadius: BorderRadius.circular(12),
                              child: Card(
                                color: Colors.grey.shade50,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 24,
                                    horizontal: 16,
                                  ),
                                  child: Row(
                                    children: [
                                      FaIcon(
                                        FontAwesomeIcons.gear,
                                        color: Colors.grey.shade600,
                                      ),
                                      const SizedBox(width: 16),
                                      Text(
                                        'Open Settings'.tr,
                                        style: AppTextStyles.headingSmall
                                            .copyWith(
                                              color: Colors.grey.shade800,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text("${'Confirm Logout'.tr} ?"),
        content: Text("${'Are you sure you want to logout'.tr} ?"),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Cancel".tr),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx, rootNavigator: true).pop();
              ScaffoldMessenger.of(context);
              final auth = context.read<AuthProvider>();
              auth.logout();
              Get.offAllNamed(AppRoutes.bottomNav);
              CustomSnackBar.show(context, 'Logged out'.tr);
            },
            child: Text("Logout".tr),
          ),
        ],
      ),
    );
  }
}
