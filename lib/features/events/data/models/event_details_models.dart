import 'package:evento_app/features/events/data/models/event_item_model.dart';
import 'package:evento_app/features/events/data/models/slider_model.dart';
import 'package:evento_app/features/events/data/models/tickets_model.dart';
import 'package:evento_app/features/organizers/data/models/admin_model.dart';
import 'package:evento_app/features/organizers/data/models/organizer_model.dart';
import 'package:evento_app/utils/helpers.dart';

class EventDetailsPageModel {
  final bool success;
  final String pageTitle;
  final EventDetailsModel event;
  final AdminModel admin;
  final OrganizersModel organizer;
  final List<TicketModel> tickets;
  final List<SliderImageModel> sliderImages;
  final List<EventItemModel> relatedEvents;
  final String? currencySymbol;
  final String? currencySymbolPosition;
  final String? currencyText;

  const EventDetailsPageModel({
    required this.success,
    required this.pageTitle,
    required this.event,
    required this.admin,
    required this.organizer,
    required this.tickets,
    required this.sliderImages,
    required this.relatedEvents,
    this.currencySymbol,
    this.currencySymbolPosition,
    this.currencyText,
  });

  factory EventDetailsPageModel.fromJson(Map<String, dynamic> json) {
    final dataRaw = json['data'];
    final data = dataRaw is Map<String, dynamic>
        ? dataRaw
        : <String, dynamic>{};

    final contentRaw = data['content'];
    final content = contentRaw is Map<String, dynamic>
        ? contentRaw
        : <String, dynamic>{};

    final adminRaw = data['admin'];
    final admin = adminRaw is Map<String, dynamic>
        ? adminRaw
        : <String, dynamic>{};
    final organizerRaw = data['organizer'];
    // Support organizer coming as nested object or absent
    final organizerMap = organizerRaw is Map<String, dynamic>
        ? organizerRaw
        : <String, dynamic>{};

    final ticketsRaw = data['tickets'];
    final imagesRaw = data['images'];
    final relatedRaw = data['related_events'];

    final tickets = ticketsRaw is List
        ? ticketsRaw
              .whereType<Map<String, dynamic>>()
              .map(TicketModel.fromJson)
              .toList()
        : <TicketModel>[];

    final sliderImages = imagesRaw is List
        ? imagesRaw
              .whereType<Map<String, dynamic>>()
              .map(SliderImageModel.fromJson)
              .toList()
        : <SliderImageModel>[];

    final relatedEvents = relatedRaw is List
        ? relatedRaw
              .whereType<Map<String, dynamic>>()
              .map(EventItemModel.fromJson)
              .toList()
        : <EventItemModel>[];

    int? contentOrganizerId() {
      final raw = content['organizer_id'];
      final id = asInt(raw);
      return (id == null || id == 0) ? null : id;
    }

    final bool noOrganizerProvided =
        organizerMap.isEmpty && contentOrganizerId() == null;

    final OrganizersModel finalOrganizer = noOrganizerProvided
        ? OrganizersModel(
            id: asInt(admin['id']) ?? 0,
            name:
                ('${(admin['first_name'] ?? '').toString()} ${(admin['last_name'] ?? '').toString()}')
                    .trim(),
            username: (admin['username'] ?? '').toString(),
            image: (admin['image'] ?? '').toString(),
            totalEvents: 0,
          )
        : (organizerMap.isNotEmpty
              ? OrganizersModel.fromJson(organizerMap)
              : OrganizersModel(
                  id: (content['organizer_id'] is int)
                      ? (content['organizer_id'] as int)
                      : int.tryParse('${content['organizer_id'] ?? ''}') ?? 0,
                  name: (content['organizer_name'] ?? content['name'] ?? '')
                      .toString(),
                  username: (content['organizer_username'] ?? '').toString(),
                  image: (content['organizer_image'] ?? content['photo'] ?? '')
                      .toString(),
                  totalEvents: 0,
                ));

    return EventDetailsPageModel(
      success: json['success'] == true,
      pageTitle: (data['page_title'] ?? '') as String,
      event: EventDetailsModel.fromJson(content),
      admin: AdminModel.fromJson(admin),
      organizer: finalOrganizer,
      tickets: tickets,
      sliderImages: sliderImages,
      relatedEvents: relatedEvents,
      currencySymbol: (data['base_currency_symbol'] ?? data['currency_symbol'])?.toString(),
      currencySymbolPosition: (data['base_currency_symbol_position'] ?? data['currency_symbol_position'])?.toString(),
      currencyText: (data['base_currency_text'] ?? data['currency_text'])?.toString(),
    );
  }
}

class EventDetailsModel {
  final int id;
  final int? organizerId;
  final String organizerName;
  final String? thumbnail;
  final String? status;
  final String? dateType;
  final String? countdownStatus;
  final DateTime? startDate;
  final String? startTime;
  final String? duration;
  final DateTime? endDate;
  final String? endTime;
  final DateTime? endDateTime;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? eventType;
  final String? isFeatured;
  final double? latitude;
  final double? longitude;
  final String? instructionsHtml;
  final String? meetingUrl;
  final String? ticketLogo;
  final String? ticketImage;
  final String title;
  final String descriptionHtml;
  final String? eventCategoryId;
  final String? name;
  final String? city;
  final String? state;
  final String? country;
  final String? address;
  final String? zipCode;
  final String? refundPolicy;
  // For events with date_type == 'multiple', backend sends an array of date ranges.
  // We preserve them here so UI logic (checkout formatting, countdown, etc.) can pick a specific occurrence.
  final List<EventMultiDateModel> dates;

  const EventDetailsModel({
    required this.id,
    required this.title,
    required this.descriptionHtml,
    this.organizerId,
    this.organizerName = '',
    this.thumbnail,
    this.status,
    this.dateType,
    this.countdownStatus,
    this.startDate,
    this.startTime,
    this.duration,
    this.endDate,
    this.endTime,
    this.endDateTime,
    this.createdAt,
    this.updatedAt,
    this.eventType,
    this.isFeatured,
    this.latitude,
    this.longitude,
    this.instructionsHtml,
    this.meetingUrl,
    this.ticketLogo,
    this.ticketImage,
    this.eventCategoryId,
    this.name,
    this.city,
    this.state,
    this.country,
    this.address,
    this.zipCode,
    this.refundPolicy,
    this.dates = const <EventMultiDateModel>[],
  });

  factory EventDetailsModel.fromJson(Map<String, dynamic> json) {
    int? parseOrganizerId() {
      final v =
          json['organizer_id'] ??
          (json['organizer'] is Map ? (json['organizer'] as Map)['id'] : null);
      final parsed = asInt(v);
      return parsed;
    }

    return EventDetailsModel(
      id: asInt(json['id']) ?? 0,
      organizerId: parseOrganizerId(),
      thumbnail: json['thumbnail']?.toString(),
      status: json['status']?.toString(),
      dateType: json['date_type']?.toString(),
      countdownStatus: json['countdown_status']?.toString(),
      startDate: asDateTime(json['start_date']),
      startTime: json['start_time']?.toString(),
      duration: json['duration']?.toString(),
      endDate: asDateTime(json['end_date']),
      endTime: json['end_time']?.toString(),
      endDateTime: asDateTime(json['end_date_time']),
      createdAt: asDateTime(json['created_at']),
      updatedAt: asDateTime(json['updated_at']),
      eventType: json['event_type']?.toString(),
      isFeatured: json['is_featured']?.toString(),
      latitude: asDouble(json['latitude']),
      longitude: asDouble(json['longitude']),
      instructionsHtml: json['instructions']?.toString(),
      meetingUrl: json['meeting_url']?.toString(),
      ticketLogo: json['ticket_logo']?.toString(),
      ticketImage: json['ticket_image']?.toString(),
      title: (json['title'] ?? '').toString(),
      descriptionHtml: (json['description'] ?? '').toString(),
      eventCategoryId: json['event_category_id']?.toString(),
      name: json['name']?.toString(),
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      country: json['country']?.toString(),
      address: json['address']?.toString(),
      zipCode: json['zip_code']?.toString(),
      refundPolicy: json['refund_policy']?.toString(),
      dates: _parseMultiDates(json['dates']),
    );
  }
}

class EventMultiDateModel {
  final int id;
  final DateTime? startDate;
  final String? startTime;
  final DateTime? endDate;
  final String? endTime;
  final DateTime? startDateTime;
  final DateTime? endDateTime;

  const EventMultiDateModel({
    required this.id,
    this.startDate,
    this.startTime,
    this.endDate,
    this.endTime,
    this.startDateTime,
    this.endDateTime,
  });

  factory EventMultiDateModel.fromJson(Map<String, dynamic> json) {
    return EventMultiDateModel(
      id: asInt(json['id']) ?? 0,
      startDate: asDateTime(json['start_date']),
      startTime: json['start_time']?.toString(),
      endDate: asDateTime(json['end_date']),
      endTime: json['end_time']?.toString(),
      startDateTime: asDateTime(json['start_date_time']),
      endDateTime: asDateTime(json['end_date_time']),
    );
  }
}

List<EventMultiDateModel> _parseMultiDates(dynamic raw) {
  if (raw is List) {
    return raw
        .whereType<Map<String, dynamic>>()
        .map(EventMultiDateModel.fromJson)
        .toList();
  }
  return const <EventMultiDateModel>[];
}
