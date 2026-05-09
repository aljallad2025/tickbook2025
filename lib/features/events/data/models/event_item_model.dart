

import 'package:evento_app/features/categories/models/category_model.dart';

class EventItemModel {
  final String id;
  final String slug;
  final String title;
  final String description;
  final String thumbnail;
  final String date;
  final String? time;
  final String dateType;
  final String duration;
  final String organizer;
  final String eventType;
  final String? address;
  final String? ticketPrice;
  final CategoryModel? category;
  final int? categoryId;
  final String? categoryName;
  final String? country;
  final String? state;
  final String? city;
  final double? latitude;
  final double? longitude;

  EventItemModel({
    required this.id,
    required this.slug,
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.date,
    required this.time,
    required this.dateType,
    required this.duration,
    required this.organizer,
    required this.eventType,
    required this.address,
    required this.ticketPrice,
    this.category,
    this.categoryId,
    this.categoryName,
    this.country,
    this.state,
    this.city,
  this.latitude,
  this.longitude,
  });

  factory EventItemModel.fromJson(Map<String, dynamic> json) {
    final String dateType = (json['date_type'] ?? '').toString();

    String date = (json['date'] ?? '').toString();
    String? time = json['time'] as String?;

    if (dateType == 'multiple') {
      final dynamic dates = json['dates'];
      if (dates is List && dates.isNotEmpty) {
        final first = dates.first;
        if (first is Map) {
          final m = first as Map<String, dynamic>;
          final String? startDate = m['start_date']?.toString();
          final String? startTime = m['start_time']?.toString();
          if (startDate != null && startDate.isNotEmpty) {
            date = startDate;
          }
          if (startTime != null && startTime.isNotEmpty) {
            time = startTime;
          }
        }
      }
    }

    // Parse category from various possible keys
    CategoryModel? parsedCategory;
    Map<String, dynamic>? catMap;
    final rawCategory = json['category'];
    final rawGCategory = json['gcategory'] ?? json['g_category'];
    if (rawCategory is Map<String, dynamic>) {
      catMap = rawCategory;
    } else if (rawGCategory is Map<String, dynamic>) {
      catMap = rawGCategory;
    }
    if (catMap != null) {
      parsedCategory = CategoryModel.fromJson(catMap);
    }

    int? parsedCategoryId;
    String? parsedCategoryName;

    parsedCategoryId =
        _asInt(json['category_id']) ?? _asInt(json['event_category_id']);
    parsedCategoryName = (json['category_name'] ?? json['event_category_name'])
        ?.toString();

    if ((parsedCategoryId == null || parsedCategoryId == 0) &&
        parsedCategory != null) {
      parsedCategoryId = parsedCategory.id == 0 ? null : parsedCategory.id;
    }
    if ((parsedCategoryName == null || parsedCategoryName.isEmpty) &&
        parsedCategory != null) {
      parsedCategoryName = parsedCategory.name.isEmpty
          ? null
          : parsedCategory.name;
    }

    return EventItemModel(
      id: json['id'].toString(),
      slug: (json['slug'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      thumbnail: (json['thumbnail'] ?? '').toString(),
      date: date,
      time: time,
      dateType: dateType,
      duration: (json['duration'] ?? '').toString(),
      organizer: (json['organizer'] ?? '').toString(),
      eventType: (json['event_type'] ?? '').toString(),
      address: json['address'] as String?,
      ticketPrice: json['start_price']?.toString(),
      category: parsedCategory,
      categoryId: parsedCategoryId,
      categoryName: parsedCategoryName,
      country: _asStringOrName(json['country']),
      state: _asStringOrName(json['state']),
      city: _asStringOrName(json['city']),
      latitude: _asDouble(json['latitude']),
      longitude: _asDouble(json['longitude']),
    );
  }
}

int? _asInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is String) return int.tryParse(v);
  return null;
}

String? _asStringOrName(dynamic v) {
  if (v == null) return null;
  if (v is String) return v;
  if (v is Map) {
    final map = v;
    final name = map['name'] ?? map['title'] ?? map['label'];
    if (name is String && name.trim().isNotEmpty) return name;
  }
  return v.toString();
}

double? _asDouble(dynamic v) {
  if (v == null) return null;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  if (v is String) return double.tryParse(v);
  return null;
}
