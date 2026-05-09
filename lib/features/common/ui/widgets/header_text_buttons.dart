import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HeaderTextButtons extends StatelessWidget {
  const HeaderTextButtons({
    super.key,
    required this.title,
    required this.onTap,
  });

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (title.isEmpty) return const SizedBox.shrink();

    return Row(
      children: [
        Text(
          title.tr,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const Spacer(),
        TextButton(onPressed: onTap, child: Text('View More'.tr)),
      ],
    );
  }
}
