import 'package:evento_app/app/app_colors.dart';
import 'package:evento_app/app/app_text_styles.dart';
import 'package:evento_app/features/common/ui/widgets/custom_snack_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class InvoiceButton extends StatelessWidget {
  final Map<String, dynamic> bookingInfo;
  const InvoiceButton({super.key, required this.bookingInfo});
  @override
  Widget build(BuildContext context) {
    final invoice = bookingInfo['invoice']?.toString();
    if (invoice == null || invoice.isEmpty) {
      return const SizedBox.shrink();
    }
    final uri = Uri.tryParse(invoice);
    String fileNameFromUrl(String url) {
      try {
        final u = Uri.parse(url);
        final seg = u.pathSegments;
        return seg.isNotEmpty ? seg.last : 'invoice.pdf';
      } catch (_) {
        return 'invoice.pdf';
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primaryColor,
            child: const Icon(
              Icons.picture_as_pdf,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Invoice'),
                const SizedBox(height: 2),
                Text(
                  fileNameFromUrl(invoice),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 120,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.download, size: 18),
              label: const Text('Open'),
              onPressed: () async {
                if (uri == null) {
                  CustomSnackBar.show(
                    iconBgColor: AppColors.snackError,
                    context,
                    'Invalid invoice URL',
                  );
                  return;
                }
                final ok = await launchUrl(
                  uri,
                  mode: LaunchMode.externalApplication,
                );
                if (!ok && context.mounted) {
                  CustomSnackBar.show(
                    iconBgColor: AppColors.snackError,
                    context,
                    'Could not open invoice',
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

