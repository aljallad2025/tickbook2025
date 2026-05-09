class CategoryModel {
  final int id;
  final String name;
  final int languageId;
  final String image;
  final String slug;
  final int status;
  final int serialNumber;
  final String isFeatured;
  final DateTime createdAt;
  final DateTime updatedAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.languageId,
    required this.image,
    required this.slug,
    required this.status,
    required this.serialNumber,
    required this.isFeatured,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    int asInt(dynamic v) {
      if (v is int) return v;
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }
    String asString(dynamic v) => v?.toString() ?? '';
    DateTime asDate(dynamic v) {
      if (v is DateTime) return v;
      if (v is String && v.isNotEmpty) {
        try {
          return DateTime.parse(v);
        } catch (_) {}
      }
      return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    }

    return CategoryModel(
      id: asInt(json['id']),
      name: asString(json['name']),
      languageId: asInt(json['language_id']),
      image: asString(json['image']),
      slug: asString(json['slug']),
      status: asInt(json['status']),
      serialNumber: asInt(json['serial_number']),
      isFeatured: asString(json['is_featured']),
      createdAt: asDate(json['created_at']),
      updatedAt: asDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'language_id': languageId,
      'image': image,
      'slug': slug,
      'status': status,
      'serial_number': serialNumber,
      'is_featured': isFeatured,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
