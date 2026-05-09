import 'package:flutter/material.dart';
import 'package:evento_app/app/app_text_styles.dart';

class KvRow extends StatelessWidget {
  final String keys;
  final String values;
  final Color? color;
  const KvRow(this.keys, this.values, {this.color = Colors.black, super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(keys, style: AppTextStyles.bodySmall),
          ),
          Expanded(
            child: Text(
              values,
              style: AppTextStyles.bodySmall.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

