import 'package:evento_app/network_services/pgw_services/mercado_pago.dart';
import 'base_pgw_controller.dart';

class MercadoPagoController implements IPaymentController {
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
    final ok = await MercadoPagoGateway.startCheckout(amountMinor: minor, currency: currency, name: fullName, email: email);
    if (!ok) {
      return PaymentOutcome.failure('Payment not completed. Please finish the payment to continue.');
    }
    final updated = Map<String, dynamic>.from(data);
    updated['gateway'] = 'mercadopago';
    updated['gatewayType'] = 'online';
    updated['paymentMethod'] = 'mercadopago';
    updated['paymentStatus'] = 'completed';
    return PaymentOutcome.success(updated);
  }
}
