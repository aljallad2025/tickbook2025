part of 'events_provider.dart';

void evAppendNextChunk(EventsProvider p) {
  if (p._all.isEmpty) return;
  final list = p._filteredAll();
  final already = p._visible.length;
  final remaining = list.length - already;
  final take = remaining > p._perPage ? p._perPage : remaining;
  if (take <= 0) return;
  p._visible.addAll(list.sublist(already, already + take));
}

void evApplyFilterAndResetVisible(EventsProvider p) {
  final base = p._filteredAll();
  p._hasMore = false;
  p._visible.clear();
  if (base.isNotEmpty) {
    final take = base.length > p._perPage ? p._perPage : base.length;
    p._visible.addAll(base.take(take));
    p._hasMore = take < base.length;
  }
}
