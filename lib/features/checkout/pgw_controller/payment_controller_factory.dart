import '../../checkout/ui/screens/checkout_screen.dart';
import 'base_pgw_controller.dart';
import 'stripe_controller.dart';
import 'flutterwave_controller.dart';
import 'paypal_controller.dart';
import 'paystack_controller.dart';
import 'xendit_controller.dart';
import 'toyyibpay_controller.dart';
import 'mollie_controller.dart';
import 'myfatoorah_controller.dart';
import 'monnify_controller.dart';
import 'nowpayments_controller.dart';
import 'phonepe_controller.dart';
import 'midtrans_controller.dart';
import 'mercadopago_controller.dart';
import 'authorizenet_controller.dart';
import 'razorpay_controller.dart';

class PaymentControllerFactory {
  static IPaymentController? forGateway(PaymentGateway gateway) {
    switch (gateway) {
      case PaymentGateway.stripe:
        return StripeController();
      case PaymentGateway.flutterwave:
        return FlutterwaveController();
      case PaymentGateway.paypal:
        return PaypalController();
      case PaymentGateway.paystack:
        return PaystackController();
      case PaymentGateway.xendit:
        return XenditController();
      case PaymentGateway.toyyibpay:
        return ToyyibpayController();
      case PaymentGateway.mollie:
        return MollieController();
      case PaymentGateway.myfatoorah:
        return MyFatoorahController();
      case PaymentGateway.monnify:
        return MonnifyController();
      case PaymentGateway.nowpayments:
        return NowPaymentsController();
      case PaymentGateway.phonepe:
        return PhonePeController();
      case PaymentGateway.midtrans:
        return MidtransController();
      case PaymentGateway.mercadopago:
        return MercadoPagoController();
      case PaymentGateway.authorizeNet:
        return AuthorizeNetController();
      case PaymentGateway.razorpay:
        return RazorpayController();
      case PaymentGateway.offline:
        return null;
    }
  }
}
