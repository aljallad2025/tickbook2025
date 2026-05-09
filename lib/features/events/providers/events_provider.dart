import 'package:evento_app/features/events/data/models/event_item_model.dart';
import 'package:evento_app/network_services/core/events_services.dart';
import 'package:evento_app/network_services/core/google_geocode_service.dart';
import 'package:evento_app/app/keys.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:geocoding/geocoding.dart';
import 'package:evento_app/features/events/data/models/location_models.dart';
import 'package:evento_app/network_services/core/location_filter_service.dart';
part 'events_provider_paging.dart';
part 'events_provider_remote.dart';
part 'events_provider_filters.dart';

class EventsProvider extends ChangeNotifier {
  final List<EventItemModel> _visible = [];
  List<EventItemModel> _all = [];
  String? _currencySymbol;
  String? _currencySymbolPosition; // 'left' or 'right'
  String? _currencyText;
  bool _loading = false;
  bool _loadingMore = false;
  bool _hasMore = true;
  int _perPage = 15;
  bool _initialized = false;
  bool _failed = false;
  bool _remoteFilteredByCategory = false;
  bool _remoteFilteredByQuery = false;
  int? _categoryId;
  String? _categoryName;
  String? _categorySlug;
  String? _query;
  String? _country;
  String? _state;
  String? _city;
  String? _eventType;
  String? _fromDate;
  String? _toDate;
  double? _priceMinSelected;
  double? _priceMaxSelected;
  double _priceMinBound = 0;
  double _priceMaxBound = 0;
  double? _centerLat;
  double? _centerLon;
  double? _radiusKm;
  String? _centerAddress;
  final Map<String, ll.LatLng?> _addressCoordsCache = {};
  bool _warmingGeo = false;
  GoogleGeocodeService? _googleGeo;
  // Filter option datasets
  List<CountryItem> _countries = const [];
  List<StateItem> _states = const [];
  List<CityItem> _cities = const [];
  bool _filtersLoading = false;
  bool _filtersLoaded = false;

  List<EventItemModel> get events => List.unmodifiable(_visible);
  bool get loading => _loading;
  bool get loadingMore => _loadingMore;
  bool get hasMore => _hasMore;
  int get perPage => _perPage;
  bool get failed => _failed;
  int? get categoryId => _categoryId;
  String? get categoryName => _categoryName;
  String? get categorySlug => _categorySlug;
  String? get query => _query;
  String? get country => _country;
  String? get stateName => _state;
  String? get city => _city;
  String? get eventType => _eventType;
  String? get fromDate => _fromDate;
  String? get toDate => _toDate;
  double? get priceMinSelected => _priceMinSelected;
  double? get priceMaxSelected => _priceMaxSelected;
  double get priceMinBound => _priceMinBound;
  double get priceMaxBound => _priceMaxBound;
  double? get centerLat => _centerLat;
  double? get centerLon => _centerLon;
  double? get radiusKm => _radiusKm;
  String? get centerAddress => _centerAddress; /*
  String get currencySymbol => (_currencySymbol ?? '').isEmpty ? '4' : (_currencySymbol ?? '4');
  String get currencySymbolPosition => (_currencySymbolPosition ?? 'left');
  String? get currencyText => _currencyText; */
  String get currencySymbol => (_currencySymbol ?? '').isEmpty
      ? 'BHD'
      : (_currencySymbol ?? 'BHD');
  String get currencySymbolPosition => (_currencySymbolPosition ?? 'left');
  String? get currencyText => _currencyText;
  // Expose filter datasets
  List<CountryItem> get countries => _countries;
  List<StateItem> get states => _states;
  List<CityItem> get cities => _cities;
  bool get filtersLoading => _filtersLoading;
  bool get filtersLoaded => _filtersLoaded;

  set perPage(int value) {
    if (value <= 0) return;
    _perPage = value;
  }

  bool get initialized => _initialized;

  Future<void> ensureInitialized({int perPage = 15}) async {
    if (_initialized) {
      if (_perPage != perPage) {
        refreshVisible(perPage: perPage);
      }
      return;
    }
    await init(perPage: perPage);
  }

  Future<void> init({int perPage = 15}) async {
    _perPage = perPage;
    _setLoading(true);
    try {
      try {
        final gKey = await AppKeys.getGoogleMapKey() ?? '';
        _googleGeo = GoogleGeocodeService(gKey);
      } catch (_) {}
      final res = await EventsServices.fetchEvents();
      _all = res.items;
      _currencySymbol = res.currencySymbol ?? _currencySymbol;
      _currencySymbolPosition =
          res.currencySymbolPosition ?? _currencySymbolPosition;
      _currencyText = res.currencyText ?? _currencyText;
      _recomputePriceBounds();
      _visible.clear();
      _appendNextChunk();
      _hasMore = _visible.length < _all.length;
      _initialized = true;
      _remoteFilteredByCategory = false;
      _remoteFilteredByQuery = false;
      _failed = false;
    } catch (_) {
      // Preserve existing items on failure to avoid blank lists
      _initialized = true;
      // Recalculate bounds based on existing data if any
      _recomputePriceBounds();
      _failed = true;
    } finally {
      _setLoading(false);
    }
  }

  void setCategoryFilter({int? id, String? name, String? slug}) {
    if (_categoryId == id &&
        (_categoryName ?? '').toLowerCase() == (name ?? '').toLowerCase() &&
        (_categorySlug ?? '') == (slug ?? '')) {
      return;
    }
    _updateAndRefetch(() {
      _categoryId = id;
      _categoryName = name;
      _categorySlug = slug;
    }, remote: true);
  }

  void clearCategoryFilter() {
    if (_categoryId == null) return;
    _categoryId = null;
    _categoryName = null;
    _categorySlug = null;
    _visible.clear();
    _remoteFilteredByCategory = false;
    init(perPage: _perPage);
  }

  void setQuery(String? value) {
    final v = value?.trim();
    if ((v ?? '') == (_query ?? '')) return;
    _updateAndRefetch(() {
      _query = (v?.isEmpty ?? true) ? null : v;
      _remoteFilteredByQuery = false;
    });
  }

  void search(String? value) {
    final v = value?.trim();
    if ((v ?? '') == (_query ?? '')) {
      _refetchWithActiveFilters();
      return;
    }
    _updateAndRefetch(() {
      _query = (v?.isEmpty ?? true) ? null : v;
    }, remote: true);
  }

  void clearQuery() {
    if (_query == null) return;
    _updateAndRefetch(() {
      _query = null;
      _remoteFilteredByQuery = false;
    });
  }

  void setAdvancedFilters({
    String? country,
    String? state,
    String? city,
    String? eventType,
    String? fromDate,
    String? toDate,
    double? minPrice,
    double? maxPrice,
  }) {
    _updateAndRefetch(() {
      _country = (country?.trim().isEmpty ?? true) ? null : country?.trim();
      _state = (state?.trim().isEmpty ?? true) ? null : state?.trim();
      _city = (city?.trim().isEmpty ?? true) ? null : city?.trim();
      _eventType = (eventType?.trim().isEmpty ?? true)
          ? null
          : eventType?.trim();
      _fromDate = (fromDate?.trim().isEmpty ?? true) ? null : fromDate?.trim();
      _toDate = (toDate?.trim().isEmpty ?? true) ? null : toDate?.trim();
      _priceMinSelected = minPrice;
      _priceMaxSelected = maxPrice;
    }, remote: true);
  }

  void clearAdvancedFilters() {
    _updateAndRefetch(() {
      _country = null;
      _state = null;
      _city = null;
      _eventType = null;
      _fromDate = null;
      _toDate = null;
      _priceMinSelected = null;
      _priceMaxSelected = null;
    });
  }

  void clearEventType() {
    if (_eventType == null) return;
    _updateAndRefetch(() {
      _eventType = null;
    }, remote: true);
  }

  void clearCountry() {
    if (_country == null) return;
    _updateAndRefetch(() {
      _country = null;
    }, remote: true);
    _maybeClearGeoRadius();
  }

  void clearStateName() {
    if (_state == null) return;
    _updateAndRefetch(() {
      _state = null;
    }, remote: true);
    _maybeClearGeoRadius();
  }

  void clearCity() {
    if (_city == null) return;
    _updateAndRefetch(() {
      _city = null;
    }, remote: true);
    _maybeClearGeoRadius();
  }

  void clearFromDate() {
    if (_fromDate == null) return;
    _updateAndRefetch(() {
      _fromDate = null;
    }, remote: true);
  }

  void clearToDate() {
    if (_toDate == null) return;
    _updateAndRefetch(() {
      _toDate = null;
    }, remote: true);
  }

  void clearPriceRange() {
    if (_priceMinSelected == null && _priceMaxSelected == null) return;
    _updateAndRefetch(() {
      _priceMinSelected = null;
      _priceMaxSelected = null;
    }, remote: true);
  }

  void setGeoRadius({double? lat, double? lon, double? radiusKm}) {
    _updateAndRefetch(() {
      _centerLat = lat;
      _centerLon = lon;
      _radiusKm = radiusKm;
      _centerAddress = null;
    }, remote: false);
    // Resolve human-readable address for center in background
    _resolveCenterAddress();
    _warmAddressCoordinatesForRadius();
  }

  void clearGeoRadius() {
    if (_centerLat == null && _centerLon == null && _radiusKm == null) return;
    _updateAndRefetch(() {
      _centerLat = null;
      _centerLon = null;
      _radiusKm = null;
      _centerAddress = null;
      _addressCoordsCache.clear();
    }, remote: false);
  }

  void clearAllFilters() {
    _updateAndRefetch(() {
      _categoryId = null;
      _categoryName = null;
      _categorySlug = null;
      _query = null;
      _country = null;
      _state = null;
      _city = null;
      _eventType = null;
      _fromDate = null;
      _toDate = null;
      _priceMinSelected = null;
      _priceMaxSelected = null;
      _centerLat = null;
      _centerLon = null;
      _radiusKm = null;
      _remoteFilteredByCategory = false;
      _remoteFilteredByQuery = false;
    });
  }

  Future<void> loadMore() async {
    if (_loadingMore || !_hasMore || _loading) return;
    _setLoadingMore(true);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    _appendNextChunk();
    final total = _filteredAll().length;
    _hasMore = _visible.length < total;
    _setLoadingMore(false);
  }

  void refreshVisible({int? perPage}) {
    if (perPage != null) _perPage = perPage;
    _visible.clear();
    _applyFilterAndResetVisible();
  }

  Future<void> refresh() async {
    await init(perPage: _perPage);
    notifyListeners();
  }

  Future<void> ensureFilterOptions({String? languageCode}) async {
    if (_filtersLoaded || _filtersLoading) return;
    _filtersLoading = true;
    notifyListeners();
    try {
      final tuple = await LocationFilterService.fetch(languageCode: languageCode);
      _countries = tuple.$1;
      _states = tuple.$2;
      _cities = tuple.$3;
      _filtersLoaded = true;
    } catch (_) {
      _filtersLoaded = false;
    } finally {
      _filtersLoading = false;
      notifyListeners();
    }
  }

  List<EventItemModel> _filteredAll() {
    Iterable<EventItemModel> list = _all;

    if (!_remoteFilteredByCategory) list = evApplyCategoryFilter(this, list);
    if (!_remoteFilteredByQuery) list = evApplyKeywordFilter(this, list);
    list = evApplyAdvancedFilters(this, list);
    list = evApplyPriceRangeFilter(this, list);

    final result = list.toList()
      ..sort((a, b) {
        final c1 = evCmp(
          a.categoryName ?? a.category?.name,
          b.categoryName ?? b.category?.name,
        );
        return c1 != 0 ? c1 : evCmp(a.title, b.title);
      });
    return result;
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  void _setLoadingMore(bool v) {
    _loadingMore = v;
    notifyListeners();
  }

  void _updateAndRefetch(void Function() update, {bool remote = false}) {
    update();
    _visible.clear();
    if (remote) {
      _refetchWithActiveFilters();
    } else {
      _applyFilterAndResetVisible();
    }
  }

  void _appendNextChunk() {
    evAppendNextChunk(this);
    notifyListeners();
  }

  void _applyFilterAndResetVisible() {
    evApplyFilterAndResetVisible(this);
    notifyListeners();
  }

  void _maybeClearGeoRadius() {
    if (_centerLat == null && _centerLon == null && _radiusKm == null) return;
    if (_country == null && _state == null && _city == null) {
      clearGeoRadius();
    }
  }

  Future<void> _resolveCenterAddress() async {
    final lat = _centerLat;
    final lon = _centerLon;
    if (lat == null || lon == null) return;
    try {
      String? label;
      // Prefer Google reverse geocoding if key provided
      if ((_googleGeo?.enabled ?? false)) {
        final res = await _googleGeo!.reverse(lat, lon);
        label = res?.formattedAddress;
      }
      if (label == null || label.trim().isEmpty) {
        // Fallback to platform geocoding
        final list = await placemarkFromCoordinates(lat, lon);
        if (list.isNotEmpty) {
          final p = list.first;
          final parts = <String>[
            if ((p.street ?? '').trim().isNotEmpty) p.street!,
            if ((p.locality ?? '').trim().isNotEmpty) p.locality!,
            if ((p.administrativeArea ?? '').trim().isNotEmpty)
              p.administrativeArea!,
            if ((p.country ?? '').trim().isNotEmpty) p.country!,
          ];
          label = parts.where((e) => e.trim().isNotEmpty).join(', ');
        }
      }
      if ((label ?? '').trim().isEmpty) return;
      // Only set if center still the same
      if (_centerLat == lat && _centerLon == lon) {
        _centerAddress = label!.trim();
        notifyListeners();
      }
    } catch (_) {}
  }

  // Resolve coordinates for an event; uses direct lat/lon or cached geocode
  ll.LatLng? _coordsFor(EventItemModel e) {
    if (e.latitude != null && e.longitude != null) {
      return ll.LatLng(e.latitude!, e.longitude!);
    }
    final addr = e.address?.trim();
    if (addr == null || addr.isEmpty) return null;
    return _addressCoordsCache[addr];
  }

  Future<void> _warmAddressCoordinatesForRadius({int max = 25}) async {
    if (_warmingGeo) return;
    if (_centerLat == null || _centerLon == null || _radiusKm == null) return;
    _warmingGeo = true;
    int count = 0;
    for (final e in _all) {
      if (count >= max) break;
      if (e.latitude != null && e.longitude != null) {
        continue; // already has coords
      }
      final addr = e.address?.trim();
      if (addr == null || addr.isEmpty) continue;
      if (_addressCoordsCache.containsKey(addr)) continue; // already attempted
      try {
        ll.LatLng? resolved;
        // Prefer Google if key provided
        if ((_googleGeo?.enabled ?? false)) {
          final gRes = await _googleGeo!.forward(addr);
          if (gRes != null) {
            resolved = gRes.point;
          }
        }
        // Fallback to platform geocoding if Google unavailable or failed
        if (resolved == null) {
          final list = await locationFromAddress(addr);
          if (list.isNotEmpty) {
            resolved = ll.LatLng(list.first.latitude, list.first.longitude);
          }
        }
        _addressCoordsCache[addr] = resolved; // can be null if both failed
      } catch (_) {
        _addressCoordsCache[addr] = null;
      }
      count++;
      // Re-filter progressively so nearby events appear as soon as resolved
      _applyFilterAndResetVisible();
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    _warmingGeo = false;
    notifyListeners();
  }
}
