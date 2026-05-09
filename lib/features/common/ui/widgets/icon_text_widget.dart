import 'package:evento_app/app/app_colors.dart';
import 'package:flutter/material.dart';

class IconTextWidgetSpan extends StatelessWidget {
  final String data;
  final IconData icon;
  const IconTextWidgetSpan({super.key, required this.data, required this.icon});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          WidgetSpan(
            child: Icon(icon, size: 16, color: AppColors.primaryColor),
          ),
          const WidgetSpan(child: SizedBox(width: 4)),
          TextSpan(
            text: data,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
          ),
        ],
      ),
    );
  }
}
