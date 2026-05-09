import 'package:evento_app/app/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InformationCardWidget extends StatelessWidget {
  final VoidCallback? onTap;
  final String cardTitle;
  final List<MapEntry<String, String>> infoEntries;
  final bool showSecondCell;
  final bool showThirdCell;
  final Color? textColor;
  final Map<String, Color>? customTextColors;
  final int leftFlex;
  final int rightFlex;
  final TextAlign textAlign;
  final int? tappableIndex;
  final bool showArrow;

  const InformationCardWidget({
    super.key,
    required this.cardTitle,
    required this.infoEntries,
    this.showSecondCell = true,
    this.showThirdCell = false,
    this.textColor = Colors.black54,
    this.customTextColors,
    this.onTap,
    this.tappableIndex,
    this.leftFlex = 4,
    this.rightFlex = 5,
    this.textAlign = TextAlign.end,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;
    return Card(
      color: Colors.grey.shade50,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Center(
            child: Text(
              cardTitle.tr,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Divider(color: Colors.grey.shade300, thickness: 1.5),
          const SizedBox(height: 10),

          ...infoEntries.asMap().entries.map((entryWithIndex) {
            final index = entryWithIndex.key;
            final entry = entryWithIndex.value;

            final valueColor =
                customTextColors != null &&
                    customTextColors!.containsKey(entry.key)
                ? customTextColors![entry.key]
                : textColor;

            Widget valueText = Text(
              entry.value.tr,
              textAlign: textAlign,
              style: TextStyle(
                color: valueColor,
                fontWeight: FontWeight.w400,
                fontSize: 16,
              ),
            );

            if (tappableIndex != null &&
                tappableIndex == index &&
                onTap != null) {
              valueText = GestureDetector(
                onTap: () => onTap!(),
                child: Text(
                  entry.value,
                  textAlign: textAlign,
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: leftFlex,
                    child: Text(
                      entry.key.tr,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  if (showArrow)
                    Expanded(
                      child: Icon(
                        isRtl
                            ? Icons.arrow_circle_left_outlined
                            : Icons.arrow_circle_right_outlined,
                        size: 20,
                      ),
                    ),
                  Expanded(flex: rightFlex, child: valueText),
                ],
              ),
            );
          }),

          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
