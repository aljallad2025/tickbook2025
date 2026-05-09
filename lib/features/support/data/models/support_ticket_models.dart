import 'package:evento_app/utils/helpers.dart';

class SupportTicketsResponse {
  final String pageTitle;
  final List<SupportTicket> tickets;
  SupportTicketsResponse({required this.pageTitle, required this.tickets});

  factory SupportTicketsResponse.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>? ?? {});
    final list = (data['support_tickets'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(SupportTicket.fromJson)
        .toList();
    return SupportTicketsResponse(
      pageTitle: (data['page_title'] ?? '').toString(),
      tickets: list,
    );
  }
}

class SupportTicket {
  final int id;
  final int? userId;
  final String? userType;
  final int? adminId;
  final String? ticketNumber;
  final String? email;
  final String? subject;
  final String? description;
  final String? attachment;
  final int status;
  final String createdAt;
  final String? updatedAt;
  final String? lastMessage;

  SupportTicket({
    required this.id,
    this.userId,
    this.userType,
    this.adminId,
    this.ticketNumber,
    this.email,
    this.subject,
    this.description,
    this.attachment,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.lastMessage,
  });

  factory SupportTicket.fromJson(Map<String, dynamic> json) => SupportTicket(
        id: asInt(json['id']) ?? 0,
        userId: asInt(json['user_id']),
        userType: json['user_type']?.toString(),
        adminId: asInt(json['admin_id']),
        ticketNumber: json['ticket_number']?.toString(),
        email: json['email']?.toString(),
        subject: json['subject']?.toString(),
        description: json['description']?.toString(),
        attachment: json['attachment']?.toString(),
        status: asInt(json['status']) ?? 0,
        createdAt: (json['created_at'] ?? '').toString(),
        updatedAt: json['updated_at']?.toString(),
        lastMessage: json['last_message']?.toString(),
      );
}
