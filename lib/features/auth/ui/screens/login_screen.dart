import 'package:evento_app/app/app_colors.dart';
import 'package:evento_app/app/app_routes.dart';
import 'package:evento_app/features/auth/providers/auth_provider.dart';
import 'package:evento_app/features/auth/ui/screens/email_otp_send_screen.dart';
import 'package:evento_app/features/auth/ui/screens/signup_screen.dart';
import 'package:evento_app/features/common/ui/widgets/custom_app_bar.dart';
import 'package:evento_app/network_services/core/navigation_service.dart';
import 'package:evento_app/utils/redirect.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({
    super.key,
    this.redirectToHome = false,
    this.popOnSuccess = false,
  });

  final bool redirectToHome;
  final bool popOnSuccess;

  @override
  Widget build(BuildContext context) {
    bool didNavigate = false;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          const CustomAppBar(title: '', showSkip: true),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 80),
                    Center(
                      child: Text(
                        'Login'.tr,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111C29),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Username
                    Text(
                      '${'Username'.tr} *',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Consumer<AuthProvider>(
                      builder: (context, auth, _) {
                        return TextField(
                          controller: auth.emailController,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 16,
                            ),
                            hintText: 'Enter Username'.tr,
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // Password
                    Text(
                      '${'Password'.tr} *',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Consumer<AuthProvider>(
                      builder: (context, auth, _) {
                        return TextField(
                          obscureText: auth.obscurePassword,
                          controller: auth.passwordController,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) async {
                            if (!auth.isLoading) {
                              final ok = await auth.login();
                              if (!ok) return;
                              if (!context.mounted) return;
                              if (didNavigate) return;
                              didNavigate = true;
                              if (popOnSuccess) {
                                Navigator.pop(context, true);
                                return;
                              }
                              // Fast-path: if pending is '/account', ensure we land on BottomNav index 3
                              final pr = auth.pendingRedirect;
                              if (pr?.name == '/account') {
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                  AppRoutes.accountTab,
                                  (route) => false,
                                );
                                auth.clearPendingRedirect();
                                return;
                              }
                              final used = navigateToPending(context, pr);
                              if (used) {
                                auth.clearPendingRedirect();
                                return;
                              }
                              if (redirectToHome) {
                                // Clear stack and go to home to avoid returning to stale routes
                                Get.offAllNamed(AppRoutes.bottomNav);
                              } else {
                                Navigator.pop(context, true);
                              }
                            }
                          },
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 16,
                            ),
                            hintText: 'Enter Password'.tr,
                            suffixIcon: IconButton(
                              onPressed: auth.togglePasswordVisibility,
                              icon: Icon(
                                auth.obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // Login button
                    Consumer<AuthProvider>(
                      builder: (context, auth, _) {
                        return SizedBox(
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
                                : () async {
                                    final ok = await auth.login();
                                    if (!ok) return;
                                    if (!context.mounted) return;
                                    if (didNavigate) return;
                                    didNavigate = true;
                                    if (popOnSuccess) {
                                      Navigator.pop(context, true);
                                      return;
                                    }
                                    final pr = auth.pendingRedirect;
                                    if (pr?.name == '/account') {
                                      Navigator.of(
                                        context,
                                      ).pushNamedAndRemoveUntil(
                                        AppRoutes.accountTab,
                                        (route) => false,
                                      );
                                      auth.clearPendingRedirect();
                                      return;
                                    }
                                    final used = navigateToPending(context, pr);
                                    if (used) {
                                      auth.clearPendingRedirect();
                                      return;
                                    }
                                    if (redirectToHome) {
                                      // Clear stack and go to home to avoid returning to stale routes
                                      Get.offAllNamed(AppRoutes.bottomNav);
                                    } else {
                                      Navigator.pop(context, true);
                                    }
                                  },
                            child: Text(
                              auth.isLoading
                                  ? '${'Logging in'.tr}…'
                                  : 'Login'.tr,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 8),

                    Consumer<AuthProvider>(
                      builder: (context, auth, _) {
                        if (auth.errorMessage == null) return const SizedBox();
                        return Center(
                          child: Text(
                            auth.errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      },
                    ),

                    TextButton(
                      onPressed: () {
                        NavigationService.pushAnimated(EmailOtpSendScreen());
                      },
                      child: Row(
                        children: [
                          Text('Lost your password'.tr),
                          _qmVisibility(context),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: SafeArea(
        top: false,
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Don`t have an account".tr,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
              _qmVisibility(context),
              TextButton(
                onPressed: () {
                  NavigationService.pushAnimated(const SignUpScreen());
                },
                child: Row(children: [Text('Sign Up'.tr)]),
              ),
            ],
          ),
        ),
      ),
    );
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
