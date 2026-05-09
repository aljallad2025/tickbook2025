import 'package:evento_app/features/events/data/models/event_details_models.dart';
import 'package:evento_app/features/events/ui/screens/event_details_screen.dart';
import 'package:evento_app/features/events/ui/widgets/event_details/event_tab_bar.dart';
import 'package:flutter/material.dart';

class TabsAndBody extends StatelessWidget {
  const TabsAndBody({super.key, required this.event});
  final EventDetailsModel event;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EventTabBar(),
        const SizedBox(height: 8),
        Builder(
          builder: (context) {
            final tc = DefaultTabController.of(context);
            return AnimatedBuilder(
              animation: tc.animation ?? tc,
              builder: (_, __) => TabBody(index: tc.index, event: event),
            );
          },
        ),
      ],
    );
  }
}

