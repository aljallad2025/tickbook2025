import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:evento_app/app/app_colors.dart';

class CustomSnackBar {
  CustomSnackBar._();

  static void show(
    BuildContext context,
    String message, {
    bool showTitle = false,
    String title = 'Success',
    Duration duration = const Duration(seconds: 2),
    Color backgroundColor = Colors.black,
    Color textColor = Colors.white,
    double borderRadius = 12,
    Color? iconBgColor = AppColors.snackSuccess,
    IconData? icon = Icons.check,
    bool floating = true,
  }) {
    final String translatedMessage = _safeTr(message);
    final String translatedTitle = _safeTr(title);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        ScaffoldMessenger.of(context).clearSnackBars();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: duration,
            elevation: floating ? 8 : 2,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            padding: EdgeInsets.zero,

            // 👇 THIS MAKES IT TOP POSITIONED
            margin: const EdgeInsets.fromLTRB(
              12,
              kToolbarHeight + 20, // push below status + app bar
              12,
              0,
            ),

            content: _buildContent(
              context: context,
              message: translatedMessage,
              title: translatedTitle,
              showTitle: showTitle,
              backgroundColor: backgroundColor,
              textColor: textColor,
              borderRadius: borderRadius,
              iconBgColor: iconBgColor,
              icon: icon,
            ),
          ),
        );
      } catch (e, s) {
        debugPrint('CustomSnackBar error: $e\n$s');
      }
    });
  }

  static Widget _buildContent({
    required BuildContext context,
    required String message,
    required String title,
    required bool showTitle,
    required Color backgroundColor,
    required Color textColor,
    required double borderRadius,
    required Color? iconBgColor,
    required IconData? icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: const [
          BoxShadow(blurRadius: 8, offset: Offset(0, 4), color: Colors.black26),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null)
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBgColor ?? AppColors.snackSuccess,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
          if (icon != null) const SizedBox(width: 12),

          // ----- TEXT -----
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showTitle)
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                if (showTitle) const SizedBox(height: 3),
                Text(
                  message,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: textColor, fontSize: 13),
                ),
              ],
            ),
          ),

          // ----- CLOSE BUTTON -----
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.close, size: 18, color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  static String _safeTr(String key) {
    try {
      return key.tr;
    } catch (_) {
      return key;
    }
  }
}
