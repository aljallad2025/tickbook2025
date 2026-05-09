import 'package:evento_app/features/organizers/data/models/admin_model.dart';
import 'package:evento_app/features/organizers/data/models/organizer_model.dart';
import 'package:evento_app/utils/helpers.dart';

class BookingDetailsPageModel {
  final String pageTitle;
  final BookingDetails? booking;
  final OrganizersModel? organizer;
  final AdminModel? admin;

  BookingDetailsPageModel({
    required this.pageTitle,
    required this.booking,
    required this.organizer,
    this.admin,
  });

  factory BookingDetailsPageModel.fromRoot(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final bookingJson = data['booking'];
    final organizerJson = data['organizer'];
    final adminJson = data['admin'];
    return BookingDetailsPageModel(
      pageTitle: data['page_title']?.toString() ?? 'Booking Details',
      booking: bookingJson is Map<String, dynamic>
          ? BookingDetails.fromJson(bookingJson)
          : null,
      organizer: organizerJson is Map<String, dynamic>
          ? OrganizersModel.fromJson(organizerJson)
          : null,
      admin: adminJson is Map<String, dynamic>
          ? AdminModel.fromJson(adminJson)
          : null,
    );
  }
}

class BookingDetails {
  final int id;
  final String bookingId;
  final String eventId;
  final String? organizerId;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String country;
  final String state;
  final String city;
  final String zipCode;
  final String address;
  final String? variationRaw;
  final String price;
  final String quantity;
  final String discount;
  final String tax;
  final String commission;
  final String earlyBirdDiscount;
  final String? currencyText;
  final String? currencyTextPosition;
  final String? currencySymbol;
  final String? currencySymbolPosition;
  final String? paymentMethod;
  final String? gatewayType;
  final String paymentStatus;
  final String eventDateRaw;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? taxPercentage;
  final int? commissionPercentage;
  final int scanStatus;
  final String? invoice;

  BookingDetails({
    required this.id,
    required this.bookingId,
    required this.eventId,
    required this.organizerId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.country,
    required this.state,
    required this.city,
    required this.zipCode,
    required this.address,
    required this.variationRaw,
    required this.price,
    required this.quantity,
    required this.discount,
    required this.tax,
    required this.commission,
    required this.earlyBirdDiscount,
    required this.currencyText,
    required this.currencyTextPosition,
    required this.currencySymbol,
    required this.currencySymbolPosition,
    required this.paymentMethod,
    required this.gatewayType,
    required this.paymentStatus,
    required this.eventDateRaw,
    required this.createdAt,
    required this.updatedAt,
    required this.taxPercentage,
    required this.commissionPercentage,
    required this.scanStatus,
    this.invoice,
  });

  factory BookingDetails.fromJson(Map<String, dynamic> json) => BookingDetails(
    id: asInt(json['id']) ?? 0,
    bookingId: json['booking_id']?.toString() ?? '',
    eventId: json['event_id']?.toString() ?? '',
    organizerId: json['organizer_id']?.toString(),
    firstName: json['fname']?.toString() ?? '',
    lastName: json['lname']?.toString() ?? '',
    email: json['email']?.toString() ?? '',
    phone: json['phone']?.toString() ?? '',
    country: json['country']?.toString() ?? '',
    state: json['state']?.toString() ?? '',
    city: json['city']?.toString() ?? '',
    zipCode: json['zip_code']?.toString() ?? '',
    address: json['address']?.toString() ?? '',
    variationRaw: json['variation']?.toString(),
    price: json['price']?.toString() ?? '',
    quantity: json['quantity']?.toString() ?? '',
    discount: json['discount']?.toString() ?? '',
    tax: json['tax']?.toString() ?? '',
    commission: json['commission']?.toString() ?? '',
    earlyBirdDiscount: json['early_bird_discount']?.toString() ?? '',
    currencyText: json['currencyText']?.toString(),
    currencyTextPosition: json['currencyTextPosition']?.toString(),
    currencySymbol: json['currencySymbol']?.toString(),
    currencySymbolPosition: json['currencySymbolPosition']?.toString(),
    paymentMethod: json['paymentMethod']?.toString(),
    gatewayType: json['gatewayType']?.toString(),
    paymentStatus: json['paymentStatus']?.toString() ?? '',
    eventDateRaw: json['event_date']?.toString() ?? '',
    createdAt: asDateTime(json['created_at']),
    updatedAt: asDateTime(json['updated_at']),
    taxPercentage: asInt(json['tax_percentage']),
    commissionPercentage: asInt(json['commission_percentage']),
    scanStatus: asInt(json['scan_status']) ?? 0,
    invoice: json['invoice']?.toString(),
  );
}
