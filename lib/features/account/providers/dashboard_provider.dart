import 'package:evento_app/features/account/data/models/dashboard_models.dart';
import 'package:evento_app/network_services/core/dashboard_service.dart';
import 'package:evento_app/network_services/core/http_errors.dart';
import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;

class DashboardProvider extends ChangeNotifier {
  static const String _tag = 'DashboardProvider';

  bool _loading = false;
  String? _error;
  DashboardResponseModel? _data;
  bool _authRequired = false;
  bool _initialized = false;
  String _lastToken = '';

  bool get loading => _loading;
  String? get error => _error;
  DashboardResponseModel? get data => _data;
  bool get authRequired => _authRequired;
  bool get initialized => _initialized;
  String get lastToken => _lastToken;

  void clearAuthRequired() {
    developer.log(
      'Clearing auth required flag (was: $_authRequired)',
      name: _tag,
      time: DateTime.now(),
    );

    if (_authRequired) {
      _authRequired = false;
      notifyListeners();
    }
  }

  Future<void> ensureInitialized(String token) async {
    final tokenChanged = token != _lastToken;
    developer.log(
      'ensureInitialized called - initialized: $_initialized, tokenChanged: $tokenChanged',
      name: _tag,
      time: DateTime.now(),
    );

    if (!_initialized || tokenChanged) {
      developer.log(
        'Initialization required',
        name: _tag,
        time: DateTime.now(),
      );
      await init(token);
    } else {
      developer.log(
        'Already initialized with same token, skipping',
        name: _tag,
        time: DateTime.now(),
      );
    }
  }

  Future<void> init(String token) async {
    if (_loading) {
      developer.log(
        'Init called while already loading, skipping',
        name: _tag,
        level: 900, // WARNING level
      );
      return;
    }

    developer.log(
      'Initializing dashboard - tokenLength: ${token.length}',
      name: _tag,
      time: DateTime.now(),
    );

    _setLoading(true);
    _error = null;
    _authRequired = false;
    _lastToken = token;

    try {
      developer.log(
        'Fetching dashboard data from service',
        name: _tag,
        time: DateTime.now(),
      );

      _data = await DashboardService.fetch(token);
      _initialized = true;

      developer.log(
        'Dashboard data fetched successfully - pageTitle: ${_data?.pageTitle}, bookingsCount: ${_data?.bookings.length ?? 0}, hasAuthUser: ${_data?.authUser != null}',
        name: _tag,
        time: DateTime.now(),
      );

    } catch (e, stackTrace) {
      _data = null;
      _initialized = true;

      if (e is AuthRequiredException) {
        _authRequired = true;
        _error = e.message;
        developer.log(
          'Authentication required',
          name: _tag,
          error: e,
          level: 900, // WARNING level
        );
      } else {
        _error = e.toString();
        developer.log(
          'Dashboard initialization failed',
          name: _tag,
          error: e,
          stackTrace: stackTrace,
          level: 1000, // ERROR level
        );
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refresh(String token) async {
    developer.log(
      'Refresh called - tokenLength: ${token.length}',
      name: _tag,
      time: DateTime.now(),
    );
    await init(token);
  }

  void _setLoading(bool v) {
    developer.log(
      'Loading state changed: $_loading -> $v',
      name: _tag,
      time: DateTime.now(),
    );
    _loading = v;
    notifyListeners();
  }
}
