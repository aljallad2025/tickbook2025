import 'package:evento_app/app/app_colors.dart';
import 'package:evento_app/app/assets_path.dart';
import 'package:evento_app/features/common/ui/widgets/custom_icons.dart';
import 'package:evento_app/features/common/ui/widgets/custom_snack_bar_widget.dart';
import 'package:evento_app/features/common/ui/widgets/dropdown_alert_dialog.dart';
import 'package:evento_app/features/common/ui/widgets/network_app_logo.dart';
import 'package:evento_app/features/home/providers/locale_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:evento_app/app/app_routes.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool hasUnread;
  const HomeAppBar({super.key, required this.hasUnread});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 2,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      titleSpacing: 16,
      title: NetworkAppLogo(height: 30),
      actions: [
        Stack(
          alignment: Alignment.center,
          children: [
            CustomIcon(
              svg: AssetsPath.notificationSvg,
              onTap: () => Get.toNamed(AppRoutes.notifications),
            ),
            if (hasUnread)
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
        const SizedBox(width: 12),
        CustomIcon(
          svg: AssetsPath.languageSvg,
          onTap: () async {
            final rootContext = context;
            final lp = rootContext.read<LocaleProvider>();
            final currentCode = lp.locale.languageCode;
            final languages = lp.languages;
            final names = languages.isNotEmpty
                ? languages.map((l) => l.name).toList(growable: false)
                : <String>['English', 'Arabic'];
            String initialName;
            if (languages.isNotEmpty) {
              initialName = (languages.firstWhere(
                (l) => l.code.toLowerCase() == currentCode.toLowerCase(),
                orElse: () => languages.first,
              )).name;
            } else {
              initialName = currentCode.toLowerCase() == 'ar'
                  ? 'Arabic'
                  : 'English';
            }

            String? nextCode;
            String? nextName;

            await showDialog(
              context: rootContext,
              builder: (dialogCtx) => DropdownAlertDialog(
                dialogType: DialogType.dropdown,
                drpDownTitle: 'Language'.tr,
                title: 'Language'.tr,
                btnTitle: 'Save Changes'.tr,
                items: names,
                initialValue: initialName,
                onConfirm: (selectedValue) {
                  final bool hasChoice =
                      selectedValue is String && selectedValue.isNotEmpty;
                  if (!hasChoice) {
                    nextCode = 'en';
                    nextName = 'English';
                    return;
                  }
                  nextName = selectedValue;
                  if (languages.isNotEmpty) {
                    final match = languages.firstWhere(
                      (l) => l.name == selectedValue,
                      orElse: () => languages.first,
                    );
                    nextCode = match.code;
                  } else {
                    nextCode = selectedValue.toLowerCase() == 'arabic'
                        ? 'ar'
                        : 'en';
                  }
                },
              ),
            );

            if (nextCode != null && context.mounted) {
              await rootContext.read<LocaleProvider>().setLocale(
                Locale(nextCode!),
              );
              if (context.mounted) {
                CustomSnackBar.show(
                  rootContext,
                  '${"Language changed to".tr} ${nextName ?? 'English'}',
                );
              }
            }
          },
        ),
        const SizedBox(width: 12),
      ],
    );
  }
}
