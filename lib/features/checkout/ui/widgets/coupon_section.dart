import 'package:flutter/material.dart';
import 'package:evento_app/app/app_text_styles.dart';
import 'package:evento_app/network_services/core/coupon_service.dart';

class CouponSection extends StatelessWidget {
  final TextEditingController controller;
  final bool applying;
  final double total;
  final Map<String, dynamic> data;
  final ValueChanged<double> onDiscount;
  final ValueChanged<String?> onMessage;
  const CouponSection({
    super.key,
    required this.controller,
    required this.applying,
    required this.total,
    required this.data,
    required this.onDiscount,
    required this.onMessage,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Coupon', style: AppTextStyles.headingMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 4,
              child: SizedBox(
                height: 46,
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 16,
                    ),
                    hintText: 'Enter coupon code',
                    hintStyle: AppTextStyles.bodySmall,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade300),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        bottomLeft: Radius.circular(8),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade300),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        bottomLeft: Radius.circular(8),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade300),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        bottomLeft: Radius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: SizedBox(
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                  ),
                  onPressed: applying
                      ? null
                      : () async {
                          final code = controller.text.trim();
                          if (code.isEmpty) return;
                          onMessage(null);
                          // event id resolution
                          final int? eventId = int.tryParse(
                            (data['event_id'] ?? data['eventId'] ?? '')
                                .toString(),
                          );
                          if (eventId == null) {
                            onMessage('Event id missing');
                            return;
                          }
                          try {
                            final double earlyBirdTotal = () {
                              final v = data['total_early_bird_dicount'];
                              if (v is num) return v.toDouble();
                              if (v is String) return double.tryParse(v) ?? 0.0;
                              return 0.0;
                            }();
                            final res = await CouponService.apply(
                              eventId: eventId,
                              couponCode: code,
                              price: total,
                              totalEarlyBirdDicount: earlyBirdTotal,
                            );
                            if (!res.success || res.discount <= 0) {
                              String msg = res.message.isNotEmpty
                                  ? res.message
                                  : 'Invalid coupon';
                              if (res.validationErrors.isNotEmpty) {
                                final firstList =
                                    res.validationErrors.values.first;
                                if (firstList.isNotEmpty) msg = firstList.first;
                              }
                              onDiscount(0);
                              onMessage(msg);
                            } else {
                              onDiscount(res.discount);
                              onMessage(
                                res.message.isNotEmpty
                                    ? res.message
                                    : 'Coupon applied',
                              );
                            }
                          } catch (e) {
                            onMessage('Error applying coupon');
                          }
                        },
                  child: applying
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Apply',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
