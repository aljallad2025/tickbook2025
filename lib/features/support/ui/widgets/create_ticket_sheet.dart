import 'package:evento_app/features/common/ui/widgets/custom_cpi.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:evento_app/features/common/ui/widgets/custom_snack_bar_widget.dart';

class CreateTicketSheet extends StatefulWidget {
  final String initialEmail;
  final Future<Map<String, dynamic>> Function(
    String subject,
    String email,
    String description,
    PlatformFile? attachment,
  )
  onSubmit;

  const CreateTicketSheet({
    super.key,
    required this.initialEmail,
    required this.onSubmit,
  });

  @override
  State<CreateTicketSheet> createState() => _CreateTicketSheetState();
}

class _CreateTicketSheetState extends State<CreateTicketSheet> {
  final _subjectCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _submitting = false;
  PlatformFile? _attachment;

  @override
  void initState() {
    super.initState();
    if (widget.initialEmail.isNotEmpty) {
      _emailCtrl.text = widget.initialEmail;
    }
  }

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _emailCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create Support Ticket'.tr,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _subjectCtrl,
              decoration: InputDecoration(labelText: 'Subject'.tr),
              textInputAction: TextInputAction.next,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Subject is required'
                  : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailCtrl,
              decoration: InputDecoration(labelText: 'Email'.tr),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Email is required'.tr
                  : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descCtrl,
              decoration: InputDecoration(labelText: 'Description'.tr),
              maxLines: 4,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Description is required'
                  : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _pickFile,
                  icon: const Icon(Icons.attach_file),
                  label: Text('Attach File'.tr),
                ),
                const SizedBox(width: 8),
                if (_attachment != null)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.insert_drive_file, size: 18),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _attachment!.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          InkWell(
                            borderRadius: BorderRadius.circular(6),
                            onTap: () => setState(() => _attachment = null),
                            child: const Icon(Icons.close, size: 18),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_submitting ? '${'Submitting'.tr}...' : 'Submit'.tr),
                    const SizedBox(width: 8),
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: _submitting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CustomCPI(),
                            )
                          : const Icon(Icons.send),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    ScaffoldMessenger.of(context);
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        withData: true,
      );
      if (!mounted) return;
      if (result != null && result.files.isNotEmpty) {
        setState(() => _attachment = result.files.first);
      }
    } catch (e) {
      if (!mounted) return;
      CustomSnackBar.show(context, 'File picker unavailable');
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      final res = await widget.onSubmit(
        _subjectCtrl.text.trim(),
        _emailCtrl.text.trim(),
        _descCtrl.text.trim(),
        _attachment,
      );
      if (!mounted) return;
      Navigator.of(context).pop(res);
    } catch (e) {
      if (!mounted) return;
      CustomSnackBar.show(context, 'Create failed'.tr);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}
