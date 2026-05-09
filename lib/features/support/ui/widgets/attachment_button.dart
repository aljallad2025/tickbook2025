import 'package:evento_app/app/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:evento_app/features/common/ui/widgets/custom_snack_bar_widget.dart';

class AttachmentButton extends StatelessWidget {
  final String url;
  final EdgeInsets padding;
  final double iconSize;
  final double borderRadius;
  final String label;

  const AttachmentButton({
    super.key,
    required this.url,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    this.iconSize = 20,
    this.borderRadius = 6,
    this.label = 'Attachment',
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(borderRadius),
      onTap: () async {
        ScaffoldMessenger.of(context);
        Uri? uri;
        try {
          uri = Uri.parse(url.trim());
        } catch (_) {}
        if (uri != null) {
          try {
            bool opened = false;
            try {
              final can = await canLaunchUrl(uri);
              if (can) {
                opened = await launchUrl(
                  uri,
                  mode: LaunchMode.externalApplication,
                );
              }
            } catch (_) {}
            if (!opened) {
              opened = await launchUrl(
                uri,
                mode: LaunchMode.externalApplication,
              );
            }
            if (!opened && context.mounted) {
              CustomSnackBar.show(
                iconBgColor: AppColors.snackError,
                context,
                'Unable to open attachment',
              );
            }
          } catch (e) {
            if (context.mounted) {
              CustomSnackBar.show(
                iconBgColor: AppColors.snackError,
                context,
                'Open failed: $e',
              );
            }
          }
        } else {
          CustomSnackBar.show(
            iconBgColor: AppColors.snackError,
            context,
            'Invalid attachment link',
          );
        }
      },
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label.tr, style: const TextStyle(color: Colors.white)),
            const SizedBox(width: 4),
            Icon(Icons.download_rounded, size: iconSize, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
