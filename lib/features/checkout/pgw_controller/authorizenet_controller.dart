import 'package:evento_app/network_services/pgw_services/authorize_net.dart';
import 'base_pgw_controller.dart';

class AuthorizeNetController implements IPaymentController {
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
    final ok = await AuthorizeNetGateway.startCheckout(amountString: amount.toStringAsFixed(2), currency: currency.toUpperCase());
    if (!ok) {
      return PaymentOutcome.failure('Payment not completed. Please finish the payment to continue.');
    }
    final updated = Map<String, dynamic>.from(data);
    updated['gateway'] = 'authorize.net';
    updated['gatewayType'] = 'online';
    updated['paymentMethod'] = 'authorize.net';
    updated['paymentStatus'] = 'completed';
    return PaymentOutcome.success(updated);
  }
}
