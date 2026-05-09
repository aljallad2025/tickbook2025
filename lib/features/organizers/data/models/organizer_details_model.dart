import 'package:evento_app/features/events/data/models/event_item_model.dart';
import 'package:evento_app/features/organizers/data/models/organizer_model.dart';

class OrganizerDetailsPageModel {
  final bool isAdmin;
  final OrganizersModel organizer;
  final Map<int, List<EventItemModel>> eventsByCategory;
  final List<OrganizerCategory> categories;

  OrganizerDetailsPageModel({
    required this.isAdmin,
    required this.organizer,
    required this.eventsByCategory,
    required this.categories,
  });

  factory OrganizerDetailsPageModel.fromRoot(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>? ?? {});
    final isAdmin = data['admin'] == true;
    final org = (data['organizer'] is Map<String, dynamic>)
        ? OrganizersModel.fromJson(data['organizer'] as Map<String, dynamic>)
        : OrganizersModel.fromJson({});

    // Categories list (id, name)
    List<OrganizerCategory> catsList = [];
    final rawCats = data['categories'];
    if (rawCats is List) {
      catsList = rawCats
          .whereType<Map<String, dynamic>>()
          .map(
            (m) => OrganizerCategory(
              id: m['id'] is int
                  ? m['id'] as int
                  : int.tryParse('${m['id']}') ?? 0,
              name: (m['name'] ?? '').toString(),
            ),
          )
          .toList();
    } else if (rawCats is Map<String, dynamic>) {
      // Some APIs may return categories as an id->object map
      catsList = rawCats.values
          .whereType<Map<String, dynamic>>()
          .map(
            (m) => OrganizerCategory(
              id: m['id'] is int
                  ? m['id'] as int
                  : int.tryParse('${m['id']}') ?? 0,
              name: (m['name'] ?? '').toString(),
            ),
          )
          .toList();
    }

    // Events grouped by categories
    final Map<int, List<EventItemModel>> byCat = {};
    final eventsVal = data['events'];
    Map<String, dynamic>? categoriesMap;
    if (eventsVal is Map<String, dynamic>) {
      if (eventsVal.containsKey('categories') &&
          eventsVal['categories'] is Map<String, dynamic>) {
        categoriesMap = (eventsVal['categories'] as Map)
            .cast<String, dynamic>();
      } else {
        // Sometimes the 'events' object itself is already the categories map
        categoriesMap = eventsVal.cast<String, dynamic>();
      }
    }
    if (categoriesMap != null) {
      categoriesMap.forEach((key, value) {
        final catId = int.tryParse(key.toString()) ?? 0;
        final list = (value as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(EventItemModel.fromJson)
            .toList();
        byCat[catId] = list;
      });
    }

    return OrganizerDetailsPageModel(
      isAdmin: isAdmin,
      organizer: org,
      eventsByCategory: byCat,
      categories: catsList,
    );
  }
}

class OrganizerCategory {
  final int id;
  final String name;
  OrganizerCategory({required this.id, required this.name});
}
