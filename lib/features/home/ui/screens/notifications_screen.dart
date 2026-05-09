import 'package:evento_app/features/common/ui/widgets/custom_app_bar.dart';
import 'package:evento_app/features/home/providers/notification_provider.dart';
import 'package:evento_app/features/home/ui/widgets/notification_list_item.dart';
import 'package:evento_app/features/home/ui/widgets/notifications_header.dart';
import 'package:evento_app/features/home/ui/widgets/notifications_utils.dart'
    as nutils;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:evento_app/features/common/ui/widgets/shimmer_widgets.dart';

class NotificationsScreen extends StatelessWidget {
  NotificationsScreen({super.key});

  final String todayDate = DateFormat('dd MMM, yyyy').format(DateTime.now());
  final List<String> items = ['All'.tr, 'Read'.tr, 'Unread'.tr];
  bool _isBookingNotification(NotificationModel n) =>
      nutils.isBookingNotification(n);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final filtered = provider.notifications.where(
      (n) => provider.tabIndex == 0
          ? !_isBookingNotification(n)
          : _isBookingNotification(n),
    );
    final notifications = filtered.toList(growable: false);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const CustomAppBar(title: 'Notifications'),
            NotificationsHeader(items: items, todayDate: todayDate),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: RefreshIndicator.adaptive(
                  onRefresh: () =>
                      context.read<NotificationProvider>().refreshFromServer(),
                  child: provider.refreshing
                      ? ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          itemCount: 8,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (_, __) => SizedBox(
                            height: 100,
                            child: const ShimmerListCard(),
                          ),
                        )
                      : notifications.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.25,
                            ),
                            Center(child: Text('No notifications found!'.tr)),
                          ],
                        )
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          itemCount: notifications.length,
                          itemBuilder: (context, index) => NotificationListItem(
                            notification: notifications[index],
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey.shade50,
        elevation: 0.5,
        currentIndex: provider.tabIndex,
        onTap: (i) => context.read<NotificationProvider>().setTab(i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.campaign_outlined),
            label: 'Promotions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            label: 'Bookings',
          ),
        ],
      ),
    );
  }
}
