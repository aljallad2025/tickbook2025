import 'package:flutter/material.dart';

class LegendDot extends StatelessWidget {
  final Color color;
  const LegendDot({super.key, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

