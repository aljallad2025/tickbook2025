import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LocationTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final VoidCallback? onLocate;
  final bool locating;

  const LocationTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.onLocate,
    this.locating = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText.tr,
        suffixIcon: onLocate == null
            ? null
            : IconButton(
                tooltip: 'Use Current Location'.tr,
                icon: locating
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.my_location),
                onPressed: locating ? null : onLocate,
              ),
      ),
    );
  }
}