import 'package:evento_app/features/categories/models/category_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoryDropdown extends StatelessWidget {
  final CategoryModel? selectedCategory;
  final List<CategoryModel> categories;
  final ValueChanged<CategoryModel?> onChanged;

  const CategoryDropdown({
    super.key,
    required this.selectedCategory,
    required this.categories,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isNotEmpty) {
      return DropdownButtonFormField<CategoryModel?>(
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(12),
        initialValue: selectedCategory,
        decoration: InputDecoration(labelText: 'Category'.tr),
        items: [
          DropdownMenuItem<CategoryModel?>(value: null, child: Text('Any'.tr)),
          ...categories.map(
            (c) =>
                DropdownMenuItem<CategoryModel?>(value: c, child: Text(c.name)),
          ),
        ],
        onChanged: onChanged,
      );
    } else {
      return TextField(
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.left,
        decoration: InputDecoration(labelText: 'Category (name)'.tr),
      );
    }
  }
}

class EventTypeDropdown extends StatelessWidget {
  final String? eventType;
  final ValueChanged<String?> onChanged;

  const EventTypeDropdown({
    super.key,
    required this.eventType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String?>(
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(12),
      initialValue: eventType,
      decoration: InputDecoration(labelText: 'Event Type'.tr),
      items: [
        DropdownMenuItem<String?>(value: null, child: Text('Any'.tr)),
        DropdownMenuItem<String?>(value: 'online', child: Text('Online'.tr)),
        DropdownMenuItem<String?>(value: 'venue', child: Text('Venue'.tr)),
      ],
      onChanged: onChanged,
    );
  }
}
