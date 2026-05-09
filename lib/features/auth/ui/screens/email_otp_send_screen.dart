import 'package:evento_app/app/app_colors.dart';
import 'package:evento_app/features/common/ui/widgets/custom_app_bar.dart';
import 'package:evento_app/features/common/ui/widgets/network_app_logo.dart';
import 'package:evento_app/network_services/core/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:evento_app/features/common/ui/widgets/custom_snack_bar_widget.dart';

class EmailOtpSendScreen extends StatefulWidget {
  const EmailOtpSendScreen({super.key});

  static const routeName = '/auth/forget';

  @override
  State<EmailOtpSendScreen> createState() => _EmailOtpSendScreenState();
}

class _EmailOtpSendScreenState extends State<EmailOtpSendScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _loading = false;

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      CustomSnackBar.show(
        iconBgColor: AppColors.snackError,
        context,
        'Please enter email'.tr,
      );
      return;
    }
    setState(() => _loading = true);
    final res = await AuthServices.sendPasswordResetEmail(email: email);
    setState(() => _loading = false);
    if (res['success'] == true ||
        res['status'] == 'success' ||
        res['status'] == 'ok') {
      if (!mounted) return;
      CustomSnackBar.show(context, res['message']?.toString() ?? 'OTP Sent'.tr);

      try {} catch (_) {}
      Get.toNamed('/auth/otp-verify', arguments: {'email': email});
    } else {
      if (!mounted) return;
      CustomSnackBar.show(
        iconBgColor: AppColors.snackError,
        context,
        res['message']?.toString() ?? 'Failed to send OTP'.tr,
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Send OTP'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 60),
              NetworkAppLogo(height: 50),
              const SizedBox(height: 40),
              FittedBox(
                child: Text(
                  'Enter your email to receive an OTP for password reset.'.tr,
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: 'Email'.tr),
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
                    : Text('Send OTP'.tr),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
