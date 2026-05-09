import 'package:evento_app/network_services/pgw_services/razorpay.dart';
import 'base_pgw_controller.dart';

class RazorpayController implements IPaymentController {
  @override
  Future<PaymentOutcome> pay({
    required Map<String, dynamic> data,
    required double amount,
    required int minor,
    required String currency,
    required String fullName,
    required String email,
    required String phone,
    required String customerId,
  }) async {
    final rz = await RazorpaySdkGateway.startCheckout(
      amountMinor: minor,
      name: fullName,
      currency: currency,
      email: email,
      phone: phone,
    );
    if (!rz.success) {
      return PaymentOutcome.failure(
        'Payment not completed. Please finish the payment to continue.',
      );
    }
    final updated = Map<String, dynamic>.from(data);
    updated['gateway'] = 'razorpay';
    updated['gatewayType'] = 'online';
    updated['paymentMethod'] = 'razorpay';
    updated['paymentStatus'] = 'completed';
    if (rz.paymentId != null) updated['razorpay_payment_id'] = rz.paymentId;
    if (rz.orderId != null) updated['razorpay_order_id'] = rz.orderId;
    if (rz.signature != null) updated['razorpay_signature'] = rz.signature;
    return PaymentOutcome.success(updated);
  }
}
