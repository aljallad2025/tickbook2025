import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class AppColors {
  static Color primaryColor = const Color(0xff1a3a8f);
  static const Color secondaryColor = Color(0xffffffff);

  // Notifier to trigger theme rebuilds when branding changes.
  static final ValueNotifier<int> _themeVersion = ValueNotifier<int>(0);
  static ValueListenable<int> get themeVersion => _themeVersion;

  static void applyBrand({required Color primary}) {
    primaryColor = primary;
    try {
      _themeVersion.value++;
    } catch (_) {}
  }

  // ───── Accent & Supporting Colors ─────
  static const Color colorFill = Color(0xFF111C29);
  static const Color colorBg = Color(0xFF1B2733);

  static const Color snackError = Color(0xffFF0000);
  static const Color snackSuccess = Color(0xff008000);

  // ───── Global Gradient Style ─────
  static LinearGradient get themeGradient => LinearGradient(
    colors: [primaryColor, secondaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
