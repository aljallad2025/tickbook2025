
import 'package:evento_app/app/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class AccountItemWidget extends StatelessWidget {
  final String title;
  final IconData svgIcon;
  final VoidCallback onTap;

  const AccountItemWidget({
    super.key,
    required this.title,
    required this.svgIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Row(
          children: [
            FaIcon(svgIcon, color: Colors.grey.shade600),
            const SizedBox(width: 16),
            Text(
              title.tr,
              style: AppTextStyles.headingSmall.copyWith(
                color: Colors.grey.shade800,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
