import 'package:evento_app/features/auth/providers/auth_provider.dart';
import 'package:evento_app/features/wishlist/data/models/wishlist_model.dart';
import 'package:evento_app/network_services/core/http_errors.dart';
import 'package:evento_app/network_services/core/wishlist_network_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WishlistProvider extends ChangeNotifier {
  WishlistProvider({required AuthProvider auth}) : _auth = auth;

  final AuthProvider _auth;
  bool _loading = false;
  bool _refreshing = false;
  WishlistPageModel? _data;
  Object? _error;
  String _query = '';
  final TextEditingController searchController = TextEditingController();

  String? _lastMessage;
  String get query => _query;
  List<Wishlists> get items {
    final list = _data?.wishlists ?? const <Wishlists>[];
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return List.unmodifiable(list);
    bool contains(String? s) => (s ?? '').toLowerCase().contains(q);
    return list.where((w) => contains(w.title)).toList(growable: false);
  }

  final ValueNotifier<WishlistAddResult?> addResultNotifier = ValueNotifier(
    null,
  );
  final ValueNotifier<WishlistDeleteResult?> deleteResultNotifier =
      ValueNotifier(null);

  final Set<int> _wishlistedEventIds = <int>{};

  bool get loading => _loading;
  bool get refreshing => _refreshing;
  WishlistPageModel? get data => _data;
  Object? get error => _error;
  String? get lastMessage => _lastMessage;
  bool isWishlisted(int eventId) => _wishlistedEventIds.contains(eventId);

  int? getWishlistIdForEvent(int eventId) {
    final list = _data?.wishlists;
    if (list == null) return null;
    for (final w in list) {
      if (w.eventId == eventId) return w.id;
    }
    return null;
  }

  Future<void> fetch() async {
    if (_loading) return;
    final token = _auth.token ?? '';
    _error = null;
    _setLoading(true);
    try {
      _data = await WishlistNetworkService.fetch(token);
      _wishlistedEventIds
        ..clear()
        ..addAll(
          (_data?.wishlists ?? const [])
              .map((w) => w.eventId)
              .where((id) => id != 0),
        );
    } on AuthRequiredException catch (e) {
      _error = e;
      _auth.onAuthExpired(from: const RouteSettings(name: '/wishlists'));
    } catch (e) {
      _error = e;
      _data = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refresh() async {
    if (_refreshing) return;
    final token = _auth.token ?? '';
    if (token.isEmpty) return;
    _refreshing = true;
    notifyListeners();
    try {
      final res = await WishlistNetworkService.fetch(token);
      _data = res;
      _wishlistedEventIds
        ..clear()
        ..addAll((res.wishlists).map((w) => w.eventId).where((id) => id != 0));
    } finally {
      _refreshing = false;
      notifyListeners();
    }
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  Future<void> addToWishlist({required int eventId}) async {
    final token = _auth.token ?? '';
    final customerId = (_auth.customer?['id'] is int)
        ? _auth.customer!['id'] as int
        : int.tryParse('${_auth.customer?['id'] ?? ''}') ?? 0;
    if (token.isEmpty || customerId == 0) {
      // Not logged in; trigger auth flow
      _auth.onAuthExpired(from: const RouteSettings(name: '/wishlists'));
      return;
    }
    try {
      final res = await WishlistNetworkService.add(
        token: token,
        eventId: eventId,
        customerId: customerId,
      );
      final success = res['success'] == true;
      final message = (res['message'] ?? '').toString();
      _lastMessage = message.isNotEmpty
          ? message
          : (success ? 'Added to wishlist' : 'Failed to add to wishlist');
      addResultNotifier.value = WishlistAddResult(
        success: success,
        message: _lastMessage!,
        eventId: eventId,
      );
      if (success) {
        _wishlistedEventIds.add(eventId);
        await fetch();
      }
      notifyListeners();
    } on AuthRequiredException catch (e) {
      addResultNotifier.value = WishlistAddResult(
        success: false,
        message: e.message,
        eventId: eventId,
      );
      _auth.onAuthExpired(from: const RouteSettings(name: '/wishlists'));
    } catch (e) {
      addResultNotifier.value = WishlistAddResult(
        success: false,
        message: 'Failed to add to wishlist',
        eventId: eventId,
      );
    }
  }

  Future<void> toggleWishlist({required int eventId}) async {
    if (isWishlisted(eventId)) {
      final wid = getWishlistIdForEvent(eventId);
      if (wid == null) {
        await fetch();
        final wid2 = getWishlistIdForEvent(eventId);
        if (wid2 == null) return;
        return removeFromWishlist(wishlistId: wid2, eventId: eventId);
      }
      return removeFromWishlist(wishlistId: wid, eventId: eventId);
    } else {
      return addToWishlist(eventId: eventId);
    }
  }

  Future<void> removeFromWishlist({
    required int wishlistId,
    int? eventId,
  }) async {
    final token = _auth.token ?? '';
    if (token.isEmpty) {
      _auth.onAuthExpired(from: const RouteSettings(name: '/wishlists'));
      return;
    }
    try {
      final res = await WishlistNetworkService.delete(
        token: token,
        wishlistId: wishlistId,
        eventId: eventId,
      );
      final success = res['success'] == true;
      final message = (res['message'] ?? '').toString();
      deleteResultNotifier.value = WishlistDeleteResult(
        success: success,
        message: message.isNotEmpty
            ? message
            : (success ? 'Removed from wishlist' : 'Failed to remove'),
        wishlistId: wishlistId,
        eventId: eventId,
      );
      if (success && _data != null) {
        _data = WishlistPageModel(
          pageTitle: _data!.pageTitle,
          wishlists: _data!.wishlists.where((w) => w.id != wishlistId).toList(),
        );
        if (eventId != null) {
          _wishlistedEventIds.remove(eventId);
        }
        notifyListeners();
      }
    } on AuthRequiredException catch (e) {
      deleteResultNotifier.value = WishlistDeleteResult(
        success: false,
        message: e.message,
        wishlistId: wishlistId,
        eventId: eventId,
      );
      _auth.onAuthExpired(from: const RouteSettings(name: '/wishlists'));
    } catch (e) {
      deleteResultNotifier.value = WishlistDeleteResult(
        success: false,
        message: 'Failed to remove from wishlist'.tr,
        wishlistId: wishlistId,
        eventId: eventId,
      );
    }
  }

  void setQuery(String q) {
    final v = q.trim();
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

  @override
  void dispose() {
    try {
      searchController.dispose();
    } catch (_) {}
    super.dispose();
  }
}
