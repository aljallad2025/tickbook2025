import 'package:evento_app/features/checkout/pgw_controller/payment_controller_factory.dart';
import 'package:evento_app/features/checkout/ui/screens/checkout_screen.dart';
import 'package:evento_app/network_services/core/basic_service.dart';
import 'package:evento_app/network_services/core/verify_payment_service.dart';
import 'dart:math' as math;

/// Result of a payment attempt.
class CheckoutPaymentOutcome {
  final bool success;
  final String? error;
  final Map<String, dynamic>? updatedData;
  const CheckoutPaymentOutcome({
    required this.success,
    this.error,
    this.updatedData,
  });
}

/// Handles all payment preparation and execution.
class CheckoutPaymentModel {
  PaymentGateway gateway;
  bool initializing = false;
  bool executed = false;

  CheckoutPaymentModel({this.gateway = PaymentGateway.offline});

  /// Maps enum to backend keyword.
  static String gwKeyword(PaymentGateway g) {
    switch (g) {
      case PaymentGateway.paypal:
        return 'paypal';
      case PaymentGateway.stripe:
        return 'stripe';
      case PaymentGateway.flutterwave:
        return 'flutterwave';
      case PaymentGateway.paystack:
        return 'paystack';
      case PaymentGateway.xendit:
        return 'xendit';
      case PaymentGateway.toyyibpay:
        return 'toyyibpay';
      case PaymentGateway.mollie:
        return 'mollie';
      case PaymentGateway.myfatoorah:
        return 'myfatoorah';
      case PaymentGateway.monnify:
        return 'monnify';
      case PaymentGateway.nowpayments:
        return 'nowpayments';
      case PaymentGateway.phonepe:
        return 'phonepe';
      case PaymentGateway.midtrans:
        return 'midtrans';
      case PaymentGateway.mercadopago:
        return 'mercadopago';
      case PaymentGateway.authorizeNet:
        return 'authorizenet';
      case PaymentGateway.razorpay:
        return 'razorpay';
      case PaymentGateway.offline:
        return 'offline';
    }
  }

  /// Reverse map from backend keyword to enum.
  static PaymentGateway? fromKeyword(String keyword) {
    switch (keyword.trim().toLowerCase()) {
      case 'paypal':
        return PaymentGateway.paypal;
      case 'stripe':
        return PaymentGateway.stripe;
      case 'flutterwave':
        return PaymentGateway.flutterwave;
      case 'paystack':
        return PaymentGateway.paystack;
      case 'xendit':
        return PaymentGateway.xendit;
      case 'toyyibpay':
        return PaymentGateway.toyyibpay;
      case 'mollie':
        return PaymentGateway.mollie;
      case 'myfatoorah':
        return PaymentGateway.myfatoorah;
      case 'monnify':
        return PaymentGateway.monnify;
      case 'now_payments':
      case 'nowpayments':
        return PaymentGateway.nowpayments;
      case 'phonepe':
        return PaymentGateway.phonepe;
      case 'midtrans':
        return PaymentGateway.midtrans;
      case 'mercadopago':
        return PaymentGateway.mercadopago;
      case 'authorizenet':
      case 'authorize.net':
      case 'authorize_net':
        return PaymentGateway.authorizeNet;
      case 'razorpay':
        return PaymentGateway.razorpay;
      default:
        return null;
    }
  }

  /// Encodes an online/offline choice to a simple string key if needed.
  static String encodeKey({PaymentGateway? g, String? offlineId}) {
    if (g == PaymentGateway.offline && offlineId != null) {
      return 'offline:$offlineId';
    }
    if (g != null) return 'online:${gwKeyword(g)}';
    return 'unknown';
  }

  Future<CheckoutPaymentOutcome> execute({
    required Map<String, dynamic> rawData,
    required double total,
    required double couponDiscount,
    required String fullName,
    required String email,
    required String phone,
    required String customerId,
  }) async {
    if (gateway == PaymentGateway.offline) {
      return CheckoutPaymentOutcome(success: true, updatedData: rawData);
    }

    double amount = (total - couponDiscount)
        .clamp(0, double.infinity)
        .toDouble();
    final payloadCurrency =
        (rawData['currencyText'] ?? rawData['base_currency_text'] ?? '')
            .toString()
            .trim();
    String currency = payloadCurrency.isNotEmpty
        ? payloadCurrency.toLowerCase()
        : (await BasicService.getBaseCurrencyText(
            forceReload: true,
          )).toLowerCase();

    // Verify with backend
    try {
  // Logging removed for production.
      final verifyRes = await VerifyPaymentService.verify(
        gateway: gwKeyword(gateway),
        total: amount.toStringAsFixed(2),
      );
      if (!verifyRes.success) {
        return CheckoutPaymentOutcome(
          success: false,
          error: verifyRes.message.isNotEmpty
              ? verifyRes.message
              : 'Unable to verify payment amount.',
        );
      }
      if (verifyRes.paidAmount != null && verifyRes.paidAmount! > 0) {
        amount = verifyRes.paidAmount!;
      }
    } catch (e) {
      return CheckoutPaymentOutcome(
        success: false,
        error: 'Payment verification failed.',
      );
    }

    // Currency adjustments and gateway-specific safety checks
    bool isPaypalSupported(String c) {
      const supported = {
        'usd',
        'eur',
        'aud',
        'cad',
        'gbp',
        'jpy',
        'nzd',
        'sgd',
        'brl',
        'mxn',
        'sek',
        'chf',
        'hkd',
        'nok',
        'try',
        'dkk',
        'czk',
        'huf',
        'ils',
        'pln',
        'rub',
        'thb',
        'twd',
      };
      return supported.contains(c);
    }

    if (gateway == PaymentGateway.paypal && !isPaypalSupported(currency)) {
      // Fallback to USD if selected currency not supported by PayPal
      currency = 'usd';
    }
    if (gateway == PaymentGateway.stripe && currency.isEmpty) {
      currency = 'usd';
    }
    if (gateway == PaymentGateway.paystack) {
      bool paystackSupported(String c) {
        const supported = {'ngn', 'ghs', 'usd', 'zar'};
        return supported.contains(c);
      }

      if (!paystackSupported(currency)) {
        final base = payloadCurrency.isNotEmpty
            ? payloadCurrency.toLowerCase()
            : (await BasicService.getBaseCurrencyText(
                forceReload: true,
              )).toLowerCase();
        currency = paystackSupported(base) ? base : 'ngn';
      }
    }

    // Midtrans requires integer IDR (zero-decimal). Ensure reasonable minimum.
    if (gateway == PaymentGateway.midtrans && currency == 'idr') {
      final intAmt = amount.round();
      if (intAmt >= 10) {
        amount = intAmt.toDouble();
      } else {
        final fallback = (total - couponDiscount);
        if (fallback >= 10) {
          amount = fallback.toDouble();
        } else {
          return const CheckoutPaymentOutcome(
            success: false,
            error:
                'Midtrans requires a minimum of 1,000 IDR. Please increase quantity or choose another method.',
          );
        }
      }
    }

    int currencyExponent(String c) {
      switch (c.toLowerCase()) {
        // Zero-decimal currencies
        case 'idr':
        case 'bhd':
        case 'jpy':
        case 'krw':
        case 'vnd':
        case 'clp':
        case 'xaf':
        case 'xof':
        case 'xpf':
        case 'bif':
        case 'djf':
        case 'gnf':
        case 'kmf':
        case 'mga':
        case 'pyg':
        case 'rwf':
        case 'ugx':
        case 'vuv':
          return 0;
        default:
          return 2;
      }
    }

    final exp = currencyExponent(currency);
    final minor = (amount * math.pow(10, exp)).round();

    final controller = PaymentControllerFactory.forGateway(gateway);
    if (controller == null) {
      return CheckoutPaymentOutcome(
        success: false,
        error: 'Payment controller not found.',
      );
    }

    try {
      initializing = true;
      final result = await controller.pay(
        data: Map<String, dynamic>.from(rawData),
        amount: amount,
        minor: minor,
        currency: currency,
        fullName: fullName,
        email: email,
        phone: phone,
        customerId: customerId,
      );
      if (!result.success) {
        return CheckoutPaymentOutcome(
          success: false,
          error: result.errorMessage ?? 'Payment failed',
        );
      }
      executed = true;
      return CheckoutPaymentOutcome(
        success: true,
        updatedData: result.updatedData ?? rawData,
      );
    } finally {
      initializing = false;
    }
  }
}
