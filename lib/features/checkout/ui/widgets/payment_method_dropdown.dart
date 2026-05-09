import 'package:flutter/material.dart';
import 'package:evento_app/app/app_text_styles.dart';
import 'package:evento_app/network_services/core/basic_service.dart';
import 'package:evento_app/features/checkout/data/models/checkout_payment_model.dart';
import '../screens/checkout_screen.dart';

class PaymentMethodDropdown extends StatefulWidget {
  final PaymentGateway value;
  final String? selectedOfflineId;
  final void Function(PaymentGateway, Map<String, String>?) onChanged;
  const PaymentMethodDropdown({
    super.key,
    required this.value,
    this.selectedOfflineId,
    required this.onChanged,
  });

  @override
  State<PaymentMethodDropdown> createState() => _PaymentMethodDropdownState();
}

class _PaymentMethodDropdownState extends State<PaymentMethodDropdown> {
  bool _loading = true;
  final List<_GatewayItem> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final online = await BasicService.getOnlineGateways();
    final offline = await BasicService.getOfflineGateways();

    final items = <_GatewayItem>[];
    // Add offline banks individually
    for (final b in offline) {
      items.add(
        _GatewayItem(
          value: PaymentGateway.offline,
          label: '${b['name']} (Offline)',
          offline: b,
        ),
      );
    }

    for (final g in online) {
      final kw = (g['keyword'] ?? '').toLowerCase();
      final name = g['name'] ?? kw;
      final pgw = CheckoutPaymentModel.fromKeyword(kw);
      if (pgw != null) {
        items.add(_GatewayItem(value: pgw, label: name));
      }
    }

    if (mounted) {
      setState(() {
        _items
          ..clear()
          ..addAll(items);
        _loading = false;
      });
      // If no selection yet, choose first item
      if (_items.isNotEmpty) {
        if (widget.value != PaymentGateway.offline) {
          final firstOnline = _items.firstWhere(
            (e) => e.value == widget.value,
            orElse: () => _items.first,
          );
          widget.onChanged(firstOnline.value, firstOnline.offline);
        } else {
          // try to match selected offline id
          final match = _items.firstWhere(
            (e) =>
                e.value == PaymentGateway.offline &&
                (widget.selectedOfflineId == null ||
                    e.offline?['id'] == widget.selectedOfflineId),
            orElse: () => _items.first,
          );
          widget.onChanged(match.value, match.offline);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _GatewayItem? selected;
    if (_items.isNotEmpty) {
      if (widget.value == PaymentGateway.offline) {
        selected = _items.firstWhere(
          (e) =>
              e.value == PaymentGateway.offline &&
              (widget.selectedOfflineId == null ||
                  e.offline?['id'] == widget.selectedOfflineId),
          orElse: () => _items.first,
        );
      } else {
        selected = _items.firstWhere(
          (e) => e.value == widget.value,
          orElse: () => _items.first,
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Payment Method', style: AppTextStyles.headingMedium),
        const SizedBox(height: 8),
        if (_loading)
          const SizedBox(
            height: 44,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          )
        else if (_items.isEmpty)
          const Text('No payment methods available')
        else
          DropdownButtonFormField<_GatewayItem>(
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(12),
            initialValue: selected,
            decoration: InputDecoration(
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            items: _items
                .map((e) => DropdownMenuItem(value: e, child: Text(e.label)))
                .toList(),
            onChanged: (v) {
              final pick = v ?? (_items.isNotEmpty ? _items.first : null);
              if (pick != null) {
                widget.onChanged(pick.value, pick.offline);
              }
            },
          ),
      ],
    );
  }
}

class _GatewayItem {
  final PaymentGateway value;
  final String label;
  final Map<String, String>? offline;
  const _GatewayItem({required this.value, required this.label, this.offline});
}
