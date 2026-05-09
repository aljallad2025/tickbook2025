import 'package:evento_app/app/app_colors.dart';
import 'package:evento_app/app/app_text_styles.dart';
import 'package:evento_app/features/events/ui/screens/event_details_screen.dart';
import 'package:evento_app/features/events/data/models/event_item_model.dart';
import 'package:evento_app/features/common/ui/widgets/shimmer_widgets.dart';
import 'package:evento_app/features/common/ui/widgets/safe_network_image.dart';
import 'package:evento_app/features/common/ui/widgets/wishlist_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:evento_app/network_services/core/navigation_service.dart';
import 'package:provider/provider.dart';
import 'package:evento_app/features/events/providers/events_provider.dart';

class EventCard extends StatelessWidget {
  final EventItemModel event;
  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
          final id = int.tryParse(event.id) ?? 0;
          NavigationService.pushAnimated(EventDetailsScreen(eventId: id));
        },
        child: Card(
          clipBehavior: Clip.antiAlias,
          color: Colors.white,
          elevation: 1,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.grey.shade200, width: 0.5),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(14),
                        bottomLeft: Radius.circular(14),
                      ),
                      child: SafeNetworkImage(
                        height: 150,
                        event.thumbnail,
                        fit: BoxFit.cover,
                        placeholder: const ShimmerBox(),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: WishlistButton(eventId: event.id),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.only(left: 12.0, right: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: AppTextStyles.bodyLarge.copyWith(fontSize: 18),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      _IconText(
                        icon: Icons.location_on_outlined,
                        text: event.address ?? event.eventType.toUpperCase(),
                      ),
                      const SizedBox(height: 8),
                      _IconText(
                        icon: Icons.location_on_outlined,
                        text: '${event.date} , ${event.time}',
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            () {
                              final pr = event.ticketPrice?.trim() ?? '';
                              if (pr.isEmpty ||
                                  pr == '0' ||
                                  pr.toLowerCase() == 'free') {
                                return 'Free'.tr;
                              }
                              final sym = context
                                  .read<EventsProvider>()
                                  .currencySymbol;
                              final pos = context
                                  .read<EventsProvider>()
                                  .currencySymbolPosition
                                  .toLowerCase();
                              return pos == 'right' ? '$pr$sym' : '$sym$pr';
                            }(),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryColor,
                            ),
                            textDirection: TextDirection.ltr,
                          ),
                          Flexible(
                            child: Text(
                              'Tickets Available'.tr,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.green.shade600,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconText extends StatelessWidget {
  const _IconText({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: AppColors.primaryColor),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text.tr,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
          ),
        ),
      ],
    );
  }
}
