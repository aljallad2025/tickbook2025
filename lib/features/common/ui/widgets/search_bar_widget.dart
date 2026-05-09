import 'package:evento_app/app/app_colors.dart';
import 'package:evento_app/app/assets_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class SearchBarWidget extends StatelessWidget {
  final Color backgroundColor;
  final Color textFieldFillColor;
  final Color borderColor;
  final Color iconColor;
  final Color hintTextColor;
  final String hintText;
  final VoidCallback? onFilterTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextEditingController? controller;
  final bool showClearButton;
  final VoidCallback? onClear;
  final bool showFilterButton;

  const SearchBarWidget({
    super.key,
    this.backgroundColor = AppColors.colorBg,
    this.textFieldFillColor = AppColors.colorFill,
    this.borderColor = const Color(0xFFCCCCCC),
    this.iconColor = Colors.white70,
    this.hintTextColor = const Color(0xFF9E9E9E),
    this.hintText = 'Search for Events',
    this.onFilterTap,
    this.onChanged,
    this.onSubmitted,
    this.controller,
    this.showClearButton = false,
    this.onClear,
    this.showFilterButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: textFieldFillColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: borderColor.withValues(alpha: 0.5)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 52,
      child: Row(
        children: [
          SvgPicture.asset(
            AssetsPath.searchSvg,
            height: 22,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              // Force LTR typing to avoid reversed text in RTL locales
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.left,
              textInputAction: TextInputAction.search,
              onSubmitted: (text) {
                if (onSubmitted != null) {
                  onSubmitted!(text);
                }
                FocusScope.of(context).unfocus();
              },
              onEditingComplete: () => FocusScope.of(context).unfocus(),
              style: const TextStyle(fontWeight: FontWeight.w500),
              cursorColor: iconColor,
              decoration: InputDecoration(
                hintText: hintText.tr,
                hintStyle: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: hintTextColor,
                ),
                fillColor: textFieldFillColor,
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(width: 10),
          if (showClearButton)
            InkWell(
              onTap: onClear,
              borderRadius: BorderRadius.circular(99),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.clear, size: 20, color: iconColor),
              ),
            ),
          if (showClearButton) const SizedBox(width: 4),
          if (showFilterButton)
            GestureDetector(
              onTap: onFilterTap,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  AssetsPath.filterSvg,
                  height: 22,
                  colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
