import 'package:flutter/material.dart';
import 'package:evento_app/app/app_colors.dart';
import 'package:evento_app/app/app_text_styles.dart';
import '../screens/checkout_screen.dart';

class SubmitBookingButton extends StatelessWidget {
  final bool disabled;
  final bool submitting;
  final bool initializingPayment;
  final bool autoPaid;
  final bool autoSubmitTriggered;
  final bool bookingStarted;
  final PaymentGateway pgw;
  final VoidCallback onPressed;
  const SubmitBookingButton({
    super.key,
    required this.disabled,
    required this.submitting,
    required this.initializingPayment,
    required this.autoPaid,
    required this.autoSubmitTriggered,
    required this.bookingStarted,
    required this.pgw,
    required this.onPressed,
  });
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onPressed: disabled ? null : onPressed,
        child:
            (submitting ||
                initializingPayment ||
                (autoPaid && autoSubmitTriggered) ||
                bookingStarted)
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                _label(),
                style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
              ),
      ),
    );
  }

  String _label() {
    switch (pgw) {
      case PaymentGateway.offline:
        return 'Create Booking';
      case PaymentGateway.stripe:
        return 'Pay with Stripe & Book';
      case PaymentGateway.flutterwave:
        return 'Pay with Flutterwave & Book';
      case PaymentGateway.paypal:
        return 'Pay with Easzypay & Book';
      case PaymentGateway.paystack:
        return 'Pay with PayStack & Book';
      case PaymentGateway.xendit:
        return 'Pay with Xendit & Book';
      case PaymentGateway.toyyibpay:
        return 'Pay with Toyyibpay & Book';
      case PaymentGateway.mollie:
        return 'Pay with Mollie & Book';
      case PaymentGateway.myfatoorah:
        return 'Pay with MyFatoorah & Book';
      case PaymentGateway.monnify:
        return 'Pay with Monnify & Book';
      case PaymentGateway.nowpayments:
        return 'Pay with NOWPayments & Book';
      case PaymentGateway.phonepe:
        return (autoPaid || autoSubmitTriggered)
            ? 'Finalizing PhonePe…'
            : 'Pay with PhonePe & Book';
      case PaymentGateway.midtrans:
        return 'Pay with MidTrans & Book';
      case PaymentGateway.mercadopago:
        return 'Pay with Mercado Pago & Book';
      case PaymentGateway.authorizeNet:
        return 'Pay with Authorize.Net & Book';
      case PaymentGateway.razorpay:
        return 'Pay with Razorpay & Book';
      case PaymentGateway.benefit:
        return 'Pay with Benefit';
    }
  }
}
