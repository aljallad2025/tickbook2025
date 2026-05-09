part of 'events_provider.dart';

extension _EventsProviderRemote on EventsProvider {
  Future<void> _refetchWithActiveFilters() async {
    if (_loading) return;
    _setLoading(true);
    try {
      final usedCategory = (_categoryId != null) ||
          ((_categoryName ?? '').trim().isNotEmpty) ||
          ((_categorySlug ?? '').trim().isNotEmpty);
      final usedQuery = (_query != null && _query!.trim().isNotEmpty);
      final res = await EventsServices.fetchEvents(
        perPage: _perPage,
        categoryId: _categoryId,
        categoryName: _categoryName,
        categorySlug: _categorySlug,
        keyword: _query,
        country: _country,
        state: _state,
        city: _city,
        from: _fromDate,
        to: _toDate,
        eventType: _eventType,
        minPrice: _priceMinSelected,
        maxPrice: _priceMaxSelected,
      );
      if (res.items.isNotEmpty) {
        _all = res.items; _currencySymbol = res.currencySymbol ?? _currencySymbol; _currencySymbolPosition = res.currencySymbolPosition ?? _currencySymbolPosition; _currencyText = res.currencyText ?? _currencyText;
        _recomputePriceBounds();
        _remoteFilteredByCategory = usedCategory;
        _remoteFilteredByQuery = usedQuery;
        _failed = false;
      } else {
        _remoteFilteredByCategory = usedCategory;
        _remoteFilteredByQuery = usedQuery;
        _failed = false; // empty list is not a fetch failure
      }
      _visible.clear();
      _appendNextChunk();
      _hasMore = _visible.length < _all.length;
    } catch (_) {
      // Fallback to local filtering
      _remoteFilteredByCategory = false;
      _remoteFilteredByQuery = false;
      _applyFilterAndResetVisible();
      _failed = false; // keep shimmer only for initial load failure
    } finally {
      _setLoading(false);
    }
  }

  void _recomputePriceBounds() {
    double minV = double.infinity;
    double maxV = 0.0;
    for (final e in _all) {
      final raw = e.ticketPrice?.toString().trim().toLowerCase();
      if (raw == null || raw.isEmpty) continue;
      final val = raw == 'free' ? 0.0 : double.tryParse(raw);
      if (val == null) continue;
      if (val < minV) minV = val;
      if (val > maxV) maxV = val;
    }
    if (minV == double.infinity) minV = 0.0;
    _priceMinBound = minV.floorToDouble();
    _priceMaxBound = maxV.ceilToDouble();
  }
}

