class FcmNotificationModel {
  final String id;
  final String? from;
  final String title;
  final String body;
  final FcmNotificationData data;

  const FcmNotificationModel({
    required this.id,
    this.from,
    required this.title,
    required this.body,
    required this.data,
  });

  factory FcmNotificationModel.fromJson(Map<String, dynamic> json) {
    return FcmNotificationModel(
      id: json['id']?.toString() ?? '',
      from: json['from']?.toString(),
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      data: FcmNotificationData.fromJson(
        json['data'] is Map<String, dynamic>
            ? json['data'] as Map<String, dynamic>
            : const <String, dynamic>{},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (from != null) 'from': from,
      'title': title,
      'body': body,
      'data': data.toJson(),
    };
  }

  @override
  String toString() {
    return 'FcmNotificationModel(id: $id, title: $title, body: $body)';
  }
}

class FcmNotificationData {
  // Core fields used by the app
  final String? bookingId;
  final String? eventId;
  final String? eventTitle;
  final String? type;
  final String? buttonUrl;
  final String? buttonName;
  final String? message;
  final String? route;
  final String? args;

  const FcmNotificationData({
    this.bookingId,
    this.eventId,
    this.eventTitle,
    this.type,
    this.buttonUrl,
    this.buttonName,
    this.message,
    this.route,
    this.args,
  });

  factory FcmNotificationData.fromJson(Map<String, dynamic> json) {
    String? s(dynamic v) => v?.toString();
    return FcmNotificationData(
      bookingId: s(json['booking_id'] ?? json['bookingId']),
      eventId: s(json['event_id'] ?? json['eventId']),
      eventTitle: s(json['event_title'] ?? json['eventTitle']),
      type: s(json['type'] ?? json['category'] ?? json['module']),
      buttonUrl: s(json['button_url'] ?? json['url'] ?? json['link']),
      buttonName: s(json['button_name'] ?? json['buttonName']),
      message: s(json['message'] ?? json['body'] ?? json['content']),
      route: s(json['route']),
      args: s(json['args']),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};

    if (bookingId != null) json['booking_id'] = bookingId;
    if (eventId != null) json['event_id'] = eventId;
    if (eventTitle != null) json['event_title'] = eventTitle;
    if (type != null) json['type'] = type;
    if (buttonUrl != null) json['button_url'] = buttonUrl;
    if (buttonName != null) json['button_name'] = buttonName;
    if (message != null) json['message'] = message;
    if (route != null) json['route'] = route;
    if (args != null) json['args'] = args;

    return json;
  }

  // Convenience getters
  int? get bookingIdAsInt {
    return bookingId != null ? int.tryParse(bookingId!) : null;
  }

  bool get isBookingNotification {
    return bookingId != null || eventId != null;
  }

  @override
  String toString() {
    return 'FcmNotificationData(booking: $bookingId, event: $eventTitle)';
  }
}
