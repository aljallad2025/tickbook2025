import 'package:evento_app/app/app_colors.dart';
import 'package:evento_app/features/common/ui/widgets/custom_app_bar.dart';
import 'package:evento_app/features/auth/providers/auth_provider.dart';
import 'package:evento_app/features/auth/providers/update_password_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:evento_app/features/common/ui/widgets/custom_snack_bar_widget.dart';

class UpdatePassword extends StatelessWidget {
  const UpdatePassword({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UpdatePasswordProvider(),
      child: const _UpdatePasswordBody(),
    );
  }
}

class _UpdatePasswordBody extends StatelessWidget {
  const _UpdatePasswordBody();

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    return Scaffold(
      appBar: CustomAppBar(title: 'Change Password'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Consumer<UpdatePasswordProvider>(
            builder: (context, prov, _) {
              return Form(
                key: formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: prov.currentController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Current Password'.tr,
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Required'.tr : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: prov.newController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'New Password'.tr,
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => (v == null || v.length < 6)
                          ? 'Minimum 6 characters'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: prov.confirmController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Confirm New Password'.tr,
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required'.tr;
                        if (v != prov.newController.text) {
                          return 'Does not match'.tr;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: prov.loading
                          ? null
                          : () async {
                              if (!formKey.currentState!.validate()) return;
                              final navigator = Navigator.of(context);
                              final auth = context.read<AuthProvider>();
                              final token = auth.token ?? '';
                              try {
                                final res = await prov.submit(token);
                                final ok =
                                    (res['status'] == true) ||
                                    (res['success'] == true);
                                final msg =
                                    res['message']?.toString() ??
                                    (ok ? 'Password Updated'.tr : 'Failed'.tr);
                                if (!context.mounted) return;
                                CustomSnackBar.show(context, msg);
                                if (ok) {
                                  navigator.maybePop();
                                }
                              } catch (e) {
                                CustomSnackBar.show(
                                  iconBgColor: AppColors.snackError,
                                  context,
                                  e.toString(),
                                );
                              }
                            },
                      child: prov.loading
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text('Change Password'.tr),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
