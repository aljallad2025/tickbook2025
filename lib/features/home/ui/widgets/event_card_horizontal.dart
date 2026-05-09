import 'package:evento_app/app/app_colors.dart';
import 'package:evento_app/features/common/ui/widgets/icon_text_widget.dart';
import 'package:evento_app/features/common/ui/widgets/shimmer_widgets.dart';
import 'package:evento_app/features/common/ui/widgets/safe_network_image.dart';
import 'package:evento_app/features/events/data/models/event_item_model.dart';
import 'package:evento_app/features/events/ui/screens/event_details_screen.dart';
import 'package:evento_app/features/common/ui/widgets/wishlist_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:evento_app/network_services/core/navigation_service.dart';
import 'package:provider/provider.dart';
import 'package:evento_app/features/events/providers/events_provider.dart';

class EventCardHorizontal extends StatelessWidget {
  final double width;
  final EventItemModel event;
  const EventCardHorizontal({super.key, required this.event, this.width = 350});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth < 380 ? 300.0 : width;
    return SizedBox(
      width: cardWidth,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
          final id = int.tryParse(event.id) ?? 0;
          NavigationService.pushAnimated(EventDetailsScreen(eventId: id));
        },
        child: Card(
          clipBehavior: Clip.antiAlias,
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.grey.shade200, width: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: SafeNetworkImage(
                      event.thumbnail,
                      fit: BoxFit.cover,
                      placeholder: const ShimmerBox(),
                    ),
                  ),
                  Positioned(
                    top: -1,
                    right: 12,
                    child: WishlistButton(
                      eventId: event.id,
                      radiusTopLeft: 0,
                      radiusBottomLeft: 8,
                      radiusTopRight: 0,
                      radiusBottomRight: 8,
                      iconHeight: 32,
                    ),
                  ),
                  Positioned(
                    bottom: -20,
                    left: 10,
                    right: 10,
                    child: Card(
                      elevation: 0.3,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: Colors.grey.shade200,
                          width: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconTextWidgetSpan(
                              data: event.date,
                              icon: Icons.calendar_month,
                            ),
                            IconTextWidgetSpan(
                              data: event.duration,
                              icon: Icons.hourglass_empty_sharp,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 10, 4),
                child: Text(
                  "",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 10, 0),
                child: Text(
                  event.title.tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: AppColors.primaryColor,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event.address?.tr ?? event.eventType.toUpperCase().tr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      () {
                        final pr = event.ticketPrice?.trim() ?? '';
                        if (pr.isEmpty ||
                            pr == '0' ||
                            pr.toLowerCase() == 'free') {
                          return 'Free'.tr;
                        }
                        final sym = 'BHD';
                        final pos = context
                            .read<EventsProvider>()
                            .currencySymbolPosition
                            .toLowerCase();
                        return pos == 'right' ? '$pr$sym' : 'BHD$pr';
                      }(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryColor,
                      ),
                      textDirection: TextDirection.ltr,
                    ),

                    Text(
                      'Tickets Available'.tr,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
