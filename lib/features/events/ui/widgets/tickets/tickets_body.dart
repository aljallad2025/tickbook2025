import 'package:evento_app/app/app_text_styles.dart';
import 'package:evento_app/app/app_routes.dart';
import 'package:evento_app/features/auth/providers/auth_provider.dart';
import 'package:evento_app/features/common/ui/widgets/custom_cpi.dart';
import 'package:evento_app/features/events/providers/event_details_provider.dart';
import 'package:evento_app/features/events/providers/tickets_provider.dart';
import 'package:evento_app/features/events/ui/models/display_row.dart';
import 'package:evento_app/features/events/ui/widgets/tickets/ticket_rows_builder.dart';
import 'package:evento_app/features/events/ui/widgets/tickets/verify_and_build_payload.dart';
import 'package:evento_app/features/events/ui/widgets/tickets/date_text.dart';
import 'package:evento_app/features/events/ui/widgets/tickets/qty_stepper.dart';
import 'package:evento_app/features/events/ui/widgets/tickets/seating_button.dart';
import 'package:evento_app/features/events/ui/widgets/tickets/summary_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'ticket_tile.dart';

class TicketsBody extends StatelessWidget {
  final int eventId;
  const TicketsBody({super.key, required this.eventId});

  void _inc(BuildContext context, String key, {int step = 1, int? max}) {
    context.read<TicketsProvider>().inc(key, step: step, max: max);
  }

  void _dec(BuildContext context, String key, {int step = 1}) {
    context.read<TicketsProvider>().dec(key, step: step);
  }

  Future<void> _openSeatPlan(BuildContext context, DisplayRow item) async {
    final result = await Get.toNamed(
      AppRoutes.seatPlan,
      arguments: {
        'eventId': eventId,
        'ticketId': item.ticketId,
        'slotUniqueId': item.slotUniqueId ?? 0,
      },
    );
    if (result is Map) {
      final total = (result['total'] is num)
          ? (result['total'] as num).toDouble()
          : 0.0;
      final seatIds = (result['seatIds'] is List)
          ? (result['seatIds'] as List).whereType<int>().toList()
          : const <int>[];
      final seatNames = (result['seatNames'] is List)
          ? (result['seatNames'] as List).whereType<String>().toList()
          : const <String>[];
      final seatDetails = (result['seatDetails'] is List)
          ? (result['seatDetails'] as List)
                .whereType<Map<String, dynamic>>()
                .toList()
          : const <Map<String, dynamic>>[];
      // ignore: use_build_context_synchronously
      context.read<TicketsProvider>().setSeatSelection(
        item.key,
        TicketSeatSelection(
          seatIds: seatIds,
          seatNames: seatNames,
          seatDetails: seatDetails,
          total: total,
        ),
      );
    }
  }

  Widget _ticketCard(
    DisplayRow item,
    TicketsProvider tp,
    BuildContext context,
  ) {
    final details = context.read<EventDetailsProvider>().details!;
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: TicketTile(
          displayTitle: item.title,
          subtitle: item.subtitle,
          priceText: item.price <= 0
              ? 'FREE'
              : ((details.currencySymbolPosition?.toLowerCase() == 'right')
                    ? '${item.price.toStringAsFixed(0)}${details.currencySymbol ?? ''}'
                    : '${details.currencySymbol ?? ''}${item.price.toStringAsFixed(0)}'),
          seatingEnabled: item.seating,
          noSeat: item.noSeat,
          trailing: (!item.seating)
              ? QtyStepper(
                  value: tp.qty[item.key] ?? 0,
                  onDec: () => _dec(context, item.key),
                  onInc: () => _inc(context, item.key, max: item.maxQty),
                )
              : SeatingButton(
                  onPressed:
                      (item.slotUniqueId == null || item.slotUniqueId == 0)
                      ? null
                      : () => _openSeatPlan(context, item),
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      context.read<EventDetailsProvider>().ensureLoaded(eventId);
    });
    return Consumer<EventDetailsProvider>(
      builder: (context, prov, _) {
        if (prov.details == null) {
          if (prov.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Failed to load: ${prov.error}'),
              ),
            );
          }
          return const Center(child: CustomCPI());
        }
        final details = prov.details!;
        final rows = buildDisplayRows(details);
        final tp = context.watch<TicketsProvider>();
        final totalPrice = tp.computeTotal(details);
        final isMultiple =
            (details.event.dateType ?? '').toLowerCase() == 'multiple' &&
            details.event.dates.isNotEmpty;
        final dates = details.event.dates;
        final selectedIdx = prov.selectedDateIndex ?? 0;
        final safeIdx = (selectedIdx >= 0 && selectedIdx < dates.length)
            ? selectedIdx
            : 0;
        final selectedOccur = isMultiple ? dates[safeIdx] : null;

        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (isMultiple) ...[
                    Text('Select Date', style: AppTextStyles.headingMedium),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      initialValue: safeIdx,
                      decoration: InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      items: List.generate(
                        dates.length,
                        (i) => DropdownMenuItem<int>(
                          value: i,
                          child: Text(formatOccurrence(dates[i])),
                        ),
                      ),
                      onChanged: (v) {
                        final nv = v ?? 0;
                        context
                            .read<EventDetailsProvider>()
                            .setSelectedDateIndex(nv);
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                  ...rows.map((e) => _ticketCard(e, tp, context)),
                ],
              ),
            ),
            const Divider(height: 1),
            SummaryBar(
              totalPrice: totalPrice,
              details: details,
              onBuy: () async {
                if (tp.verifying) return;
                tp.setVerifyState(verifying: true, error: null);
                try {
                  final payload = await verifyAndBuildCheckoutPayload(
                    context: context,
                    details: details,
                    rows: rows,
                    selectedOccur: selectedOccur,
                  );
                  if (!context.mounted) return;
                  final auth = context.read<AuthProvider>();
                  final isLoggedIn =
                      (auth.token != null && auth.token!.isNotEmpty);
                  if (!isLoggedIn) {
                    auth.setPendingRedirect(
                      RouteSettings(
                        name: AppRoutes.checkout,
                        arguments: payload,
                      ),
                    );
                    Get.toNamed(
                      AppRoutes.checkoutLogin,
                      arguments: {
                        'redirectToHome': false,
                        'popOnSuccess': true,
                      },
                    );
                    return;
                  }
                  Get.toNamed(AppRoutes.checkout, arguments: payload);
                } catch (e) {
                  tp.setVerifyState(verifying: false, error: e.toString());
                  return;
                }
                tp.setVerifyState(verifying: false, error: null);
              },
              verifying: tp.verifying,
              verifyError: tp.verifyError,
            ),
          ],
        );
      },
    );
  }
}

