import 'package:evento_app/app/app_colors.dart';
import 'package:evento_app/features/common/ui/widgets/custom_app_bar.dart';
import 'package:evento_app/features/common/ui/widgets/network_app_logo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:evento_app/features/common/ui/widgets/custom_snack_bar_widget.dart';
import 'package:pinput/pinput.dart';

class OtpVerifyScreen extends StatefulWidget {
  const OtpVerifyScreen({super.key});

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  String? _email;
  String _code = '';
  bool _loading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    dynamic args = ModalRoute.of(context)?.settings.arguments;
    args ??= Get.arguments;
    if (args is Map && args['email'] is String) {
      _email = args['email'] as String;
    }
  }

  Future<void> _submit() async {
    if (_email == null || _email!.isEmpty) {
      CustomSnackBar.show(
        iconBgColor: AppColors.snackError,
        context,
        'Missing email'.tr,
      );
      return;
    }
    if (_code.isEmpty) {
      CustomSnackBar.show(
        iconBgColor: AppColors.snackError,
        context,
        'Please enter the OTP'.tr,
      );
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() => _loading = false);
    Get.toNamed(
      '/auth/reset-password',
      arguments: {'email': _email, 'code': _code},
    );
  }

  @override
  Widget build(BuildContext context) {
    final pinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(fontSize: 20, color: Colors.black),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
    );

    return Scaffold(
      appBar: CustomAppBar(title: 'Verify OTP'),
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
                  Text('Enter the code sent to '.tr),
                  Text(
                    _email ?? 'Your Email'.tr,
                    style: TextStyle(color: AppColors.primaryColor),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Pinput(
                length: 6,
                defaultPinTheme: pinTheme,
                onChanged: (v) => _code = v,
                onCompleted: (v) => _code = v,
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
                    : Text('Verify'.tr),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
