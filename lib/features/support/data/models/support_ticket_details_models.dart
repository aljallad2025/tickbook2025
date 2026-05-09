import 'package:evento_app/utils/helpers.dart';

class TicketDetailsResponse {
  final String pageTitle;
  final SupportTicketDetails? ticket;
  TicketDetailsResponse({required this.pageTitle, required this.ticket});

  factory TicketDetailsResponse.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>? ?? {});
    return TicketDetailsResponse(
      pageTitle: (data['page_title'] ?? '').toString(),
      ticket: data['support_ticket'] is Map<String, dynamic>
          ? SupportTicketDetails.fromJson(
              data['support_ticket'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class SupportTicketDetails {
  final int id;
  final int? userId;
  final String? ticketNumber;
  final String? email;
  final String? subject;
  final String? description;
  final String? attachment;
  final int status;
  final String createdAt;
  final String? updatedAt;
  final List<TicketMessage> messages;

  SupportTicketDetails({
    required this.id,
    this.userId,
    this.ticketNumber,
    this.email,
    this.subject,
    this.description,
    this.attachment,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    required this.messages,
  });

  factory SupportTicketDetails.fromJson(Map<String, dynamic> json) {
    final msgs = (json['messages'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(TicketMessage.fromJson)
        .toList();
    return SupportTicketDetails(
      id: asInt(json['id']) ?? 0,
      userId: asInt(json['user_id']),
      ticketNumber: json['ticket_number']?.toString(),
      email: json['email']?.toString(),
      subject: json['subject']?.toString(),
      description: json['description']?.toString(),
      attachment: json['attachment']?.toString(),
      status: asInt(json['status']) ?? 0,
      createdAt: (json['created_at'] ?? '').toString(),
      updatedAt: json['updated_at']?.toString(),
      messages: msgs,
    );
  }
}

class TicketMessage {
  final int id;
  final int? userId;
  final String? userType;
  final int? adminId;
  final int? type;
  final String? reply;
  final String? file;
  final String createdAt;
  final SenderProfile? sender;

  TicketMessage({
    required this.id,
    this.userId,
    this.userType,
    this.adminId,
    this.type,
    this.reply,
    this.file,
    required this.createdAt,
    this.sender,
  });

  factory TicketMessage.fromJson(Map<String, dynamic> json) => TicketMessage(
    id: asInt(json['id']) ?? 0,
    userId: asInt(json['user_id']),
    userType: json['user_type']?.toString(),
    adminId: asInt(json['admin_id']),
    type: asInt(json['type']),
    reply: json['reply']?.toString(),
    file: json['file']?.toString(),
    createdAt: (json['created_at'] ?? '').toString(),
    sender: json['sender'] is Map<String, dynamic>
        ? SenderProfile.fromJson(json['sender'] as Map<String, dynamic>)
        : null,
  );
}

class SenderProfile {
  final int id;
  final String? name;
  final String? role;
  final String? avatar;

  SenderProfile({required this.id, this.name, this.role, this.avatar});

  factory SenderProfile.fromJson(Map<String, dynamic> json) {
    final id = asInt(json['id']) ?? 0;
    // Admin-style fields
    final firstName = json['first_name']?.toString();
    final lastName = json['last_name']?.toString();
    final image = json['image']?.toString();
    final username = json['username']?.toString();
    // Customer-style fields
    final fName = json['fname']?.toString();
    final lName = json['lname']?.toString();
    final photo = json['photo']?.toString();

    String? name;
    String? avatar;
    String role = 'Customer';

    if (firstName != null || lastName != null) {
      name = [
        firstName,
        lastName,
      ].where((e) => (e ?? '').isNotEmpty).join(' ').trim();
      avatar = image;
      role = (username == 'admin') ? 'Super Admin' : 'Super Admin';
    } else if (fName != null || lName != null) {
      name = [fName, lName].where((e) => (e ?? '').isNotEmpty).join(' ').trim();
      avatar = photo;
      role = 'Customer';
    } else {
      name = (json['name'] ?? json['username'] ?? json['email'] ?? '')
          .toString();
      avatar = (json['avatar'] ?? json['image'] ?? json['photo'])?.toString();
      if (username == 'admin') role = 'Super Admin';
    }

    return SenderProfile(id: id, name: name, role: role, avatar: avatar);
  }
}
