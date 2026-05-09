import 'package:evento_app/network_services/core/password_service.dart';
import 'package:flutter/material.dart';

class UpdatePasswordProvider extends ChangeNotifier {
  final TextEditingController currentController = TextEditingController();
  final TextEditingController newController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  bool loading = false;

  void disposeControllers() {
    currentController.dispose();
    newController.dispose();
    confirmController.dispose();
  }

  Future<Map<String, dynamic>> submit(String token) async {
    loading = true;
    notifyListeners();
    try {
      final fields = {
        'current_password': currentController.text.trim(),
        'new_password': newController.text.trim(),
        'new_password_confirmation': confirmController.text.trim(),
      };
      final res = await PasswordService.updatePassword(token, fields);
      return res;
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
