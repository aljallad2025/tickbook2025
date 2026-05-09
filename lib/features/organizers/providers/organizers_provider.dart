import 'package:evento_app/features/organizers/data/models/organizer_model.dart';
import 'package:evento_app/network_services/core/organizer_service.dart';
import 'package:flutter/material.dart';

class OrganizersProvider extends ChangeNotifier {
  bool _loading = false;
  String? _error;
  bool _initialized = false;
  List<OrganizersModel> _all = const [];
  String _query = '';
  final TextEditingController searchController = TextEditingController();
  bool _failed = false;

  bool get loading => _loading;
  String? get error => _error;
  bool get initialized => _initialized;
  String get query => _query;
  List<OrganizersModel> get items => List.unmodifiable(_filtered());
  bool get failed => _failed;

  Future<void> ensureInitialized() async {
    if (!_initialized) {
      await init();
    }
  }

  Future<void> init() async {
    _setLoading(true);
    _error = null;
    try {
      _all = await OrganizerService().getOrganizers();
      _initialized = true;
      _failed = false;
    } catch (e) {
      // Keep existing list on failure to avoid clearing UI
      _initialized = true;
      _error = e.toString();
      _failed = true;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refresh() async {
    await init();
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  void setQuery(String value) {
    final v = value.trim();
    if (_query == v) return;
    _query = v;
    notifyListeners();
  }

  void clearQuery() {
    if (_query.isEmpty) return;
    _query = '';
    try {
      if (searchController.text.isNotEmpty) {
        searchController.clear();
      }
    } catch (_) {}
    notifyListeners();
  }

  List<OrganizersModel> _filtered() {
    if (_query.isEmpty) return _all;
    final q = _query.toLowerCase();
    bool contains(String? s) => (s ?? '').toLowerCase().contains(q);
    return _all
        .where((o) {
          if (contains(o.name)) return true;
          if (contains(o.username)) return true;
          if (contains(o.address)) return true;
          if (contains(o.country)) return true;
          if (contains(o.state)) return true;
          if (contains(o.city)) return true;
          if (contains(o.designation)) return true;
          return false;
        })
        .toList(growable: false);
  }

  @override
  void dispose() {
    try {
      searchController.dispose();
    } catch (_) {}
    super.dispose();
  }
}
