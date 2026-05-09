import 'package:evento_app/utils/helpers.dart';

class AdminModel {
  final int id;
  final int? roleId;
  final String firstName;
  final String lastName;
  final String image;
  final String username;
  final String email;
  final String? phone;
  final String? address;
  final String? details;
  final int? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AdminModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.image,
    required this.username,
    required this.email,
    this.roleId,
    this.phone,
    this.address,
    this.details,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory AdminModel.fromJson(Map<String, dynamic> json) => AdminModel(
        id: asInt(json['id']) ?? 0,
        roleId: asInt(json['role_id']),
        firstName: (json['first_name'] ?? '').toString(),
        lastName: (json['last_name'] ?? '').toString(),
        image: (json['image'] ?? '').toString(),
        username: (json['username'] ?? '').toString(),
        email: (json['email'] ?? '').toString(),
        phone: json['phone']?.toString(),
        address: json['address']?.toString(),
        details: json['details']?.toString(),
        status: asInt(json['status']),
        createdAt: asDateTime(json['created_at']),
        updatedAt: asDateTime(json['updated_at']),
      );
}
