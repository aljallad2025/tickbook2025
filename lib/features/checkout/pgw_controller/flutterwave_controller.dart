import 'package:get/get.dart';
import 'package:evento_app/network_services/core/pgw_service.dart';
import 'package:evento_app/app/app_constants.dart';
import 'package:evento_app/app/app_routes.dart';
import 'base_pgw_controller.dart';

class FlutterwaveController implements IPaymentController {
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
    final r = await PGWService.createFlutterwavePayment(
      amountMinor: minor,
      currency: currency,
    );
    if (!r.success || r.redirectUrl == null || r.txRef == null) {
      return PaymentOutcome.failure('Flutterwave init failed: ${r.message}');
    }

    final ok =
        await Get.toNamed(
              AppRoutes.checkoutWebView,
              arguments: {
                'url': r.redirectUrl,
                'title': 'Flutterwave',
                'finishScheme': 'myapp://flutterwave-finish',
                'invoiceId': r.txRef,
                'statusUrlTemplate':
                    '$pgwBaseUrl/flutterwave-status.php?tx_ref={invoiceId}',
                'statusPollIntervalSeconds': 4,
                'statusPollMaxAttempts': 10,
                'successUrlContains': [
                  'success',
                  'paid',
                  'completed',
                  'captured',
                  'approved',
                ],
              },
            )
            as bool?;

    // If WebView polling reported success, trust it to avoid race conditions.
    // Otherwise, attempt a final server verify before failing.
    bool verified = ok == true;
    if (!verified) {
      // Small delay to allow backend to propagate status
      await Future.delayed(const Duration(seconds: 2));
      verified = await PGWService.verifyFlutterwave(txRef: r.txRef!);
      if (!verified) {
        // One more quick retry in case of transient lag
        await Future.delayed(const Duration(seconds: 2));
        verified = await PGWService.verifyFlutterwave(txRef: r.txRef!);
      }
    }
    if (!verified) {
      return PaymentOutcome.failure(
        'Payment not completed. Please finish the payment to continue.',
      );
    }

    final updated = Map<String, dynamic>.from(data);
    updated['gateway'] = 'flutterwave';
    updated['gatewayType'] = 'online';
    updated['paymentMethod'] = 'flutterwave';
    updated['paymentStatus'] = 'completed';
    // Align with other gateways (no extra custom fields)
    return PaymentOutcome.success(updated);
  }
}
