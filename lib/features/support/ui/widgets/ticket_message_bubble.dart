import 'package:evento_app/app/app_colors.dart';
import 'package:evento_app/features/support/data/models/support_ticket_details_models.dart';
import 'package:evento_app/features/support/ui/widgets/attachment_button.dart';
import 'package:evento_app/features/support/ui/widgets/ticket_user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class MessageBubble extends StatelessWidget {
  final TicketMessage msg;
  final int currentUserId;
  const MessageBubble({
    super.key,
    required this.msg,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final isMine = (msg.userId != null && msg.userId == currentUserId);
    final align = isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final color = isMine
        ? AppColors.primaryColor.withValues(alpha: 0.1)
        : Colors.grey.shade100;
    final displayName = isMine
        ? msg.sender?.name
        : (msg.sender?.name ?? 'Super Admin');
    final role = isMine ? msg.sender?.role : msg.sender?.role;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: isMine
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        if (!isMine)
          TicketUserAvatar(
            url: msg.sender?.avatar,
            isAdmin: role?.toLowerCase() == 'Super Admin',
          ),
        if (!isMine) const SizedBox(width: 8),
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: align,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: isMine
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName!.toUpperCase(),
                      style:  TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      role!,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      msg.createdAt,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if ((msg.reply ?? '').isNotEmpty)
                  Align(
                    alignment: isMine
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Html(
                      data: msg.reply!,
                      style: {
                        "body": Style(
                          margin: Margins.zero,
                          fontSize: FontSize(16),
                        ),
                      },
                    ),
                  ),

                if ((msg.file ?? '').isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      height: 40,

                      child: AttachmentButton(url: msg.file!),
                    ),
                  ),
                ],
                const SizedBox(height: 6),
              ],
            ),
          ),
        ),
        if (isMine) const SizedBox(width: 8),
        if (isMine) TicketUserAvatar(url: msg.sender?.avatar, isAdmin: false),
      ],
    );
  }
}
