part of 'events_provider.dart';

int evCmp(String? x, String? y) {
  final sx = (x ?? '').toLowerCase();
  final sy = (y ?? '').toLowerCase();
  return sx.compareTo(sy);
}

String _evNorm(String? s) {
  final v = (s ?? '').toLowerCase();
  // Normalize dashes/underscores and strip non-alphanumerics to improve matching
  final replaced = v.replaceAll(RegExp(r'[-_]+'), ' ');
  final compact = replaced.replaceAll(RegExp(r'[^a-z0-9\s]+'), ' ');
  return compact.replaceAll(RegExp(r'\s+'), ' ').trim();
}

bool evContains(String? s, String q) => _evNorm(s).contains(_evNorm(q));

const Map<String, String> _isoCountryMap = {
  'us': 'united states',
  'usa': 'united states',
  'uk': 'united kingdom',
  'gb': 'united kingdom',
  'ae': 'united arab emirates',
  'in': 'india',
  'ca': 'canada',
  'au': 'australia',
  'de': 'germany',
  'fr': 'france',
  'es': 'spain',
  'it': 'italy',
  'jp': 'japan',
  'cn': 'china',
  'br': 'brazil',
  'za': 'south africa',
  'ng': 'nigeria',
};

String _abbrevOfCountry(String? name) {
  final n = (name ?? '').trim().toLowerCase();
  if (n.isEmpty) return '';
  // Build acronym from first letters
  final parts = n.split(RegExp(r'\s+'));
  final acronym = parts.map((p) => p.isNotEmpty ? p[0] : '').join();
  return acronym;
}

Iterable<EventItemModel> evApplyCategoryFilter(
  EventsProvider p,
  Iterable<EventItemModel> list,
) {
  final name = p._categoryName?.trim();
  if (name != null && name.isNotEmpty) {
    final target = name.toLowerCase();
    final exact = list.where(
      (e) => evContains(e.categoryName ?? e.category?.name, target),
    );
    if (exact.isNotEmpty) return exact;

    final partial = list.where(
      (e) => evContains(e.categoryName ?? e.category?.name, target),
    );
    if (partial.isNotEmpty) return partial;

    if (p._categoryId != null) {
      final byId = list.where(
        (e) => e.categoryId != null && e.categoryId == p._categoryId,
      );
      if (byId.isNotEmpty) return byId;

      final loose = p._all.where(
        (e) => evContains(e.title, target) || evContains(e.address, target),
      );
      if (loose.isNotEmpty) return loose;
    }
  } else if (p._categoryId != null) {
    return list.where(
      (e) => e.categoryId != null && e.categoryId == p._categoryId,
    );
  }
  return list;
}

Iterable<EventItemModel> evApplyKeywordFilter(
  EventsProvider p,
  Iterable<EventItemModel> list,
) {
  final q = p._query?.toLowerCase();
  if (q == null || q.isEmpty) return list;
  bool match(EventItemModel e) {
    if (evContains(e.title, q)) return true;
    if (evContains(e.categoryName ?? e.category?.name, q)) return true;
    if (evContains(e.address, q)) return true;
    if (evContains(e.country, q)) return true;
    if (evContains(e.state, q)) return true;
    if (evContains(e.city, q)) return true;
    if (evContains(e.date, q)) return true;
    if (evContains(e.time, q)) return true;
    return false;
  }

  return list.where(match);
}

Iterable<EventItemModel> evApplyAdvancedFilters(
  EventsProvider p,
  Iterable<EventItemModel> list,
) {
  var out = list;
  if (p._eventType != null && p._eventType!.trim().isNotEmpty) {
    final t = p._eventType!.toLowerCase();
    out = out.where((e) => (e.eventType).toLowerCase() == t);
  }
  if (p._country != null && p._country!.isNotEmpty) {
    final rawInput = p._country!;
    final input = _evNorm(rawInput);
    // Accept common shorthand & slugs
    final expanded = _isoCountryMap[input] ?? _isoCountryMap[rawInput.toLowerCase()];
    out = out.where((e) {
      final c = _evNorm(e.country);
      if (c.isEmpty) {
        // If country field missing, fallback to address text match
        return evContains(e.address, input);
      }
      if (evContains(c, input)) return true;
      if (expanded != null && c == _evNorm(expanded)) return true;
      final acr = _abbrevOfCountry(c);
      if (acr == input) return true;
      if (evContains(e.address, input)) return true;
      return false;
    });
  }
  if (p._state != null && p._state!.isNotEmpty) {
    final s = _evNorm(p._state!);
    out = out.where((e) => evContains(e.state, s) || evContains(e.address, s));
  }
  if (p._city != null && p._city!.isNotEmpty) {
    final s = _evNorm(p._city!);
    out = out.where((e) => evContains(e.city, s) || evContains(e.address, s));
  }
  if (p._fromDate != null || p._toDate != null) {
    DateTime? parse(String? s) => s == null ? null : DateTime.tryParse(s);
    final from = parse(p._fromDate);
    final to = parse(p._toDate);
    out = out.where((e) {
      final ed = parse(e.date);
      if (ed == null) return true;
      if (from != null &&
          ed.isBefore(DateTime(from.year, from.month, from.day))) {
        return false;
      }
      if (to != null &&
          ed.isAfter(DateTime(to.year, to.month, to.day, 23, 59, 59))) {
        return false;
      }
      return true;
    });
  }
  if (p._centerLat != null && p._centerLon != null && p._radiusKm != null) {
    final center = ll.LatLng(p._centerLat!, p._centerLon!);
    final dist = const ll.Distance();
    out = out.where((e) {
      ll.LatLng? target;
      if (e.latitude != null && e.longitude != null) {
        target = ll.LatLng(e.latitude!, e.longitude!);
      } else if (e.address != null && e.address!.trim().isNotEmpty) {
        target = p._coordsFor(e);
      }
      if (target == null) return false;
      final dKm = dist.as(ll.LengthUnit.Kilometer, center, target);
      return dKm <= p._radiusKm!;
    });
  }
  return out;
}

Iterable<EventItemModel> evApplyPriceRangeFilter(
  EventsProvider p,
  Iterable<EventItemModel> list,
) {
  if (p._priceMinSelected == null && p._priceMaxSelected == null) return list;
  final minP = p._priceMinSelected ?? double.negativeInfinity;
  final maxP = p._priceMaxSelected ?? double.infinity;
  double? priceOf(EventItemModel e) {
    final raw = e.ticketPrice?.toString().trim().toLowerCase();
    if (raw == null || raw.isEmpty) return null;
    if (raw == 'free') return 0.0;
    return double.tryParse(raw);
  }

  return list.where((e) {
    final pz = priceOf(e);
    if (pz == null) return true;
    if (pz < minP) return false;
    if (pz > maxP) return false;
    return true;
  });
}
