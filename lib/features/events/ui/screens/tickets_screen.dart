import 'package:evento_app/features/common/ui/widgets/custom_app_bar.dart';
import 'package:evento_app/features/events/ui/widgets/tickets/tickets_body.dart';
import 'package:flutter/material.dart';

class TicketsScreen extends StatelessWidget {
  final int eventId;
  const TicketsScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Select Tickets'),
      body: TicketsBody(eventId: eventId),
    );
  }
}
