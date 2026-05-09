import 'package:flutter/material.dart';
import 'package:get/get.dart';

bool navigateToPending(BuildContext context, RouteSettings? pending) {
  if (pending == null) return false;
  Get.offAllNamed(pending.name ?? '/', arguments: pending.arguments);
  return true;
}

bool navigateToPendingWithNavigator(
  NavigatorState nav,
  RouteSettings? pending,
) {
  if (pending == null) return false;
  Get.offAllNamed(pending.name ?? '/', arguments: pending.arguments);
  return true;
}
