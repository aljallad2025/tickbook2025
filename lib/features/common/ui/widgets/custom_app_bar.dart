import 'package:evento_app/app/assets_path.dart';
import 'package:evento_app/features/common/ui/widgets/custom_icon_button_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:evento_app/app/app_routes.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onTap;
  final bool showBackButton;
  final String icon;
  final bool showTitle;
  final bool showSkip;

  const CustomAppBar({
    super.key,
    required this.title,
    this.onTap,
    this.showBackButton = true,
    this.icon = AssetsPath.backIconSvg,
    this.showTitle = true,
    this.showSkip = false,
  });

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurStyle: BlurStyle.solid,
            spreadRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: 0,
        forceMaterialTransparency: true,
        foregroundColor: Colors.transparent,
        title: Stack(
          alignment: Alignment.center,
          children: [
            if (widget.showTitle)
              Text(
                widget.title.tr,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),

            if (widget.showBackButton)
              Align(
                alignment: isRtl ? Alignment.centerRight : Alignment.centerLeft,
                child: CustomIconButtonWidget(
                  assetPath: widget.icon,
                  flipHorizontally: isRtl,
                  onTap:
                      widget.onTap ??
                      () {
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        } else {
                          Get.offAllNamed(AppRoutes.bottomNav);
                        }
                      },
                ),
              ),

            if (widget.showSkip)
              Align(
                alignment: isRtl ? Alignment.centerLeft : Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Get.toNamed(AppRoutes.bottomNav);
                  },
                  child: Text('Skip'.tr),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
