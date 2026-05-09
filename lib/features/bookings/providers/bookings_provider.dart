import 'dart:async';
import 'package:evento_app/features/bookings/data/models/booking_models.dart';
import 'package:evento_app/network_services/core/bookings_service.dart';
import 'package:evento_app/network_services/core/http_errors.dart';
import 'package:flutter/foundation.dart';

class BookingsProvider extends ChangeNotifier {
  bool _loading = false;
  String? _error;
  bool _initialized = false;
  List<BookingItemModel> _bookings = const [];
  String _pageTitle = 'Event Bookings';
  String _query = '';
  bool _authRequired = false;
  String _lastToken = '';

  bool get loading => _loading;
  String? get error => _error;
  bool get initialized => _initialized;
  String get pageTitle => _pageTitle;
  List<BookingItemModel> get bookings {
    if (_query.isEmpty) return List.unmodifiable(_bookings);
    final q = _query.toLowerCase();
    return _bookings
        .where(
          (b) =>
              b.bookingId.toLowerCase().contains(q) ||
              b.eventId.toLowerCase().contains(q) ||
              b.paymentStatus.toLowerCase().contains(q) ||
              b.customerFullName.toLowerCase().contains(q) ||
              b.eventDateRaw.toLowerCase().contains(q) ||
              b.eventTitle!.toLowerCase().contains(q) ||
              b.state.toLowerCase().contains(q) ||
              b.city.toLowerCase().contains(q) ||
              b.country.toLowerCase().contains(q) ||
              b.address.toLowerCase().contains(q),
        )
        .toList(growable: false);
  }

  bool get authRequired => _authRequired;
  String get lastToken => _lastToken;

  void clearAuthRequired() {
    if (_authRequired) {
      _authRequired = false;
      notifyListeners();
    }
  }

  void setQuery(String q) {
    _query = q.trim();

    notifyListeners();
  }

  Future<void> ensureInitialized(String token) async {
    if (!_initialized || token != _lastToken) {
      await init(token);
    }
  }

  Future<void> init(String token) async {
    if (_loading) return;
    _setLoading(true);
    _error = null;
    _authRequired = false;
    _lastToken = token;
    try {
      final res = await BookingsService.fetch(token);
      _pageTitle = (res.pageTitle).isNotEmpty ? res.pageTitle : _pageTitle;
      _bookings = res.bookings;
      _initialized = true;
    } catch (e) {
      _bookings = const [];
      _initialized = true;
      if (e is AuthRequiredException) {
        _authRequired = true;
        _error = e.message;
      } else {
        _error = e.toString();
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refresh(String token) async {
    await init(token);
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }
}
