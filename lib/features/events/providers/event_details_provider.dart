import 'package:evento_app/features/events/data/models/event_details_models.dart';
import 'package:evento_app/network_services/core/event_details_service.dart';
import 'package:flutter/foundation.dart';

class EventDetailsProvider extends ChangeNotifier {
  bool _loading = false;
  String? _error;
  EventDetailsPageModel? _details;
  int _lastEventId = -1;
  final Map<int, EventDetailsPageModel> _cache = <int, EventDetailsPageModel>{};
  int? _selectedDateIndex;

  bool get loading => _loading;
  String? get error => _error;
  EventDetailsPageModel? get details => _details;
  int get lastEventId => _lastEventId;
  bool get hasCache => _cache.isNotEmpty;
  int? get selectedDateIndex => _selectedDateIndex;
  EventMultiDateModel? get selectedDateOccurrence {
    final d = _details?.event.dates;
    final idx = _selectedDateIndex;
    if (d == null || d.isEmpty || idx == null) return null;
    if (idx < 0 || idx >= d.length) return null;
    return d[idx];
  }

  Future<void> ensureLoaded(int eventId) async {
    if (eventId != _lastEventId && _cache.containsKey(eventId)) {
      _lastEventId = eventId;
      _details = _cache[eventId];
      _error = null;
      _selectedDateIndex = null;
      notifyListeners();
      return;
    }

    if (eventId != _lastEventId && !_cache.containsKey(eventId)) {
      _lastEventId = eventId;
      _details = null;
      _error = null;
      _selectedDateIndex = null;
      notifyListeners();
    }

    if (_details == null || eventId != _lastEventId) {
      await load(eventId);
    }
  }

  Future<void> load(int eventId) async {
    _setLoading(true);
    _error = null;
    _lastEventId = eventId;
    try {
      _details = await EventDetailsService.fetchDetails(eventId: eventId);
      if (_details != null) {
        _cache[eventId] = _details!;
      }
    } catch (e) {
      _details = null;
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refresh() async {
    if (_lastEventId != -1) {
      await load(_lastEventId);
    }
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  void setSelectedDateIndex(int? idx) {
    _selectedDateIndex = idx;
    notifyListeners();
  }
}
