import 'package:evento_app/app/app_colors.dart';
import 'package:evento_app/app/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class DescriptionSection extends StatelessWidget {
  const DescriptionSection({super.key, this.textHtml});
  final String? textHtml;
  @override
  Widget build(BuildContext context) {
    final html = (textHtml ?? '').trim();
    if (html.isEmpty) return const Text('No description');
    return Html(data: html);
  }
}

class RefundSection extends StatelessWidget {
  const RefundSection({super.key, this.text});
  final String? text;
  @override
  Widget build(BuildContext context) {
    final t = (text ?? '').trim();
    if (t.isEmpty) return const Text('No refund policy');
    return Html(data: t);
  }
}

class OnlineEventNotice extends StatelessWidget {
  const OnlineEventNotice({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(top: 8, bottom: 16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.wifi_tethering, color: AppColors.primaryColor),
              const SizedBox(width: 8),
              Text(
                'Online Event',
                style: AppTextStyles.headingSmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'This event will be held online. A meeting / streaming link and any necessary instructions will be provided after you purchase a ticket (or closer to the start time).',
            style: AppTextStyles.bodyLargeGrey.copyWith(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
