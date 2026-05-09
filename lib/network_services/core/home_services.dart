import 'dart:convert';
import 'dart:developer' as developer;
import 'package:evento_app/features/categories/models/category_model.dart';
import 'package:evento_app/features/events/data/models/event_item_model.dart';
import 'package:evento_app/features/home/data/models/hero_section_model.dart';
import 'package:evento_app/features/home/data/models/home_data_model.dart';
import 'package:evento_app/features/home/data/models/section_titles_model.dart';
import 'package:evento_app/app/urls.dart';
import 'package:evento_app/utils/net_utils.dart';
import 'package:http/http.dart';

class HomeServices {
  static const String _tag = 'HomeServices';

  static Future<HomeDataModel> fetchHome({
    String? languageCode,
    bool forceRemote = false,
  }) async {
    final startTime = DateTime.now();
    developer.log(
      'Starting home data fetch - languageCode: $languageCode, forceRemote: $forceRemote',
      name: _tag,
      time: startTime,
    );

    // Fetch from API
    final uri = Uri.parse(AppUrls.home);
    developer.log(
      'Making GET request to: $uri',
      name: _tag,
      time: DateTime.now(),
    );

    late final Response response;
    try {
      response = await NetUtils.getWithRetry(
        uri,
        headers: {
          if (languageCode != null) 'Accept-Language': languageCode,
          'Accept': 'application/json',
        },
      );

      final requestDuration = DateTime.now().difference(startTime);
      developer.log(
        'Response received in ${requestDuration.inMilliseconds}ms - Status: ${response.statusCode}',
        name: _tag,
        time: DateTime.now(),
      );
    } catch (e, stackTrace) {
      developer.log(
        'Network request failed',
        name: _tag,
        error: e,
        stackTrace: stackTrace,
        level: 1000, // ERROR
      );
      rethrow;
    }

    if (response.statusCode != 200) {
      developer.log(
        'Failed to load home data - Status: ${response.statusCode}, Body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}',
        name: _tag,
        level: 1000, // ERROR
      );
      throw Exception('Failed to load home data: ${response.statusCode}');
    }

    // Parse JSON
    Map<String, dynamic>? decoded;
    try {
      final bodyStr = response.body;
      developer.log(
        'Response body length: ${bodyStr.length} chars',
        name: _tag,
        time: DateTime.now(),
      );

      final obj = json.decode(bodyStr);
      if (obj is Map<String, dynamic>) {
        decoded = obj;
        developer.log(
          'JSON decoded successfully - Top-level keys: ${decoded.keys.join(", ")}',
          name: _tag,
          time: DateTime.now(),
        );
      }
    } catch (e, stackTrace) {
      developer.log(
        'Failed to parse home data JSON',
        name: _tag,
        error: e,
        stackTrace: stackTrace,
        level: 1000, // ERROR
      );
      throw Exception('Failed to parse home data');
    }

    // Initialize collections
    List<CategoryModel> categories = [];
    List<EventItemModel> eventsAll = [];
    List<EventItemModel> latestEvents = [];
    Map<int, List<EventItemModel>> eventsByCat = {};
    HeroSectionModel? hero;
    SectionTitlesModel? sectionTitles;

    if (decoded is Map<String, dynamic>) {
      final data = decoded['data'];
      if (data is Map<String, dynamic>) {
        developer.log(
          'Data object keys: ${data.keys.join(", ")}',
          name: _tag,
          time: DateTime.now(),
        );

        // Parse categories
        final cats = data['categories'];
        if (cats is List) {
          try {
            categories = cats
                .whereType<Map<String, dynamic>>()
                .map(CategoryModel.fromJson)
                .toList();
            developer.log(
              'Parsed ${categories.length} categories',
              name: _tag,
              time: DateTime.now(),
            );
          } catch (e) {
            developer.log(
              'Error parsing categories',
              name: _tag,
              error: e,
              level: 900, // WARNING
            );
          }
        } else {
          developer.log(
            'No categories found or invalid format',
            name: _tag,
            level: 900, // WARNING
          );
        }

        // Parse latest/upcoming events
        final latest = data['upcoming_events'] ?? data['latest_events'];
        if (latest is List) {
          try {
            latestEvents = latest
                .whereType<Map<String, dynamic>>()
                .map(EventItemModel.fromJson)
                .toList();
            developer.log(
              'Parsed ${latestEvents.length} latest/upcoming events',
              name: _tag,
              time: DateTime.now(),
            );
          } catch (e) {
            developer.log(
              'Error parsing latest events',
              name: _tag,
              error: e,
              level: 900, // WARNING
            );
          }
        } else {
          developer.log(
            'No latest/upcoming events found',
            name: _tag,
            level: 900, // WARNING
          );
        }

        // Parse events
        final events = data['events'];
        if (events is Map<String, dynamic>) {
          developer.log(
            'Events object keys: ${events.keys.join(", ")}',
            name: _tag,
            time: DateTime.now(),
          );

          // Parse all events
          final all = events['all'];
          if (all is List) {
            try {
              eventsAll = all
                  .whereType<Map<String, dynamic>>()
                  .map(EventItemModel.fromJson)
                  .toList();
              developer.log(
                'Parsed ${eventsAll.length} events from "all"',
                name: _tag,
                time: DateTime.now(),
              );
            } catch (e) {
              developer.log(
                'Error parsing all events',
                name: _tag,
                error: e,
                level: 900, // WARNING
              );
            }
          }

          // Parse events by category
          final catMap = events['categories'];
          if (catMap is Map<String, dynamic>) {
            int totalCategoryEvents = 0;
            for (final entry in catMap.entries) {
              final list = entry.value;
              if (list is List) {
                final catId = int.tryParse(entry.key) ?? 0;
                try {
                  eventsByCat[catId] = list
                      .whereType<Map<String, dynamic>>()
                      .map((m) {
                    final enriched = Map<String, dynamic>.from(m);
                    enriched['category_id'] = catId;
                    return EventItemModel.fromJson(enriched);
                  }).toList();
                  totalCategoryEvents += eventsByCat[catId]!.length;
                } catch (e) {
                  developer.log(
                    'Error parsing events for category $catId',
                    name: _tag,
                    error: e,
                    level: 900, // WARNING
                  );
                }
              }
            }
            developer.log(
              'Parsed events by category - ${eventsByCat.length} categories, $totalCategoryEvents total events',
              name: _tag,
              time: DateTime.now(),
            );
          } else {
            developer.log(
              'No events by category found',
              name: _tag,
              level: 900, // WARNING
            );
          }
        } else {
          developer.log(
            'No events object found',
            name: _tag,
            level: 900, // WARNING
          );
        }

        // Parse hero section
        final heroInfo = data['heroInfo'];
        if (heroInfo is Map<String, dynamic>) {
          try {
            hero = HeroSectionModel.fromJson(heroInfo);
            developer.log(
              'Parsed hero section - firstTitle: ${hero.firstTitle}',
              name: _tag,
              time: DateTime.now(),
            );
          } catch (e) {
            developer.log(
              'Error parsing hero section',
              name: _tag,
              error: e,
              level: 900, // WARNING
            );
          }
        } else {
          developer.log(
            'No hero section found',
            name: _tag,
            level: 900, // WARNING
          );
        }

        // Parse section titles
        final secTitles = data['secTitleInfo'];
        if (secTitles is Map<String, dynamic>) {
          try {
            sectionTitles = SectionTitlesModel.fromJson(secTitles);
            developer.log(
              'Parsed section titles',
              name: _tag,
              time: DateTime.now(),
            );
          } catch (e) {
            developer.log(
              'Error parsing section titles',
              name: _tag,
              error: e,
              level: 900, // WARNING
            );
          }
        } else {
          developer.log(
            'No section titles found',
            name: _tag,
            level: 900, // WARNING
          );
        }
      }
    }

    final totalDuration = DateTime.now().difference(startTime);
    developer.log(
      'Home data fetch completed in ${totalDuration.inMilliseconds}ms - Summary: ${categories.length} categories, ${eventsAll.length} all events, ${latestEvents.length} latest events, ${eventsByCat.length} event categories',
      name: _tag,
      time: DateTime.now(),
    );

    return HomeDataModel(
      categories: categories,
      latestEvents: latestEvents,
      eventsAll: eventsAll,
      eventsByCategory: eventsByCat,
      hero: hero,
      sectionTitles: sectionTitles,
    );
  }
}
