import 'package:evento_app/app/app_text_styles.dart';
import 'package:evento_app/features/home/providers/notification_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:evento_app/features/common/ui/widgets/custom_snack_bar_widget.dart';

class NotificationsHeader extends StatelessWidget {
  final List<String> items;
  final String todayDate;
  const NotificationsHeader({
    super.key,
    required this.items,
    required this.todayDate,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final selectedValue = switch (provider.filter) {
      NotificationFilter.read => 'Read'.tr,
      NotificationFilter.unread => 'Unread'.tr,
      _ => 'All'.tr,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 150,
                height: 40,
                child: DropdownButtonFormField(
                  borderRadius: BorderRadius.circular(8),
                  dropdownColor: Colors.white,
                  elevation: 2,
                  initialValue: selectedValue,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: items
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) {
                    switch (val) {
                      case 'Read':
                        provider.setFilter(NotificationFilter.read);
                        break;
                      case 'Unread':
                        provider.setFilter(NotificationFilter.unread);
                        break;
                      default:
                        provider.setFilter(NotificationFilter.all);
                    }
                  },
                ),
              ),
              TextButton(
                onPressed: () async {
                  if (provider.filter == NotificationFilter.read) {
                    CustomSnackBar.show(
                      context,
                      'All notifications are already read!'.tr,
                    );
                    return;
                  }
                  await provider.markAllAsRead();
                  if (!context.mounted) return;
                  CustomSnackBar.show(
                    context,
                    provider.filter == NotificationFilter.unread
                        ? 'Mark as read'.tr
                        : 'Marked all as read'.tr,
                  );
                },
                child: Text(
                  'Mark All as Read'.tr,
                  style: AppTextStyles.bodyLargeGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('${"Today".tr} $todayDate', style: AppTextStyles.bodyLargeGrey),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
