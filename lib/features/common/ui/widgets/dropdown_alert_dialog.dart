import 'package:evento_app/app/assets_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum DialogType { dropdown, calendar }

class DropdownAlertDialog extends StatefulWidget {
  final String title;
  final String? btnTitle;
  final String drpDownTitle;
  final DialogType dialogType;
  final List<String>? items;
  final String? initialValue;
  final Function(dynamic) onConfirm;

  const DropdownAlertDialog({
    super.key,
    required this.title,
    required this.dialogType,
    this.items,
    this.initialValue,
    required this.onConfirm,
    this.btnTitle,
    this.drpDownTitle = 'Select Service',
  });

  @override
  State<DropdownAlertDialog> createState() => _DropdownAlertDialogState();
}

class _DropdownAlertDialogState extends State<DropdownAlertDialog> {
  String? selectedValue;
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.initialValue;
    selectedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDropdown = widget.dialogType == DialogType.dropdown;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: Colors.white,
      child: SizedBox(
        width: double.infinity,
        height: isDropdown ? 250 : 440,
        child: Column(
          children: [
            _buildHeader(context),
            Divider(thickness: 1.5, color: Colors.grey.shade300),
            const SizedBox(height: 8),
            if (isDropdown) _buildDropdown() else _buildCalendar(),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onConfirm(isDropdown ? selectedValue : selectedDate);
                    Navigator.pop(context);
                  },
                  child: Text(
                    widget.btnTitle ??
                        (isDropdown ? 'Assign Service' : 'Select Date'),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SvgPicture.asset(AssetsPath.cancelSvg, width: 22),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the dropdown menu
  Widget _buildDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        height: 56,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedValue,
            hint: Text(widget.drpDownTitle),
            borderRadius: BorderRadius.circular(12),
            dropdownColor: Colors.white,
            items:
                widget.items?.map((item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList() ??
                [],
            onChanged: (value) => setState(() => selectedValue = value),
          ),
        ),
      ),
    );
  }

  /// Builds the calendar date picker
  Widget _buildCalendar() {
    return SizedBox(
      height: 270,
      child: CalendarDatePicker(
        initialDate: selectedDate ?? DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)),
        onDateChanged: (date) => setState(() => selectedDate = date),
      ),
    );
  }
}
