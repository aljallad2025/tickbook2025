import 'package:evento_app/features/home/data/models/home_data_model.dart';
import 'package:evento_app/network_services/core/home_services.dart';
import 'package:evento_app/features/home/providers/locale_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/widgets.dart';
import 'dart:developer' as developer;

class HomeProvider extends ChangeNotifier {
  static const String _tag = 'HomeProvider';

  final TextEditingController searchController = TextEditingController();
  String _searchText = '';
  bool _loading = false;
  HomeDataModel? _data;
  int? _selectedCategoryId;
  bool _initialized = false;
  bool _fetching = false;
  bool _failed = false;

  bool get loading => _loading;
  HomeDataModel? get data => _data;
  int? get selectedCategoryId => _selectedCategoryId;
  String get searchText => _searchText;
  bool get failed => _failed;
  bool get initialized => _initialized;

  Future<void> fetch([BuildContext? context, bool forceRemote = false]) async {
    if (_fetching) {
      developer.log(
        'Fetch called while already fetching, skipping',
        name: _tag,
        level: 900, // WARNING
      );
      return;
    }

    developer.log(
      'Starting fetch - forceRemote: $forceRemote, hasContext: ${context != null}',
      name: _tag,
      time: DateTime.now(),
    );

    _fetching = true;
    _setLoading(true);

    try {
      String? lang;
      if (context != null) {
        try {
          lang = context.read<LocaleProvider>().locale.languageCode;
          developer.log(
            'Using language code: $lang',
            name: _tag,
            time: DateTime.now(),
          );
        } catch (e) {
          developer.log(
            'Failed to get language code from LocaleProvider',
            name: _tag,
            error: e,
            level: 900, // WARNING
          );
        }
      }

      developer.log(
        'Calling HomeServices.fetchHome',
        name: _tag,
        time: DateTime.now(),
      );

      _data = await HomeServices.fetchHome(
        languageCode: lang,
        forceRemote: true,
      );

      _initialized = true;
      _failed = false;

      developer.log(
        'Fetch successful - categories: ${_data?.categories.length ?? 0}, eventsAll: ${_data?.eventsAll.length ?? 0}, latestEvents: ${_data?.latestEvents.length ?? 0}',
        name: _tag,
        time: DateTime.now(),
      );
    } catch (e, stackTrace) {
      developer.log(
        'Fetch failed - keeping existing data to avoid blank UI',
        name: _tag,
        error: e,
        stackTrace: stackTrace,
        level: 1000, // ERROR
      );

      // Keep existing data on failure to avoid blank UI after a transient error
      _initialized = true;
      _failed = true;
    } finally {
      _setLoading(false);
      _fetching = false;
    }
  }

  Future<void> ensureFetched([BuildContext? context]) async {
    developer.log(
      'ensureFetched called - initialized: $_initialized',
      name: _tag,
      time: DateTime.now(),
    );

    if (_initialized) {
      developer.log(
        'Already initialized, skipping fetch',
        name: _tag,
        time: DateTime.now(),
      );
      return;
    }

    await fetch(context, true);
  }

  Future<void> refresh([BuildContext? context]) async {
    developer.log(
      'Refresh called',
      name: _tag,
      time: DateTime.now(),
    );

    await fetch(context, true);
    notifyListeners();
  }

  void selectCategory(int? id) {
    developer.log(
      'Category selected - from: $_selectedCategoryId to: $id',
      name: _tag,
      time: DateTime.now(),
    );

    _selectedCategoryId = id;
    notifyListeners();
  }

  void setSearchText(String v) {
    final t = v.trimLeft();
    if (_searchText == t) {
      developer.log(
        'Search text unchanged, skipping update',
        name: _tag,
        time: DateTime.now(),
      );
      return;
    }

    developer.log(
      'Search text changed - from: "$_searchText" to: "$t"',
      name: _tag,
      time: DateTime.now(),
    );

    _searchText = t;
    notifyListeners();
  }

  void clearSearchText() {
    developer.log(
      'Clearing search text - was: "$_searchText"',
      name: _tag,
      time: DateTime.now(),
    );

    _searchText = '';
    try {
      if (searchController.text.isNotEmpty) searchController.clear();
    } catch (e) {
      developer.log(
        'Failed to clear search controller',
        name: _tag,
        error: e,
        level: 900, // WARNING
      );
    }
    notifyListeners();
  }

  void _setLoading(bool v) {
    developer.log(
      'Loading state changed: $_loading -> $v',
      name: _tag,
      time: DateTime.now(),
    );

    _loading = v;
    notifyListeners();
  }

  @override
  void dispose() {
    developer.log(
      'Disposing HomeProvider',
      name: _tag,
      time: DateTime.now(),
    );

    try {
      searchController.dispose();
    } catch (e) {
      developer.log(
        'Error disposing search controller',
        name: _tag,
        error: e,
        level: 900, // WARNING
      );
    }
    super.dispose();
  }
}
