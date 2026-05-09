import 'package:evento_app/features/account/data/models/customer_model.dart';

class CheckoutCustomerInfo {
  final String fullName;
  final String email;
  final String phone;
  final String customerId;

  const CheckoutCustomerInfo({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.customerId,
  });

  static CheckoutCustomerInfo from(
    CustomerModel? customer,
    Map<String, dynamic> rawData,
  ) {
    final fullName = () {
      final f = customer?.fname?.toString().trim();
      final l = customer?.lname?.toString().trim();
      final combined = '${f ?? ''} ${l ?? ''}'.trim();
      if (combined.isNotEmpty) return combined;
      return (rawData['fname'] ?? rawData['name'] ?? 'User').toString();
    }();
    final email = customer?.email ?? (rawData['email']?.toString() ?? '');
    final phone = customer?.phone ?? (rawData['phone']?.toString() ?? '');
    final customerId = customer?.id?.toString() ??
        rawData['customer_id']?.toString() ??
        '0';
    return CheckoutCustomerInfo(
      fullName: fullName,
      email: email,
      phone: phone,
      customerId: customerId,
    );
  }
}

