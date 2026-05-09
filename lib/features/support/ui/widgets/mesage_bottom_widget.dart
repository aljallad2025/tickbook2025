import 'package:evento_app/app/app_colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MessageBottomWidget extends StatelessWidget {
  final bool sending;
  final TextEditingController replyCtrl;
  final PlatformFile? attachment;
  final VoidCallback onPick;
  final VoidCallback onRemoveAttachment;
  final VoidCallback? onSend;
  const MessageBottomWidget({
    super.key,
    required this.sending,
    required this.replyCtrl,
    required this.attachment,
    required this.onPick,
    required this.onRemoveAttachment,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: onPick,
                  icon: const Icon(Icons.attach_file),
                ),
                Expanded(
                  child: TextField(
                    controller: replyCtrl,
                    minLines: 1,
                    maxLines: 5,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) {
                      if (!sending && onSend != null) onSend!();
                    },
                    decoration:
                        InputDecoration(
                          hintText: '${'Write Your Message'.tr}...',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ).copyWith(
                          suffixIcon: sending
                              ? Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : IconButton(
                                  tooltip: 'Send'.tr,
                                  onPressed: onSend,
                                  icon: const Icon(Icons.send),
                                  color: AppColors.primaryColor,
                                ),
                        ),
                  ),
                ),
                const SizedBox(width: 4),
              ],
            ),
            if (attachment != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.insert_drive_file, size: 18),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        attachment!.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    InkWell(
                      borderRadius: BorderRadius.circular(6),
                      onTap: onRemoveAttachment,
                      child: const Icon(Icons.close, size: 18),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
