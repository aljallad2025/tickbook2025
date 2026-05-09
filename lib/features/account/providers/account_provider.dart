import 'package:evento_app/features/account/data/models/dashboard_models.dart';
import 'package:evento_app/network_services/core/dashboard_service.dart';
import 'package:evento_app/network_services/core/http_errors.dart';
import 'package:flutter/foundation.dart';

class AccountProvider extends ChangeNotifier {
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
    if (_authRequired) {
      _authRequired = false;
      notifyListeners();
    }
  }

  Future<void> ensureInitialized(String token) async {
    if (!_initialized || token != _lastToken) {
      await init(token);
    }
  }

  Future<void> init(String token) async {
    _setLoading(true);
    _error = null;
    _authRequired = false;
    _lastToken = token;
    try {
      _data = await DashboardService.fetch(token);
      _initialized = true;
    } catch (e) {
      _data = null;
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
