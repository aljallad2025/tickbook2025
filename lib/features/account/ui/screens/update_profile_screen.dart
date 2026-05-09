import 'package:evento_app/app/app_colors.dart';
import 'package:evento_app/app/app_text_styles.dart';
import 'package:evento_app/features/common/ui/widgets/custom_app_bar.dart';
import 'package:evento_app/features/account/providers/update_profile_provider.dart';
import 'package:evento_app/features/auth/providers/auth_provider.dart';
import 'package:evento_app/features/account/data/models/customer_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:evento_app/features/common/ui/widgets/custom_snack_bar_widget.dart';

class UpdateProfileScreen extends StatelessWidget {
  const UpdateProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UpdateProfileProvider(),
      child: const _UpdateProfileScreenBody(),
    );
  }
}

class _UpdateProfileScreenBody extends StatefulWidget {
  const _UpdateProfileScreenBody();

  @override
  State<_UpdateProfileScreenBody> createState() =>
      _UpdateProfileScreenBodyState();
}

class _UpdateProfileScreenBodyState extends State<_UpdateProfileScreenBody> {
  final _formKey = GlobalKey<FormState>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = context.read<UpdateProfileProvider>();
      final auth = context.read<AuthProvider>();
      prov.initFromCustomer(auth.customerModel);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final prov = context.read<UpdateProfileProvider>();
    final auth = context.read<AuthProvider>();
    final token = auth.token ?? '';
    try {
      final res = await prov.submit(token);
      final ok = (res['success'] == true);
      final msg = res['message']?.toString() ?? (ok ? 'Updated' : 'Failed');
      if (ok && mounted) {
        CustomSnackBar.show(
          iconBgColor: ok ? AppColors.snackSuccess : AppColors.snackError,
          context,
          msg,
        );
        final updatedJson =
            res['data']?['customer_info'] as Map<String, dynamic>? ??
            res['data'] as Map<String, dynamic>?;
        if (updatedJson != null) {
          final serverModel = CustomerModel.fromJson(updatedJson);
          await auth.setCustomerModel(serverModel);
        }
        if (mounted) navigator.maybePop();
      } else {
        if (!mounted) return;
        CustomSnackBar.show(context, msg);
      }
    } catch (e) {
      if (!mounted) return;
      CustomSnackBar.show(
        iconBgColor: AppColors.snackError,
        context,
        e.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Edit Profile'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Consumer<UpdateProfileProvider>(
            builder: (context, prov, _) {
              return Form(
                key: _formKey,
                child: Column(
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: prov.pickImage,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.grey.shade500,
                                  width: 8,
                                ),
                              ),
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,

                                  color: Colors.grey.shade200,
                                  image: prov.selectedImage != null
                                      ? DecorationImage(
                                          image: FileImage(prov.selectedImage!),
                                          fit: BoxFit.cover,
                                        )
                                      : (prov.initialModel?.photo != null &&
                                            prov
                                                .initialModel!
                                                .photo!
                                                .isNotEmpty)
                                      ? DecorationImage(
                                          image: CachedNetworkImageProvider(
                                            prov.initialModel!.photo!,
                                          ),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child:
                                    (prov.selectedImage == null &&
                                        (prov.initialModel?.photo == null ||
                                            prov.initialModel!.photo!.isEmpty))
                                    ? const Center(
                                        child: Icon(
                                          Icons.camera_alt,
                                          size: 32,
                                          color: Colors.grey,
                                        ),
                                      )
                                    : null,
                              ),
                            ),

                            Positioned(
                              right: 2,
                              bottom: 2,
                              child: Material(
                                elevation: 1,
                                shape: const CircleBorder(),
                                clipBehavior: Clip.hardEdge,
                                child: CircleAvatar(
                                  backgroundColor: Colors.grey.shade50,
                                  radius: 20,
                                  child: Icon(Icons.camera_alt_outlined),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildText('First Name', 'fname', prov: prov),
                    const SizedBox(height: 8),
                    _buildText('Last Name', 'lname', prov: prov),
                    const SizedBox(height: 8),
                    _buildText(
                      'Email',
                      'email',
                      keyboard: TextInputType.emailAddress,
                      prov: prov,
                    ),
                    const SizedBox(height: 8),
                    _buildText('Username', 'username', prov: prov),
                    const SizedBox(height: 8),
                    _buildText(
                      'Phone',
                      'phone',
                      keyboard: TextInputType.phone,
                      prov: prov,
                    ),
                    const SizedBox(height: 8),
                    _buildText('Address', 'address', prov: prov),
                    const SizedBox(height: 8),
                    _buildText('Country', 'country', prov: prov),
                    const SizedBox(height: 8),
                    _buildText('State', 'state', prov: prov),
                    const SizedBox(height: 8),
                    _buildText('City', 'city', prov: prov),
                    const SizedBox(height: 8),
                    _buildText('Zip Code', 'zip_code', prov: prov),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: prov.loading ? null : () => _submit(),
                      child: prov.loading
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text('Update'.tr),
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

  Widget _buildText(
    String label,
    String key, {
    TextInputType? keyboard,
    required UpdateProfileProvider prov,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.tr,
          style: AppTextStyles.bodySmall.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: prov.controllers[key],
          keyboardType: keyboard,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintStyle: AppTextStyles.bodySmall,
            hintText: '${'Enter'.tr} ${label.tr}',
          ),
          validator: (v) {
            if ((key == 'email' || key == 'fname' || key == 'lname') &&
                (v == null || v.trim().isEmpty)) {
              return 'This field is Required';
            }
            return null;
          },
        ),
      ],
    );
  }
}
