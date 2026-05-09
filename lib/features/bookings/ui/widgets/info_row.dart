import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget infoRow(
  String key,
  String value, {
  Color? vColor,
  VoidCallback? onTap,
  FontWeight fontWeight = FontWeight.normal,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 120,
        child: Text(
          key.tr,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Text(
            value.isEmpty ? '-' : value,
            style: TextStyle(
              color: vColor ?? Colors.black87,
              fontWeight: fontWeight,
            ),
          ),
        ),
      ),
    ],
  );
}
