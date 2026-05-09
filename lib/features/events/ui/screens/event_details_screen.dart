import 'package:evento_app/app/app_routes.dart';
import 'package:evento_app/app/app_text_styles.dart';
import 'package:evento_app/app/assets_path.dart';
import 'package:evento_app/features/common/ui/widgets/custom_cpi.dart';
import 'package:evento_app/features/common/ui/widgets/custom_icon_button_widgets.dart';
import 'package:evento_app/features/events/data/models/event_details_models.dart';
import 'package:evento_app/features/events/ui/sections/countdown_section.dart';
import 'package:evento_app/features/events/ui/sections/related_event_section.dart';
import 'package:evento_app/features/events/ui/sections/tabs_and_body.dart';
import 'package:evento_app/features/events/ui/sections/title_and_status.dart';
import 'package:evento_app/features/events/providers/event_details_provider.dart';
import 'package:evento_app/features/events/ui/widgets/event_details/bottom_bar.dart';
import 'package:evento_app/features/events/ui/widgets/event_details/event_details_slider.dart';
import 'package:evento_app/features/events/ui/widgets/event_details/location_time_row.dart';
import 'package:evento_app/features/events/ui/widgets/event_details/organizer_card.dart';
import 'package:evento_app/features/events/ui/widgets/event_details/tab_data.dart';
import 'package:evento_app/features/events/ui/widgets/event_details/tab_map.dart';
import 'package:get/route_manager.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class EventDetailsScreen extends StatelessWidget {
  final int eventId;
  const EventDetailsScreen({super.key, required this.eventId});
  @override
  Widget build(BuildContext context) => _EventDetailsScaffold(eventId: eventId);
}

class TabBody extends StatelessWidget {
  const TabBody({super.key, required this.index, required this.event});
  final int index;
  final EventDetailsModel event;
  @override
  Widget build(BuildContext context) {
    switch (index) {
      case 0:
        return DescriptionSection(textHtml: event.descriptionHtml);
      case 1:
        if ((event.eventType ?? '').toLowerCase() == 'online') {
          return const OnlineEventNotice();
        }
        return MapSection(
          lat: event.latitude,
          lon: event.longitude,
          title: event.title,
        );
      case 2:
        return RefundSection(text: event.refundPolicy);
      default:
        return const SizedBox.shrink();
    }
  }
}

class _EventDetailsScaffold extends StatelessWidget {
  const _EventDetailsScaffold({required this.eventId});
  final int eventId;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      context.read<EventDetailsProvider>().ensureLoaded(eventId);
    });
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Stack(
            alignment: Alignment.center,
            children: [
              Center(
                child: Consumer<EventDetailsProvider>(
                  builder: (context, prov, _) {
                    final page = prov.details?.pageTitle ?? '';
                    final title = page.isNotEmpty ? page : 'Details';
                    return Text(
                      title,
                      style: AppTextStyles.headingSmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    );
                  },
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: CustomIconButtonWidget(
                  assetPath: AssetsPath.backIconSvg,
                  onTap: () => Navigator.of(context).maybePop(),
                ),
              ),
            ],
          ),
        ),
        body: Consumer<EventDetailsProvider>(
          builder: (context, prov, _) {
            if (prov.error != null && prov.details == null) {
              return Center(
                child: Text(
                  'Failed to load details: ${prov.error}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red.shade400),
                ),
              );
            }
            if (prov.details == null) {
              return const Center(child: CustomCPI());
            }
            final details = prov.details!;
            final event = details.event;
            final images = details.sliderImages;
            final headerImages = images.map((e) => e.image).toList();
            final double? minPrice = details.tickets.isEmpty
                ? null
                : details.tickets
                      .map((t) => t.fPrice)
                      .reduce((a, b) => a < b ? a : b);

            return Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (headerImages.isNotEmpty)
                            EventDetailsSlider(headerImages: headerImages),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TitleAndStatus(event: event),
                                const SizedBox(height: 8),
                                LocationAndTimeRow(event: event),
                                const SizedBox(height: 4),
                                TabsAndBody(event: event),
                                const SizedBox(height: 12),
                                CountdownSection(event: event),
                                const SizedBox(height: 12),
                                // InkWell(
                                //   onTap: () {
                                //     Get.toNamed(
                                //       AppRoutes.organizerDetails,
                                //       arguments: {
                                //         'id': event.organizerId,
                                //         'isAdmin': event.organizerId == null
                                //             ? true
                                //             : false,
                                //       },
                                //     );
                                //   },
                                //
                                //   child: OrganizerCard(
                                //     details: details,
                                //     event: event,
                                //   ),
                                // ),
                                // const SizedBox(height: 12),
                                RelatedEventsSection(details: details),
                                const SizedBox(height: 150),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    bottom: false,
                    child: BottomBar(minPrice: minPrice),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
