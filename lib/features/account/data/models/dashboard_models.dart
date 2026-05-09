import 'package:evento_app/features/bookings/data/models/booking_models.dart';

class AuthUserModel {
  final int id;
  final String name;
  final String email;
  final String photo;
  final String username;
  final String phone;
  final String address;
  final String country;
  final String city;
  final String firstName;
  final String lastName;

  AuthUserModel({
    required this.id,
    required this.name,
    required this.email,
    this.photo = '',
    this.username = '',
    this.phone = '',
    this.address = '',
    this.country = '',
    this.city = '',
    this.firstName = '',
    this.lastName = '',
  });

  String get fullName {
    if (firstName.isNotEmpty || lastName.isNotEmpty) {
      return [firstName, lastName].where((s) => s.isNotEmpty).join(' ');
    }
    return name.isNotEmpty ? name : username;
  }

  factory AuthUserModel.fromJson(Map<String, dynamic> json) => AuthUserModel(
    id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
    name:
        json['fname']?.toString() ??
        json['name']?.toString() ??
        json['full_name']?.toString() ??
        '',
    email: json['email']?.toString() ?? '',
    photo: json['photo']?.toString() ?? '',
    username:
        json['username']?.toString() ?? json['user_name']?.toString() ?? '',
    phone: json['phone']?.toString() ?? json['mobile']?.toString() ?? '',
    address: json['address']?.toString() ?? '',
    country: json['country']?.toString() ?? '',
    city: json['city']?.toString() ?? '',
    firstName:
        json['first_name']?.toString() ?? json['fname']?.toString() ?? '',
    lastName: json['last_name']?.toString() ?? json['lname']?.toString() ?? '',
  );
}

class DashboardResponseModel {
  final String pageTitle;
  final AuthUserModel? authUser;
  final List<BookingItemModel> bookings;

  DashboardResponseModel({
    required this.pageTitle,
    required this.authUser,
    required this.bookings,
  });

  factory DashboardResponseModel.fromJson(Map<String, dynamic> json) {
    return DashboardResponseModel(
      pageTitle:
          json['page_title']?.toString() ?? json['pageTitle']?.toString() ?? '',
      authUser: json['auth_user'] != null
          ? AuthUserModel.fromJson(json['auth_user'])
          : null,
      bookings: (json['bookings'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(BookingItemModel.fromJson)
          .toList(),
    );
  }

  /// Convenience getter for UI
  String get userFullName => authUser?.fullName ?? '';
}
