import 'package:evento_app/app/app_colors.dart';
import 'package:evento_app/features/auth/providers/auth_provider.dart';
import 'package:evento_app/app/app_routes.dart';
import 'package:evento_app/features/common/ui/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const CustomAppBar(title: '', showSkip: false),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 40),
                        Center(
                          child: Text(
                            'Create Account'.tr,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111C29),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        _label('First Name'),
                        TextField(
                          controller: auth.firstNameController,
                          textInputAction: TextInputAction.next,
                          decoration: _inputDecoration('Enter Your First Name'),
                        ),
                        const SizedBox(height: 16),
                        _label('Last Name'),
                        TextField(
                          controller: auth.lastNameController,
                          textInputAction: TextInputAction.next,
                          decoration: _inputDecoration('Enter Your Last Name'),
                        ),
                        const SizedBox(height: 16),
                        _label('Username'),
                        TextField(
                          controller: auth.usernameController,
                          textInputAction: TextInputAction.next,
                          decoration: _inputDecoration('Choose a username'),
                        ),
                        const SizedBox(height: 16),
                        _label('Email Address'),
                        TextField(
                          controller: auth.emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: _inputDecoration(
                            'Enter Your Email Address',
                          ),
                        ),
                        const SizedBox(height: 16),
                        _label('Password'),
                        TextField(
                          controller: auth.passwordController,
                          obscureText: auth.obscurePassword,
                          textInputAction: TextInputAction.next,
                          decoration: _inputDecoration('Enter Password')
                              .copyWith(
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    auth.obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: AppColors.primaryColor,
                                  ),
                                  onPressed: auth.togglePasswordVisibility,
                                ),
                              ),
                        ),
                        const SizedBox(height: 16),
                        _label('Re-enter Password'),
                        TextField(
                          controller: auth.confirmPasswordController,
                          obscureText: auth.obscurePassword,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _submit(context, auth),
                          decoration: _inputDecoration('Confirm Password'.tr),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: AppColors.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: auth.isLoading
                                ? null
                                : () => _submit(context, auth),
                            child: Text(
                              auth.isLoading
                                  ? '${'Creating Account'.tr}…'
                                  : 'Sign Up'.tr,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (auth.errorMessage != null)
                          Center(
                            child: Text(
                              auth.errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account'.tr,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            _qmVisibility(context),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Login'.tr),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) =>
      Text('${text.tr} *', style: const TextStyle(fontWeight: FontWeight.w600));

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    hintText: hint.tr,
  );

  Future<void> _submit(BuildContext context, AuthProvider auth) async {
    final ok = await auth.signup();
    if (!context.mounted) return;
    if (ok) {
      Navigator.pushReplacementNamed(context, AppRoutes.signup);
    }
  }

  Visibility _qmVisibility(BuildContext context, {Color color = Colors.grey}) {
    return Visibility(
      visible: Directionality.of(context) == TextDirection.ltr,
      child: Text(
        " ?",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}
