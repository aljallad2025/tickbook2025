import 'package:evento_app/app/app_colors.dart';
import 'package:evento_app/app/app_text_styles.dart';
import 'package:evento_app/features/common/ui/widgets/custom_app_bar.dart';
import 'package:evento_app/features/common/ui/widgets/custom_cpi.dart';
import 'package:evento_app/features/home/providers/locale_provider.dart';
import 'package:evento_app/network_services/core/basic_service.dart';
import 'package:evento_app/network_services/core/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:evento_app/app/app_theme_data.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Settings'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: NotificationService.notificationsEnabled,
            builder: (context, enabled, _) => Card(
              color: Colors.grey.shade50,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                title: Text(
                  'Enable Notifications'.tr,
                  style: AppTextStyles.headingSmall.copyWith(
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  enabled
                      ? 'You will receive notifications'.tr
                      : 'Notifications are disabled'.tr,
                ),
                trailing: Switch(
                  value: enabled,
                  activeThumbColor: AppColors.primaryColor,
                  activeTrackColor: AppColors.primaryColor.withValues(
                    alpha: 0.4,
                  ),
                  onChanged: (v) async {
                    await NotificationService.setNotificationsEnabled(v);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          v
                              ? 'Notifications enabled.'.tr
                              : 'Notifications are disabled'.tr,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          Card(
            color: Colors.grey.shade50,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Consumer<LocaleProvider>(
                builder: (context, lp, _) {
                  final items = lp.languages;
                  final current = lp.locale.languageCode;
                  return Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Language'.tr,
                              style: AppTextStyles.headingSmall.copyWith(
                                color: Colors.grey.shade800,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                borderRadius: BorderRadius.circular(12),
                                isExpanded: true,
                                value: current,
                                items: [
                                  for (final lang in items)
                                    DropdownMenuItem<String>(
                                      value: lang.code,
                                      child: Text(lang.name),
                                    ),
                                ],
                                onChanged: (code) async {
                                  if (code == null) return;
                                  await lp.setLocale(Locale(code));
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 12),

          InkWell(
            borderRadius: BorderRadius.circular(12),
            child: Card(
              color: Colors.red,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    Icon(Icons.refresh, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      'Restart App'.tr,
                      style: AppTextStyles.headingSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            onTap: () => _rebootWithLogoReload(context),
          ),
        ],
      ),
    );
  }

  void _rebootWithLogoReload(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CustomCPI()),
    );
    bool ok = false;
    try {
      // Step 1: Force remote fetch so latest URLs & color persist.
      await BasicService.fetchBasic(forceReload: true);
      // Step 2: Ensure logo/favicon bytes reflect any URL changes.
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
    } finally {
      if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Branding refreshed.'.tr
              : 'Branding refresh failed; using previous values.'.tr,
        ),
      ),
    );

    try {
      Get.forceAppUpdate();
    } catch (_) {}
  }
}
