import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'base_pgw_controller.dart';
import 'package:evento_app/network_services/core/basic_service.dart';

class BenefitController implements IPaymentController {
  @override
  Future<PgwResult> pay({
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
      final baseUrl = await BasicService.getBaseUrl();
      final uri = Uri.parse('$baseUrl/pgw/benefit-create-request.php');
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'amount': amount}),
      );
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode != 200 || json['error'] != null) {
        return PgwResult(success: false, errorMessage: json['error']?.toString() ?? 'Benefit error');
      }
      final redirectUrl = json['redirect_url']?.toString() ?? '';
      if (redirectUrl.isEmpty) {
        return PgwResult(success: false, errorMessage: 'No redirect URL');
      }
      final launched = await launchUrl(Uri.parse(redirectUrl), mode: LaunchMode.externalApplication);
      if (!launched) {
        return PgwResult(success: false, errorMessage: 'Could not open Benefit payment page');
      }
      return PgwResult(success: true, updatedData: {...data, 'payment_method': 'benefit', 'order_id': json['order_id'] ?? ''});
    } catch (e) {
      return PgwResult(success: false, errorMessage: e.toString());
    }
  }
}
