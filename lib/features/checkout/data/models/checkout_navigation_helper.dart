import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:evento_app/network_services/core/navigation_service.dart';
import 'package:evento_app/features/checkout/ui/screens/checkout_success_screen.dart';

class CheckoutNavigationHelper {
  static void goToSuccess(Map<String, dynamic> successArgs) {
    try {
      final nav = NavigationService.navigator;
      if (nav != null) {
        nav.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => CheckoutSuccessScreen(arguments: successArgs),
          ),
          (Route<dynamic> r) => false,
        );
        return;
      }
    } catch (e) {
      assert(() { return true; }());
    }
    try {
      Get.offAll(() => CheckoutSuccessScreen(arguments: successArgs));
    } catch (e) {
      assert(() { return true; }());
    }
  }
}
