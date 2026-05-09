import 'package:flutter/material.dart';
import 'package:evento_app/app/app_colors.dart';

class SeatingButton extends StatelessWidget {
  final VoidCallback? onPressed;
  const SeatingButton({super.key, this.onPressed});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          minimumSize: Size.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        onPressed: onPressed,
        child: const Text(
          'Choose Seats',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

