import 'dart:convert';

import 'package:evento_app/app/urls.dart';
import 'package:http/http.dart' as http;

class EmailResult {
  final bool success;
  final String message;

  EmailResult({required this.success, required this.message});
}

class OrgEmailService {
  static Future<EmailResult> sendEmailToOrganizer({
    required int organizerID,
    required String name,
    required String email,
    required String subject,
    required String message,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(AppUrls.sendEmailToOrganizerUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'organizer_id': organizerID,
          'name': name,
          'email': email,
          'subject': subject,
          'message': message,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return EmailResult(
          success: data['success'] ?? false,
          message: data['message'] ?? 'Email sent successfully',
        );
      } else {
        return EmailResult(
          success: false,
          message: 'Server Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return EmailResult(success: false, message: 'Email sending failed: $e');
    }
  }
}
