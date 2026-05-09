import 'package:evento_app/utils/helpers.dart';

class OrganizersModel {
  final int id;
  final String? name;
  final String? username;
  final String? image;
  final String? address;
  final String? phone;
  final String? email;
  final String? facebook;
  final String? twitter;
  final String? linkedin;
  final String? country;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? designation;
  final String? userType;
  final int totalEvents;
  final String? status;
  final String? details;

  OrganizersModel({
    required this.id,
    this.name,
    this.username,
    this.image,
    this.address,
    this.phone,
    this.email,
    this.facebook,
    this.twitter,
    this.linkedin,
    this.country,
    this.city,
    this.state,
    this.zipCode,
    this.designation,
    this.userType,
    this.status,
    required this.totalEvents,
    this.details,
  });

  factory OrganizersModel.fromJson(Map<String, dynamic> json) {
    return OrganizersModel(
      id: asInt(json['id']) ?? 0,
      name: (json['organizer_name'] ?? json['title'] ?? json['name'])
          .toString(),
      username: (json['username'] ?? json['user_name'] ?? '').toString(),
      image: (json['photo'] ?? json['image'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      facebook: (json['facebook'] ?? '').toString(),
      twitter: (json['twitter'] ?? '').toString(),
      linkedin: (json['linkedin'] ?? '').toString(),
      country: (json['country'] ?? '').toString(),
      city: (json['city'] ?? '').toString(),
      state: (json['state'] ?? '').toString(),
      zipCode: (json['zip_code'] ?? '').toString(),
      designation: (json['designation'] ?? '').toString(),
      userType: (json['user_type'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      totalEvents: asInt(json['total_events']) ?? 0,
      details: (json['details'] ?? '').toString(),
    );
  }
}
