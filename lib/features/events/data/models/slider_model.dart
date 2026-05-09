import 'package:evento_app/utils/helpers.dart';

class SliderImageModel {
  final int id;
  final int? eventId;
  final String image;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SliderImageModel({
    required this.id,
    required this.image,
    this.eventId,
    this.createdAt,
    this.updatedAt,
  });

  factory SliderImageModel.fromJson(Map<String, dynamic> json) =>
      SliderImageModel(
        id: asInt(json['id']) ?? 0,
        eventId: asInt(json['event_id']),
        image: (json['image'] ?? '') as String,
        createdAt: asDateTime(json['created_at']),
        updatedAt: asDateTime(json['updated_at']),
      );
}
