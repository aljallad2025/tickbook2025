import 'dart:io';
import 'package:evento_app/features/account/data/models/customer_model.dart';
import 'package:evento_app/network_services/core/update_profile_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class UpdateProfileProvider extends ChangeNotifier {
  final Map<String, TextEditingController> controllers = {};
  CustomerModel? initialModel;
  File? selectedImage;
  bool loading = false;

  UpdateProfileProvider() {
    final fields = [
      'fname',
      'lname',
      'email',
      'username',
      'phone',
      'address',
      'country',
      'state',
      'city',
      'zip_code',
    ];
    for (final f in fields) {
      controllers[f] = TextEditingController();
    }
  }

  void initFromCustomer(CustomerModel? model) {
    initialModel = model;
    if (model == null) return;
    controllers['fname']!.text = model.fname ?? '';
    controllers['lname']!.text = model.lname ?? '';
    controllers['email']!.text = model.email ?? '';
    controllers['username']!.text = model.username ?? '';
    controllers['phone']!.text = model.phone ?? '';
    controllers['address']!.text = model.address ?? '';
    controllers['country']!.text = model.country ?? '';
    controllers['state']!.text = model.state ?? '';
    controllers['city']!.text = model.city ?? '';
    controllers['zip_code']!.text = model.zipCode ?? '';
    notifyListeners();
  }

  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return;
    final path = result.files.single.path;
    if (path == null) return;
    selectedImage = File(path);
    notifyListeners();
  }

  Future<Map<String, dynamic>> submit(String token) async {
    loading = true;
    notifyListeners();
    try {
      final existing = initialModel;
      final updated = (existing ?? CustomerModel()).copyWith(
        fname: controllers['fname']!.text.trim(),
        lname: controllers['lname']!.text.trim(),
        email: controllers['email']!.text.trim(),
        username: controllers['username']!.text.trim(),
        phone: controllers['phone']!.text.trim(),
        address: controllers['address']!.text.trim(),
        country: controllers['country']!.text.trim(),
        state: controllers['state']!.text.trim(),
        city: controllers['city']!.text.trim(),
        zipCode: controllers['zip_code']!.text.trim(),
      );

      final fields = updated.toFormFields();
      if (selectedImage == null) {
        fields.remove('photo');
      }
      final res = await UpdateProfileService.updateProfile(
        token,
        fields,
        imageFilePath: selectedImage?.path,
      );
      return res;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    for (final c in controllers.values) {
      c.dispose();
    }
    super.dispose();
  }
}
