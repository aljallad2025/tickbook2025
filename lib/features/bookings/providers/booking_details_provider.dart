import 'package:evento_app/features/bookings/data/models/booking_details_model.dart';
import 'package:evento_app/network_services/core/booking_details_service.dart';
import 'package:evento_app/network_services/core/http_errors.dart';
import 'package:flutter/foundation.dart';

class BookingDetailsProvider extends ChangeNotifier {
  bool _loading = false;
  bool _refreshing = false;
  String? _error;
  BookingDetailsPageModel? _page;
  bool _initialized = false;
  String _lastToken = '';
  int _lastBookingId = 0;
  bool _authRequired = false;

  bool get loading => _loading;
  bool get refreshing => _refreshing;
  String? get error => _error;
  BookingDetailsPageModel? get page => _page;
  bool get initialized => _initialized;
  bool get authRequired => _authRequired;
  String get lastToken => _lastToken;

  Future<void> ensureInitialized({required String token, required int bookingId}) async {
    if (!_initialized || token != _lastToken || bookingId != _lastBookingId) {
      await init(token: token, bookingId: bookingId);
    }
  }

  Future<void> init({required String token, required int bookingId}) async {
    _setLoading(true);
    _error = null;
    _authRequired = false;
    _lastToken = token;
    _lastBookingId = bookingId;
    try {
      final res = await BookingDetailsService.fetch(token: token, bookingId: bookingId);
      _page = res;
      _initialized = true;
    } catch (e) {
      _page = null;
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

  Future<void> refresh() async {
    if (_lastBookingId == 0 || _refreshing) return;
    _refreshing = true;
    notifyListeners();
    try {
      final res = await BookingDetailsService.fetch(token: _lastToken, bookingId: _lastBookingId);
      _page = res;
      _error = null;
    } catch (e) {
      if (e is AuthRequiredException) {
        _authRequired = true;
        _error = e.message;
      } else {
        // keep old page, just note error
        _error = e.toString();
      }
    } finally {
      _refreshing = false;
      notifyListeners();
    }
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }
}
