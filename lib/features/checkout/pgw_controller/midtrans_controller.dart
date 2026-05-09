import 'package:evento_app/network_services/pgw_services/midtrans.dart';
import 'base_pgw_controller.dart';

class MidtransController implements IPaymentController {
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
    final amountInt = minor;
    final ok = await MidtransGateway.startCheckout(
      amount: amountInt,
      currency: currency,
      name: fullName,
      email: email,
      phone: phone,
    );
    if (!ok) {
      return PaymentOutcome.failure(
        'Payment not completed. Please finish the payment to continue.',
      );
    }
    final updated = Map<String, dynamic>.from(data);
    updated['gateway'] = 'midtrans';
    updated['gatewayType'] = 'online';
    updated['paymentMethod'] = 'midtrans';
    updated['paymentStatus'] = 'completed';
    return PaymentOutcome.success(updated);
  }
}
