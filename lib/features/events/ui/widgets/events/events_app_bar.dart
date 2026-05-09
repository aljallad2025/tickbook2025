import 'package:evento_app/app/app_colors.dart';
import 'package:evento_app/app/app_routes.dart';
import 'package:evento_app/app/assets_path.dart';
import 'package:evento_app/features/common/ui/widgets/custom_icons.dart';
import 'package:evento_app/features/common/ui/widgets/network_app_logo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EventAppBar extends StatelessWidget implements PreferredSizeWidget {
  const EventAppBar({super.key, required this.hasUnread});

  final bool hasUnread;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
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
              const SizedBox(width: 16),
            ],
          ),
        ],
      ),
    );
  }
}
