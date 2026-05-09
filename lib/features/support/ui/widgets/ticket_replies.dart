
import 'package:evento_app/features/support/data/models/support_ticket_details_models.dart';
import 'package:evento_app/features/support/ui/widgets/ticket_message_bubble.dart';
import 'package:flutter/material.dart';

class TicketReplies extends StatelessWidget {
  final List<TicketMessage> messages;
  final int currentUserId;
  const TicketReplies({
    super.key,
    required this.messages,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'No messages yet',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: messages.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) =>
          MessageBubble(msg: messages[i], currentUserId: currentUserId),
    );
  }
}
