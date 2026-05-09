import 'package:evento_app/app/app_colors.dart';
import 'package:evento_app/features/common/ui/widgets/custom_app_bar.dart';
import 'package:evento_app/features/common/ui/widgets/search_bar_widget.dart';
import 'package:evento_app/features/auth/providers/auth_provider.dart';
import 'package:evento_app/features/support/providers/support_tickets_provider.dart';
import 'package:evento_app/features/support/ui/widgets/ticket_tile.dart';
import 'package:evento_app/features/support/ui/widgets/create_ticket_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:evento_app/features/support/ui/widgets/shimmer_list.dart';
import 'package:evento_app/features/common/ui/widgets/custom_snack_bar_widget.dart';

class SupportTickets extends StatelessWidget {
  const SupportTickets({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: context.watch<SupportTicketsProvider>().pageTitle,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SearchBarWidget(
              borderColor: Colors.grey.shade400,
              backgroundColor: Colors.grey.shade100,
              textFieldFillColor: Colors.white,
              iconColor: Colors.grey.shade600,
              hintText: '${'Search'.tr} ${'Ticket'.tr}...',
              controller: context
                  .read<SupportTicketsProvider>()
                  .searchController,
              showClearButton: context
                  .watch<SupportTicketsProvider>()
                  .query
                  .isNotEmpty,
              onChanged: (q) =>
                  context.read<SupportTicketsProvider>().setQuery(q),
              onSubmitted: (q) =>
                  context.read<SupportTicketsProvider>().setQuery(q),
              onClear: () {
                context.read<SupportTicketsProvider>().clearQuery();
              },
              showFilterButton: false,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              onPressed: () => _openCreateSheet(context),
              child: Text('Create New Ticket'.tr),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Consumer<SupportTicketsProvider>(
                builder: (context, prov, _) {
                  final token = context.read<AuthProvider>().token ?? '';
                  if (token.isNotEmpty && prov.lastToken != token) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      context.read<SupportTicketsProvider>().ensureInitialized(
                        token,
                      );
                    });
                    return const ShimmerList();
                  }
                  if (prov.loading) {
                    return const ShimmerList();
                  }
                  if (prov.authRequired) {
                    return const SizedBox.shrink();
                  }
                  final tickets = prov.tickets;
                  if (tickets.isEmpty) {
                    if (prov.loading) {
                      return const ShimmerList();
                    }
                    return Center(
                      child: Text(
                        prov.error == null
                            ? 'No tickets found'.tr
                            : 'Failed to load'.tr,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    );
                  }
                  return RefreshIndicator.adaptive(
                    backgroundColor: AppColors.primaryColor,
                    color: Colors.white,
                    onRefresh: () => prov.refresh(token),
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: tickets.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => TicketTile(ticket: tickets[i]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openCreateSheet(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final initialEmail = auth.customer?['email']?.toString() ?? '';

    final sheetFuture = showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => CreateTicketSheet(
        initialEmail: initialEmail,
        onSubmit: (subject, email, description, attachment) async {
          final token = context.read<AuthProvider>().token ?? '';
          return context.read<SupportTicketsProvider>().createTicket(
            token: token,
            subject: subject,
            email: email,
            description: description,
            attachment: attachment,
          );
        },
      ),
    );
    sheetFuture.then((res) async {
      if (!context.mounted || res == null) return;
      CustomSnackBar.show(
        context,
        res['message']?.toString() ?? 'Support Ticket Created Successfully'.tr,
      );
      final token = context.read<AuthProvider>().token ?? '';
      await context.read<SupportTicketsProvider>().refresh(token);
    });
  }
}
