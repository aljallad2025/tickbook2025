import 'dart:async';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:evento_app/network_services/core/basic_service.dart';

class RazorpayResult {
  final bool success;
  final String? paymentId;
  final String? orderId;
  final String? signature;
  RazorpayResult({
    required this.success,
    this.paymentId,
    this.orderId,
    this.signature,
  });
}

class RazorpaySdkGateway {
  static void log(String msg) {
    try {
      // Optional debug hook for Razorpay logs (removed for production)
    } catch (e) {
      assert(() { return true; }());
    }
  }

  static Razorpay? _rzp;

  static void _ensure() {
    log('Initializing SDK');
    _rzp ??= Razorpay();
  }

  static Future<RazorpayResult> startCheckout({
    required int amountMinor,
    required String name,
    required String currency,
    required String email,
    required String phone,
    String description = 'Order',
    String? key,
    String? orderId,
  }) async {
    _ensure();

    final completer = Completer<RazorpayResult>();

    void handleSuccess(PaymentSuccessResponse r) {
      if (!completer.isCompleted) {
        completer.complete(
          RazorpayResult(
            success: true,
            paymentId: r.paymentId,
            orderId: r.orderId,
            signature: r.signature,
          ),
        );
      }
    }

    void handleError(PaymentFailureResponse r) {
      if (!completer.isCompleted) {
        completer.complete(RazorpayResult(success: false));
      }
    }

    void handleExternalWallet(ExternalWalletResponse r) {}

    _rzp!.on(Razorpay.EVENT_PAYMENT_SUCCESS, handleSuccess);
    _rzp!.on(Razorpay.EVENT_PAYMENT_ERROR, handleError);
    _rzp!.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWallet);

    try {
      // Key from backend/basic or override
      final apiKey = await BasicService.getRazorpayKey();
      final useKey = (apiKey != null && apiKey.isNotEmpty) ? apiKey : key;
      if (useKey == null || useKey.isEmpty) {
        throw Exception('Razorpay key not provided by API');
      }

      final options = {
        'key': useKey,
        'amount': amountMinor / 100,
        'currency': currency.toUpperCase(),
        'name': name,
        'description': description,
        if (orderId != null && orderId.isNotEmpty) 'order_id': orderId,
        'prefill': {'contact': phone, 'email': email},
      };
      log('Opening SDK with amount=$amountMinor $currency');
      _rzp!.open(options);
      final res = await completer.future;
      return res;
    } finally {
      try {
        _rzp!.clear();
      } catch (e) {
        // Ignore cleanup failure; instance will be dropped.
        assert(() { return true; }());
      }
      _rzp = null;
    }
  }
}
