import 'package:evento_app/app/app_colors.dart';
import 'package:evento_app/features/common/ui/widgets/custom_app_bar.dart';
import 'package:evento_app/features/common/ui/widgets/network_app_logo.dart';
import 'package:evento_app/network_services/core/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:evento_app/features/common/ui/widgets/custom_snack_bar_widget.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  String? _email;
  String? _code;
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _pw2Controller = TextEditingController();
  bool _loading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    dynamic args = ModalRoute.of(context)?.settings.arguments;
    args ??= Get.arguments;
    if (args is Map) {
      if (args['email'] is String) _email = args['email'] as String;
      if (args['code'] is String) _code = args['code'] as String;
    }
  }

  Future<void> _submit() async {
    final pw = _pwController.text.trim();
    final pw2 = _pw2Controller.text.trim();
    if (_email == null || _email!.isEmpty) {
      CustomSnackBar.show(
        iconBgColor: AppColors.snackError,
        context,
        'Missing email'.tr,
      );
      return;
    }
    if (_code == null || _code!.isEmpty) {
      CustomSnackBar.show(
        iconBgColor: AppColors.snackError,
        context,
        'Missing OTP'.tr,
      );
      return;
    }
    if (pw.isEmpty || pw2.isEmpty) {
      CustomSnackBar.show(
        iconBgColor: AppColors.snackError,
        context,
        'Re-enter Password'.tr,
      );
      return;
    }
    if (pw != pw2) {
      CustomSnackBar.show(
        iconBgColor: AppColors.snackError,
        context,
        'Passwords do not match'.tr,
      );
      return;
    }
    setState(() => _loading = true);
    final res = await AuthServices.resetPasswordWithCode(
      email: _email!,
      code: _code!,
      newPassword: pw,
      newPasswordConfirmation: pw2,
    );
    setState(() => _loading = false);
    if (res['status'] == 'success' || res['success'] == true) {
      if (!mounted) return;
      CustomSnackBar.show(
        context,
        res['message']?.toString() ?? 'Password updated successfully'.tr,
      );
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      if (!mounted) return;
      CustomSnackBar.show(
        iconBgColor: res['status'] == 'success'
            ? AppColors.snackSuccess
            : AppColors.snackError,
        context,
        res['message']?.toString() ?? 'Failed to update password'.tr,
      );
    }
  }

  @override
  void dispose() {
    _pwController.dispose();
    _pw2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Reset Password'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 60),
              NetworkAppLogo(height: 50),
              const SizedBox(height: 40),
              Row(
                children: [
                  Text('Resetting password for '.tr),
                  Text(
                    _email ?? 'Your Email'.tr,
                    style: TextStyle(color: AppColors.primaryColor),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _pwController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'New Password'.tr),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _pw2Controller,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Confirm Password'.tr),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text('Reset Password'.tr),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
