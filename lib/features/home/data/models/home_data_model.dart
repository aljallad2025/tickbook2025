import 'package:evento_app/features/categories/models/category_model.dart';
import '../../../events/data/models/event_item_model.dart';
import 'hero_section_model.dart';
import 'section_titles_model.dart';

class HomeDataModel {
  final List<CategoryModel> categories;
  final List<EventItemModel> latestEvents;
  final List<EventItemModel> eventsAll;
  final Map<int, List<EventItemModel>> eventsByCategory;
  final HeroSectionModel? hero;
  final SectionTitlesModel? sectionTitles;

  HomeDataModel({
    required this.categories,
    required this.latestEvents,
    required this.eventsAll,
    required this.eventsByCategory,
    required this.hero,
    required this.sectionTitles,
  });
}
