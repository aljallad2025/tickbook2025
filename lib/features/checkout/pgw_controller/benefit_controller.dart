import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'base_pgw_controller.dart';
import 'package:evento_app/app/app_constants.dart';

class BenefitController implements IPaymentController {
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
    try {
      final uri = Uri.parse('$pgwBaseUrl/benefit-create-request.php');
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'amount': amount}),
      );
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode != 200 || json['error'] != null) {
        return PaymentOutcome.failure(json['error']?.toString() ?? 'Benefit error');
      }
      final redirectUrl = json['redirect_url']?.toString() ?? '';
      if (redirectUrl.isEmpty) {
        return PaymentOutcome.failure('No redirect URL from Benefit');
      }
      final launched = await launchUrl(Uri.parse(redirectUrl), mode: LaunchMode.externalApplication);
      if (!launched) {
        return PaymentOutcome.failure('Could not open Benefit payment page');
      }
      return PaymentOutcome.success({...data, 'payment_method': 'benefit', 'order_id': json['order_id'] ?? ''});
    } catch (e) {
      return PaymentOutcome.failure(e.toString());
    }
  }
}
