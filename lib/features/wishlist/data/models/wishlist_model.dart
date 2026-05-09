class Wishlists {
  final int id;
  final int eventId;
  final String title;
  final String image;

  Wishlists({
    required this.id,
    required this.eventId,
    required this.title,
    required this.image,
  });

  factory Wishlists.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v) => v is int ? v : int.tryParse(v.toString()) ?? 0;
    return Wishlists(
      id: toInt(json['id']),
      eventId: toInt(json['event_id']),
      title: (json['title'] ?? '').toString(),
      image: (json['image'] ?? json['thumbnail']).toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'event_id': eventId,
    'title': title,
    'image': image,
  };
}

class WishlistPageModel {
  final String pageTitle;
  final List<Wishlists> wishlists;

  const WishlistPageModel({required this.pageTitle, required this.wishlists});
}

class WishlistAddResult {
  final bool success;
  final String message;
  final int eventId;
  const WishlistAddResult({
    required this.success,
    required this.message,
    required this.eventId,
  });
}

class WishlistDeleteResult {
  final bool success;
  final String message;
  final int wishlistId;
  final int? eventId;
  const WishlistDeleteResult({
    required this.success,
    required this.message,
    required this.wishlistId,
    this.eventId,
  });
}
