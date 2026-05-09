import 'package:flutter/material.dart';

class QtyStepper extends StatelessWidget {
  final int value;
  final VoidCallback onInc;
  final VoidCallback onDec;
  const QtyStepper({
    super.key,
    required this.value,
    required this.onInc,
    required this.onDec,
  });
  @override
  Widget build(BuildContext context) {
    final borderColor = Colors.grey.shade300;
    const double cellSize = 32;
    final radius = BorderRadius.circular(6);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderColor),
        borderRadius: radius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _stepperCell(onTap: onDec, icon: Icons.remove, size: cellSize),
          Container(width: 1, height: cellSize, color: borderColor),
          Container(
            alignment: Alignment.center,
            constraints: const BoxConstraints(minWidth: cellSize),
            height: cellSize,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text('$value', style: const TextStyle(fontSize: 13)),
          ),
          Container(width: 1, height: cellSize, color: borderColor),
          _stepperCell(onTap: onInc, icon: Icons.add, size: cellSize),
        ],
      ),
    );
  }

  Widget _stepperCell({
    required VoidCallback onTap,
    required IconData icon,
    required double size,
  }) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: Icon(icon, size: 16, color: Colors.black87),
      ),
    );
  }
}

