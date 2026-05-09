import 'package:evento_app/app/assets_path.dart';
import 'package:evento_app/features/common/ui/widgets/custom_snack_bar_widget.dart';
import 'package:evento_app/network_services/core/org_email_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class ContactNowAlertDialogWidget extends StatefulWidget {
  final int organizerID;
  const ContactNowAlertDialogWidget({super.key, required this.organizerID});

  @override
  State<ContactNowAlertDialogWidget> createState() =>
      _ContactNowAlertDialogWidgetState();
}

class _ContactNowAlertDialogWidgetState
    extends State<ContactNowAlertDialogWidget> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  bool _submitting = false;

  String? _requiredValidator(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;

  String? _emailValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    final re = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return re.hasMatch(v.trim()) ? null : 'Enter a valid email';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    final name = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final subject = _subjectController.text.trim();
    final message = _messageController.text.trim();

    final result = await OrgEmailService.sendEmailToOrganizer(
      name: name,
      email: email,
      subject: subject,
      message: message,
      organizerID: widget.organizerID,
    );

    if (!mounted) return;
    CustomSnackBar.show(
      context,
      result.message,
      title: result.success ? 'Success' : 'Ops!',
    );

    if (result.success) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: Colors.white,
      child: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                _buildHeader(context),
                Divider(thickness: 1.5, color: Colors.grey.shade300),

                /// Form fields
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _fullNameController,
                        hint: 'Enter Full Name',
                        validator: _requiredValidator,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.name],
                      ),
                      _buildTextField(
                        controller: _emailController,
                        hint: 'Enter Your Email',
                        validator: _emailValidator,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                      ),
                      _buildTextField(
                        controller: _subjectController,
                        hint: 'Enter Email Subject',
                        validator: _requiredValidator,
                        textInputAction: TextInputAction.next,
                      ),
                      _buildTextField(
                        controller: _messageController,
                        hint: 'Write Your Message',
                        validator: _requiredValidator,
                        maxLines: 5,
                        textInputAction: TextInputAction.newline,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        _submitting ? null : _submit();
                      },
                      child: Text(
                        _submitting ? 'Sending...'.tr : 'Contact Now'.tr,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Header with title and close icon
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Contact Now'.tr,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SvgPicture.asset(AssetsPath.cancelSvg, width: 22),
            ),
          ),
        ],
      ),
    );
  }

  /// Styled text form field
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    List<String>? autofillHints,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: TextFormField(
        controller: controller,
        validator: validator,
        maxLines: maxLines,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        autofillHints: autofillHints,
        decoration: InputDecoration(
          hintText: hint.tr,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 16,
          ),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
