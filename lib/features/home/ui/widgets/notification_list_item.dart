import 'package:evento_app/app/app_colors.dart';
import 'package:evento_app/app/app_text_styles.dart';
import 'package:evento_app/features/auth/providers/auth_provider.dart';
import 'package:evento_app/features/common/ui/widgets/custom_snack_bar_widget.dart';
import 'package:evento_app/features/home/data/models/fcm_notification_model.dart';
import 'package:evento_app/features/home/providers/notification_provider.dart';
import 'package:evento_app/features/home/ui/widgets/booking_guest_dialog.dart';
import 'package:evento_app/features/home/ui/widgets/notification_type_icon.dart';
import 'package:evento_app/features/home/ui/widgets/notifications_utils.dart';
import 'package:evento_app/network_services/core/navigation_service.dart';
import 'package:evento_app/network_services/core/notification_service.dart';
import 'package:evento_app/app/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class NotificationListItem extends StatelessWidget {
  final NotificationModel notification;
  const NotificationListItem({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(notification.hashCode),
      direction: DismissDirection.endToStart,
      onDismissed: (_) async {
        final model = notification;
        await context.read<NotificationProvider>().removeNotification(model);
        final rootCtx =
            NavigationService.navigatorKey.currentContext ??
            Get.context ??
            context;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          CustomSnackBar.show(rootCtx, 'Notification removed successfully!'.tr);
        });
      },
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          context.read<NotificationProvider>().markAsRead(notification);

          final payload = notification.payload ?? const <String, dynamic>{};

          // Use FCM notification model for consistent parsing
          try {
            final fcmNotification = FcmNotificationModel.fromJson({
              'id': notification.id,
              'title': notification.title,
              'body': notification.body,
              'data': payload,
            });

            final data = fcmNotification.data;

            if (data.isBookingNotification) {
              final auth = context.read<AuthProvider>();
              final loggedIn = (auth.token ?? '').isNotEmpty;
              final eventTitle = data.eventTitle ?? notification.title;

              if (!loggedIn) {
                final p = payload;
                final msg = (p['message'] ?? notification.body)?.toString();
                final evtDate = (p['event_date'] ?? p['eventDate'])?.toString();
                final payStatus = (p['paymentStatus'] ?? p['payment_status'])
                    ?.toString();
                await showBookingGuestDialog(
                  context: context,
                  title: eventTitle,
                  bookingId: (data.bookingIdAsInt?.toString() ?? '-'),
                  message: msg,
                  eventDate: evtDate,
                  paymentStatus: payStatus,
                  onLogin: () {
                    NavigationService.navigatorKey.currentState?.pushNamed(
                      AppRoutes.login,
                      arguments: {'popOnSuccess': true},
                    );
                  },
                );
                return;
              }

              if (data.bookingIdAsInt != null) {
                // Navigate to booking details
                final bookingId = data.bookingIdAsInt!;
                NavigationService.navigatorKey.currentState?.pushNamed(
                  AppRoutes.bookingDetails,
                  arguments: {
                    'bookingId': bookingId,
                    'booking_id': bookingId.toString(),
                    'eventTitle': eventTitle,
                    'event_title': eventTitle,
                  },
                );
                return;
              }
            }
          } catch (_) {
            // Fallback to manual parsing
          }

          Map<String, dynamic> fcmData = payload;
          if (payload.containsKey('data') && payload['data'] is Map) {
            fcmData = Map<String, dynamic>.from(payload['data']);
          }

          final bookingId = (fcmData['booking_id'] ?? fcmData['bookingId'])
              ?.toString();
          final eventTitle =
              fcmData['event_title']?.toString() ??
              fcmData['eventTitle']?.toString() ??
              payload['event_title']?.toString() ??
              payload['eventTitle']?.toString() ??
              notification.title;

          if (bookingId != null && bookingId.isNotEmpty) {
            final bookingIdInt = int.tryParse(bookingId);
            if (bookingIdInt != null && bookingIdInt > 0) {
              final auth = context.read<AuthProvider>();
              final loggedIn = (auth.token ?? '').isNotEmpty;
              if (!loggedIn) {
                final msg =
                    (fcmData['message'] ??
                            payload['message'] ??
                            notification.body)
                        ?.toString();
                final evtDate =
                    (fcmData['event_date'] ??
                            fcmData['eventDate'] ??
                            payload['event_date'] ??
                            payload['eventDate'])
                        ?.toString();
                final payStatus =
                    (fcmData['paymentStatus'] ??
                            fcmData['payment_status'] ??
                            payload['paymentStatus'] ??
                            payload['payment_status'])
                        ?.toString();
                await showBookingGuestDialog(
                  context: context,
                  title: eventTitle,
                  bookingId: bookingId,
                  message: msg,
                  eventDate: evtDate,
                  paymentStatus: payStatus,
                  onLogin: () {
                    NavigationService.navigatorKey.currentState?.pushNamed(
                      AppRoutes.login,
                      arguments: {'popOnSuccess': true},
                    );
                  },
                );
                return;
              }
              // Navigate to booking details
              NavigationService.navigatorKey.currentState?.pushNamed(
                AppRoutes.bookingDetails,
                arguments: {
                  'bookingId': bookingIdInt,
                  'booking_id': bookingId,
                  'eventTitle': eventTitle,
                  'event_title': eventTitle,
                },
              );
              return;
            }
          }

          final url =
              (payload['button_url'] ?? payload['url'] ?? payload['link'])
                  as String?;
          if ((url == null || url.trim().isEmpty) && payload.isEmpty) {
            CustomSnackBar.show(
              context,
              'No action available for this notification'.tr,
            );
            return;
          }
          NotificationService.handleNotificationTapData(payload);
        },
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.grey.shade100),
          ),
          elevation: 0.1,
          color: notification.isRead ? Colors.white : Colors.grey.shade100,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      height: 56,
                      width: 56,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        border: Border.all(color: Colors.grey.shade400),
                        shape: BoxShape.circle,
                      ),
                      child: NotificationTypeIcon(type: notification.type),
                    ),
                    if (!notification.isRead)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          height: 16,
                          width: 16,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: AppTextStyles.headingSmall.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            timeAgo(notification.timestamp),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notification.body,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 16,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
