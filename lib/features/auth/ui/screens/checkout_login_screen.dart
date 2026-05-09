import 'package:evento_app/app/app_colors.dart';
import 'package:evento_app/app/app_routes.dart';
import 'package:evento_app/features/auth/providers/auth_provider.dart';
import 'package:evento_app/features/common/ui/widgets/custom_app_bar.dart';
import 'package:evento_app/utils/redirect.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class CheckoutLoginScreen extends StatelessWidget {
  const CheckoutLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: CustomAppBar(
        title: '',
        onTap: () {
          Navigator.of(context).pop();
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111C29),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        onPressed: () {
                          final used = navigateToPending(
                            context,
                            auth.pendingRedirect,
                          );
                          if (used) auth.clearPendingRedirect();
                          Navigator.of(context).canPop();
                        },
                        child: Text('Checkout As Guest'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Username*',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: auth.emailController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(hintText: 'Username'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Password*',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      IconButton(
                        splashRadius: 20,
                        onPressed: auth.togglePasswordVisibility,
                        icon: Icon(
                          auth.obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                    ],
                  ),
                  TextField(
                    obscureText: auth.obscurePassword,
                    controller: auth.passwordController,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(hintText: 'Password'),
                    onSubmitted: (_) async => _submit(context, auth),
                  ),
                  const SizedBox(height: 16),
                  if (auth.errorMessage != null)
                    Center(
                      child: Text(
                        auth.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: auth.isLoading
                          ? null
                          : () => _submit(context, auth),
                      child: Text(auth.isLoading ? 'Logging in' : 'Log In'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account",
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      TextButton(
                        onPressed: () => Get.toNamed(AppRoutes.signup),
                        child: const Text('Sign Up'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _submit(BuildContext context, AuthProvider auth) async {
    final ok = await auth.login();
    if (!ok) return;
    if (!context.mounted) return;
    final used = navigateToPending(context, auth.pendingRedirect);
    if (used) auth.clearPendingRedirect();
  }
}
