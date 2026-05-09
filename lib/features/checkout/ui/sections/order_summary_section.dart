import 'package:flutter/material.dart';
import 'package:evento_app/app/app_text_styles.dart';
import 'package:evento_app/app/app_colors.dart';

class OrderSummarySection extends StatelessWidget {
  final String eventTitle;
  final String eventDateText;
  final String eventPlaceText;
  final List<Map<String, dynamic>> items;
  final double total;
  final double couponDiscount;
  final double? verifySubTotal;
  final double? verifyTax;
  final double? verifyFees;
  final double? verifyGrandTotal;
  final String? currencySymbol;
  final String? currencySymbolPosition;
  final double? taxPercent;
  const OrderSummarySection({
    super.key,
    required this.eventTitle,
    required this.eventDateText,
    required this.eventPlaceText,
    required this.items,
    required this.total,
    required this.couponDiscount,
    this.verifySubTotal,
    this.verifyTax,
    this.verifyFees,
    this.verifyGrandTotal,
    this.currencySymbol,
    this.currencySymbolPosition,
    this.taxPercent,
  });
  @override
  Widget build(BuildContext context) {
    String fmt(double v) {
      final sym = currencySymbol ?? '\$';
      final pos = (currencySymbolPosition ?? 'left').toLowerCase();
      final text = v.toStringAsFixed(2);
      return pos == 'right' ? '$text$sym' : '$sym$text';
    }

    String fmtPercent(double p) {
      // Integer -> 0 decimals, otherwise 2 decimals
      return (p % 1 == 0) ? p.toStringAsFixed(0) : p.toStringAsFixed(2);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Order Summary', style: AppTextStyles.headingMedium),
        const SizedBox(height: 8),
        _OrderHeader(
          title: eventTitle,
          dateText: eventDateText,
          placeText: eventPlaceText,
        ),
        const SizedBox(height: 8),
        ...items.map((e) => _OrderItem(item: e, fmt: fmt)),
        const Divider(height: 24),
        _RowKV(keys: 'Subtotal', v: fmt(_displaySubtotal())),
        if (_computedTax() > 0 || taxPercent != null)
          _RowKV(
            keys: () {
              final p = taxPercent;
              if (p != null) {
                return 'Tax (${fmtPercent(p)}%)';
              }
              return 'Tax';
            }(),
            v: fmt(_computedTax()),
          ),
        if (_computedFees() > 0) _RowKV(keys: 'Fees', v: fmt(_computedFees())),
        _RowKV(keys: 'Total', v: fmt(_computedTotal()), emphasize: true),
        if (couponDiscount > 0) ...[
          const SizedBox(height: 4),
          _RowKV(keys: 'Coupon Discount', v: '-${fmt(couponDiscount)}'),
          const SizedBox(height: 2),
          _RowKV(
            keys: 'Grand Total',
            v: fmt(
              (_computedTotal() - couponDiscount).clamp(0, double.infinity),
            ),
            emphasize: true,
          ),
        ],
      ],
    );
  }
}

class _OrderHeader extends StatelessWidget {
  final String title;
  final String dateText;
  final String placeText;
  const _OrderHeader({
    required this.title,
    required this.dateText,
    required this.placeText,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.event, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(child: Text(dateText, style: AppTextStyles.bodySmall)),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              const Icon(Icons.place, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(child: Text(placeText, style: AppTextStyles.bodySmall)),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final String Function(double) fmt;
  const _OrderItem({required this.item, required this.fmt});
  @override
  Widget build(BuildContext context) {
    final String name = (item['name'] ?? '').toString();
    final int qty = (item['qty'] is num) ? (item['qty'] as num).toInt() : 0;
    final double unit = (item['unit'] is num)
        ? (item['unit'] as num).toDouble()
        : 0;
    final double subtotal = (item['subtotal'] is num)
        ? (item['subtotal'] as num).toDouble()
        : 0;
    final List seats = (item['seats'] is List)
        ? item['seats'] as List
        : const [];
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(name, style: AppTextStyles.bodyLarge)),
              Text('x$qty', style: AppTextStyles.bodySmall),
            ],
          ),
          if (seats.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('Seats: ${seats.join(', ')}', style: AppTextStyles.bodySmall),
          ],
          const SizedBox(height: 6),
          _RowKV(keys: 'Unit Price', v: fmt(unit)),
          _RowKV(keys: 'Subtotal', v: fmt(subtotal)),
        ],
      ),
    );
  }
}

class _RowKV extends StatelessWidget {
  final String keys;
  final String v;
  final bool emphasize;
  const _RowKV({required this.keys, required this.v, this.emphasize = false});
  @override
  Widget build(BuildContext context) {
    final style = emphasize
        ? AppTextStyles.bodyLarge.copyWith(color: AppColors.primaryColor)
        : AppTextStyles.bodySmall;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(keys, style: AppTextStyles.bodySmall),
          Text(v, style: style),
        ],
      ),
    );
  }
}

extension _OrderSummaryComputation on OrderSummarySection {
  double _sumItems() {
    double s = 0;
    for (final m in items) {
      final v = m['subtotal'];
      if (v is num) {
        s += v.toDouble();
      } else if (v is String) {
        s += double.tryParse(v) ?? 0.0;
      }
    }
    return s;
  }

  double _displaySubtotal() {
    // Prefer summing item subtotals for display consistency
    return _sumItems();
  }

  double _taxRate() {
    if (taxPercent == null) return double.nan;
    final p = taxPercent!;
    return p <= 1 ? p : p / 100.0;
  }

  double _computedFees() {
    // Only use explicit fees provided by server.
    return (verifyFees ?? 0.0).clamp(0, double.infinity);
  }

  double _computedTax() {
    final r = _taxRate();
    if (!r.isNaN) {
      // Compute tax based on item subtotal only
      return (_sumItems() * r).clamp(0, double.infinity);
    }
    return (verifyTax ?? 0).clamp(0, double.infinity);
  }

  double _computedTotal() {
    // If percent available, recompute using items + implied/explicit fees.
    final r = _taxRate();
    if (!r.isNaN) {
      final base = _sumItems() + _computedFees();
      final tax = _sumItems() * r; // tax on items only
      return (base + tax).clamp(0, double.infinity);
    }
    // Fallback to server-provided grand total logic
    if (verifyGrandTotal != null) return verifyGrandTotal!;
    final base = verifySubTotal ?? total;
    final tax = verifyTax ?? 0;
    final fees = verifyFees ?? 0;
    return (base + tax + fees).clamp(0, double.infinity);
  }
}
