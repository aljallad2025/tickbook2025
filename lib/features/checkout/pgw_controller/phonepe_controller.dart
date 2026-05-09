import 'package:evento_app/network_services/pgw_services/phonepe.dart';
import 'base_pgw_controller.dart';

class PhonePeController implements IPaymentController {
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
    final ok = await PhonePeGateway.startCheckout(
      amountMinor: minor,
      merchantUserId: customerId,
      name: fullName,
      email: email,
      mobile: phone,
      currency: currency,
      originalCheckoutArgs: Map<String, dynamic>.from(data),
    );
    if (!ok) {
      return PaymentOutcome.failure('Payment not completed. Please finish the payment to continue.');
    }
    final updated = Map<String, dynamic>.from(data);
    updated['gateway'] = 'phonepe';
    updated['gatewayType'] = 'online';
    updated['paymentMethod'] = 'phonepe';
    updated['paymentStatus'] = 'completed';
    return PaymentOutcome.success(updated);
  }
}
