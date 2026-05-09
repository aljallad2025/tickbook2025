import 'package:evento_app/network_services/pgw_services/monnify.dart';
import 'base_pgw_controller.dart';

class MonnifyController implements IPaymentController {
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
    final ok = await MonnifyGateway.startCheckout(amountMinor: minor, name: fullName, email: email, phone: phone);
    if (!ok) {
      return PaymentOutcome.failure('Payment not completed. Please finish the payment to continue.');
    }
    final updated = Map<String, dynamic>.from(data);
    updated['gateway'] = 'monnify';
    updated['gatewayType'] = 'online';
    updated['paymentMethod'] = 'monnify';
    updated['paymentStatus'] = 'completed';
    return PaymentOutcome.success(updated);
  }
}
