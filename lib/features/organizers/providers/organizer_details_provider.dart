import 'package:evento_app/features/organizers/data/models/organizer_details_model.dart';
import 'package:evento_app/network_services/core/organizer_details_service.dart';
import 'package:flutter/foundation.dart';

class OrganizerDetailsProvider extends ChangeNotifier {
  bool _loading = false;
  String? _error;
  bool _initialized = false;
  int _lastId = 0;
  bool _lastIsAdmin = false;
  String _lastToken = '';
  OrganizerDetailsPageModel? _page;
  int? _selectedCategoryId;
  final Map<int, OrganizerDetailsPageModel> _cache =
      <int, OrganizerDetailsPageModel>{};

  bool get loading => _loading;
  String? get error => _error;
  bool get initialized => _initialized;
  OrganizerDetailsPageModel? get page => _page;
  int get lastId => _lastId;
  bool get lastIsAdmin => _lastIsAdmin;
  String get lastToken => _lastToken;
  int? get selectedCategoryId => _selectedCategoryId;

  Future<void> ensureInitialized({
    required String token,
    required int id,
    required bool isAdmin,
  }) async {
    // If we're asked for the same organizer again and we already have data,
    // do not hit the API; just update tracking fields.
    if (_initialized && id == _lastId && _page != null) {
      _lastIsAdmin = isAdmin;
      _lastToken = token;
      return;
    }

    // If different organizer but cached, reuse cache without network.
    if (id != _lastId && _cache.containsKey(id)) {
      _lastId = id;
      _lastIsAdmin = isAdmin;
      _lastToken = token;
      _page = _cache[id];
      _error = null;
      _initialized = true;
      notifyListeners();
      return;
    }
    // Otherwise, fetch if uninitialized or requesting a new organizer or no data yet.
    if (!_initialized || id != _lastId || _page == null) {
      await init(token: token, id: id, isAdmin: isAdmin);
    }
  }

  Future<void> init({
    required String token,
    required int id,
    required bool isAdmin,
  }) async {
    _setLoading(true);
    _error = null;
    _lastId = id;
    _lastIsAdmin = isAdmin;
    _lastToken = token;
    try {
      _page = await OrganizerDetailsService.fetch(
        token: token,
        id: id,
        isAdmin: isAdmin,
      );
      if (_page != null) {
        _cache[id] = _page!;
      }
      _initialized = true;
    } catch (e) {
      _page = null;
      _initialized = true;
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refresh() async {
    if (_lastId != 0) {
      await init(token: _lastToken, id: _lastId, isAdmin: _lastIsAdmin);
    }
  }

  void setSelectedCategory(int? id) {
    if (_selectedCategoryId == id) return;
    _selectedCategoryId = id;
    notifyListeners();
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }
}
