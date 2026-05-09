import 'dart:async';

class PaymentOutcome {
  final bool success;
  final Map<String, dynamic>? updatedData;
  final String? errorMessage;
  const PaymentOutcome._(this.success, this.updatedData, this.errorMessage);
  factory PaymentOutcome.success(Map<String, dynamic> data) => PaymentOutcome._(true, data, null);
  factory PaymentOutcome.failure(String message) => PaymentOutcome._(false, null, message);
}

abstract class IPaymentController {
  Future<PaymentOutcome> pay({
    required Map<String, dynamic> data,
    required double amount,
    required int minor,
    required String currency,
    required String fullName,
    required String email,
    required String phone,
    required String customerId,
  });
}
