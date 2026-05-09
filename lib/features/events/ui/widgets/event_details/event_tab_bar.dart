import 'package:evento_app/app/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EventTabBar extends StatelessWidget {
  const EventTabBar({super.key, this.controller});
  final TabController? controller;
  @override
  Widget build(BuildContext context) {
    final ctrl = controller ?? DefaultTabController.of(context);
    return TabBar(
      controller: ctrl,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      splashFactory: NoSplash.splashFactory,
      labelColor: Colors.black,
      unselectedLabelColor: Colors.grey,
      labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      indicator:  UnderlineTabIndicator(
        borderSide: BorderSide(width: 5, color: AppColors.primaryColor),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        insets: EdgeInsets.symmetric(horizontal: -16),
      ),
      tabs: [
        Tab(text: 'Description'.tr),
        Tab(text: 'Map'.tr),
        Tab(text: 'Return Policy'.tr),
      ],
    );
  }
}
