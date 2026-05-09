import 'package:evento_app/app/app_colors.dart';
import 'package:evento_app/features/auth/providers/auth_provider.dart';
import 'package:evento_app/features/common/ui/widgets/custom_app_bar.dart';
import 'package:evento_app/features/common/ui/widgets/custom_cpi.dart';
import 'package:evento_app/features/support/ui/widgets/mesage_bottom_widget.dart';
import 'package:evento_app/features/support/ui/widgets/ticket_details_header_card.dart';
import 'package:evento_app/features/support/ui/widgets/ticket_replies.dart';
import 'package:evento_app/features/support/providers/support_ticket_details_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:evento_app/features/common/ui/widgets/shimmer_widgets.dart';
import 'package:evento_app/features/common/ui/widgets/custom_snack_bar_widget.dart';

class TicketDetails extends StatelessWidget {
  final int ticketId;
  const TicketDetails({super.key, required this.ticketId});

  Future<void> _refresh(BuildContext context) async {
    final token = context.read<AuthProvider>().token ?? '';
    await context.read<SupportTicketDetailsProvider>().init(
      token: token,
      ticketId: ticketId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: context.watch<SupportTicketDetailsProvider>().pageTitle,
      ),
      body: Consumer<SupportTicketDetailsProvider>(
        builder: (context, prov, _) {
          // ensure init
          final token = context.read<AuthProvider>().token ?? '';
          if (!prov.initialized ||
              prov.lastToken != token ||
              prov.lastTicketId != ticketId) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<SupportTicketDetailsProvider>().ensureInitialized(
                token: token,
                ticketId: ticketId,
              );
            });
          }

          if (prov.loading && !prov.initialized) {
            return const SupportTicketDetailsShimmer();
          }
          if (prov.details == null) {
            if (prov.error != null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Failed to load ticket details',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              );
            }
            return const Center(child: CustomCPI());
          }

          final details = prov.details!;
          final bool isClosed = details.status == 3;
          return Column(
            children: [
              Expanded(
                child: RefreshIndicator.adaptive(
                  backgroundColor: AppColors.primaryColor,
                  color: Colors.white,
                  onRefresh: () => _refresh(context),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      TicketDetailsHeaderCard(details: details),
                      const SizedBox(height: 16),
                      Builder(
                        builder: (ctx) {
                          final dynamic uidRaw = ctx
                              .read<AuthProvider>()
                              .customer?['id'];
                          int currentUserId = 0;
                          if (uidRaw is int) {
                            currentUserId = uidRaw;
                          } else if (uidRaw is String) {
                            currentUserId = int.tryParse(uidRaw) ?? 0;
                          }
                          return TicketReplies(
                            messages: details.messages,
                            currentUserId: currentUserId,
                          );
                        },
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
              if (!isClosed)
                MessageBottomWidget(
                  sending: prov.sending,
                  replyCtrl: prov.replyController,
                  attachment: prov.attachment,
                  onPick: () => _pickFile(context),
                  onRemoveAttachment: () => context
                      .read<SupportTicketDetailsProvider>()
                      .clearAttachment(),
                  onSend: prov.sending ? null : () => _send(context),
                ),
              if (prov.loading) const SupportTicketDetailsShimmer(),
            ],
          );
        },
      ),
    );
  }

  Future<void> _pickFile(BuildContext context) async {
    ScaffoldMessenger.of(context);
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        withData: true,
      );
      if (result != null && result.files.isNotEmpty && context.mounted) {
        context.read<SupportTicketDetailsProvider>().setAttachment(
          result.files.first,
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      CustomSnackBar.show(
        iconBgColor: AppColors.snackError,
        context,
        'Please attach a file smaller than 5MB.',
      );
    }
  }

  Future<void> _send(BuildContext context) async {
    final prov = context.read<SupportTicketDetailsProvider>();
    final text = prov.replyController.text.trim();
    if (text.isEmpty && prov.attachment == null) {
      CustomSnackBar.show(
        iconBgColor: AppColors.snackError,
        context,
        'Type a reply or attach a file.',
      );
      return;
    }
    final details = prov.details;
    if (details != null && details.status == 3) {
      CustomSnackBar.show(
        iconBgColor: AppColors.snackError,
        context,
        'Cannot reply to a closed ticket.',
      );
      return;
    }
    final token = context.read<AuthProvider>().token ?? '';
    try {
      final res = await prov.reply(
        token: token,
        ticketId: ticketId,
        message: text.isEmpty ? null : text,
        attachment: prov.attachment,
      );
      prov.clearReplyText();
      prov.clearAttachment();
      if (!context.mounted) return;
      CustomSnackBar.show(context, res['message']?.toString() ?? 'Replied.');
      await _refresh(context);
    } catch (e) {
      if (!context.mounted) return;
      CustomSnackBar.show(
        iconBgColor: AppColors.snackError,
        context,
        'Reply failed: $e',
      );
    }
  }
}
