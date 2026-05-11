import 'dart:convert';
import 'dart:developer' as developer;
import 'package:evento_app/network_services/core/auth_services.dart';
import 'package:evento_app/features/account/data/models/customer_model.dart';
import 'package:evento_app/network_services/core/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:evento_app/features/auth/ui/screens/login_screen.dart';
import 'package:evento_app/features/common/ui/widgets/custom_snack_bar_widget.dart';

class AuthProvider extends ChangeNotifier {
  static const String _tag = 'AuthProvider';

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;
  String? _token;
  Map<String, dynamic>? _customer;
  RouteSettings? _pendingRedirect;
  bool _navigatingToLogin = false;

  bool get obscurePassword => _obscurePassword;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get token => _token;
  Map<String, dynamic>? get customer => _customer;

  CustomerModel? get customerModel =>
      _customer == null ? null : CustomerModel.fromJson(_customer!);
  RouteSettings? get pendingRedirect => _pendingRedirect;
  bool get navigatingToLogin => _navigatingToLogin;

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    developer.log('Password visibility toggled: ${_obscurePassword ? "hidden" : "visible"}', name: _tag);
    notifyListeners();
  }

  Future<void> tryLoadSession() async {
    developer.log('Attempting to load session from SharedPreferences', name: _tag);
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('auth_token');
      final customerJson = prefs.getString('auth_customer');

      if (_token != null) {
        developer.log('Token loaded: ${_token!.substring(0, _token!.length > 20 ? 20 : _token!.length)}...', name: _tag);
      } else {
        developer.log('No token found in SharedPreferences', name: _tag);
      }

      if (customerJson != null) {
        _customer = json.decode(customerJson) as Map<String, dynamic>;
        developer.log('Customer data loaded: ${_customer?['username'] ?? _customer?['email'] ?? "unknown"}', name: _tag);
      } else {
        developer.log('No customer data found in SharedPreferences', name: _tag);
      }

      notifyListeners();
    } catch (e, stackTrace) {
      developer.log('Error loading session: $e', name: _tag, error: e, stackTrace: stackTrace);
    }
  }

  Future<bool> login() async {
    final usernameOrEmail = emailController.text.trim();
    final password = passwordController.text;

    developer.log('Login attempt started for user: $usernameOrEmail', name: _tag);

    if (usernameOrEmail.isEmpty || password.isEmpty) {
      _errorMessage = 'Please enter username and password';
      developer.log('Login validation failed: empty credentials', name: _tag);
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _errorMessage = null;

    try {
      developer.log('Calling AuthServices.login...', name: _tag);
      final res = await AuthServices.login(
        username: usernameOrEmail,
        password: password,
      );

      developer.log('Login response received: ${res.keys.toList()}', name: _tag);

      final token = res['token']?.toString();
      final customer = res['customer'] as Map<String, dynamic>?;

      if (token == null || customer == null) {
        _errorMessage = 'Invalid response from server';
        developer.log('Login failed: invalid response structure (token: ${token != null}, customer: ${customer != null})', name: _tag);
        _setLoading(false);
        return false;
      }

      _token = token;
      _customer = customer;

      developer.log('Login successful for user: ${customer['username'] ?? customer['email'] ?? "unknown"}', name: _tag);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      await prefs.setString('auth_customer', json.encode(customer));

      developer.log('Session persisted to SharedPreferences', name: _tag);

      _navigatingToLogin = false;
      _setLoading(false);
      return true;
    } catch (e, stackTrace) {
      _errorMessage = 'Login failed';
      developer.log('Login exception: $e', name: _tag, error: e, stackTrace: stackTrace);
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    developer.log('Logout initiated', name: _tag);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('auth_customer');

      _token = null;
      _customer = null;

      developer.log('Logout completed - session cleared', name: _tag);
      notifyListeners();
    } catch (e, stackTrace) {
      developer.log('Error during logout: $e', name: _tag, error: e, stackTrace: stackTrace);
    }
  }

  void setPendingRedirect(RouteSettings? settings) {
    developer.log('Pending redirect set: ${settings?.name ?? "null"}', name: _tag);
    _pendingRedirect = settings;
  }

  void clearPendingRedirect() {
    developer.log('Pending redirect cleared (was: ${_pendingRedirect?.name ?? "null"})', name: _tag);
    _pendingRedirect = null;
  }

  Future<void> onAuthExpired({RouteSettings? from, String? message}) async {
    developer.log('Auth expired called - from: ${from?.name ?? "null"}, message: $message', name: _tag);

    await logout();
    setPendingRedirect(from);

    final nav = NavigationService.navigator;
    if (nav == null) {
      developer.log('NavigationService.navigator is null, cannot navigate to login', name: _tag);
      return;
    }

    if (_navigatingToLogin) {
      developer.log('Already navigating to login, skipping duplicate navigation', name: _tag);
      return;
    }

    if (message != null) {
      final ctx = nav.context;
      if (ctx.mounted) {
        developer.log('Showing auth expired message: $message', name: _tag);
        CustomSnackBar.show(ctx, message);
      }
    }

    _navigatingToLogin = true;
    developer.log('Navigating to LoginScreen', name: _tag);

    NavigationService.pushAnimated(
      const LoginScreen(redirectToHome: false),
    ).whenComplete(() {
      _navigatingToLogin = false;
      developer.log('Login navigation completed', name: _tag);
    });
  }

  Future<void> setCustomer(Map<String, dynamic>? customer) async {
    developer.log('Setting customer: ${customer != null ? (customer['username'] ?? customer['email'] ?? "unknown") : "null"}', name: _tag);

    _customer = customer;
    final prefs = await SharedPreferences.getInstance();

    if (customer == null) {
      await prefs.remove('auth_customer');
      developer.log('Customer data removed from SharedPreferences', name: _tag);
    } else {
      await prefs.setString('auth_customer', json.encode(customer));
      developer.log('Customer data saved to SharedPreferences', name: _tag);
    }

    notifyListeners();
  }

  Future<void> setCustomerModel(CustomerModel? model) async {
    developer.log('Setting customer model: ${model != null ? "present" : "null"}', name: _tag);
    if (model == null) return await setCustomer(null);
    await setCustomer(model.toJson());
  }

  Future<bool> signup() async {
    final f = firstNameController.text.trim();
    final l = lastNameController.text.trim();
    final u = usernameController.text.trim();
    final e = emailController.text.trim();
    final p = passwordController.text;
    final pc = confirmPasswordController.text;

    developer.log('Signup attempt started - username: $u, email: $e', name: _tag);

    if ([f, u, e, p, pc].any((v) => v.isEmpty)) {
      _errorMessage = 'Please fill all required fields';
      developer.log('Signup validation failed: empty fields', name: _tag);
      notifyListeners();
      return false;
    }

    if (p != pc) {
      _errorMessage = 'Passwords do not match';
      developer.log('Signup validation failed: password mismatch', name: _tag);
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _errorMessage = null;

    try {
      developer.log('Calling AuthServices.signup...', name: _tag);
      final res = await AuthServices.signup(
        firstName: f,
        lastName: l,
        username: u,
        email: e,
        password: p,
        confirmPassword: pc,
      );

      developer.log('Signup response received: $res', name: _tag);

      final status = (res['status'] ?? '').toString().toLowerCase();

      if (status != 'success') {
        String? msg;
        if (res['message'] is String) msg = res['message'];
        if (msg == null && res['errors'] is Map) {
          final errors = res['errors'] as Map;
          if (errors.isNotEmpty) {
            final firstVal = errors.values.first;
            if (firstVal is List && firstVal.isNotEmpty) {
              msg = firstVal.first.toString();
            } else if (firstVal is String) {
              msg = firstVal;
            }
          }
        }
        _errorMessage = msg ?? res.toString();
        developer.log('Signup failed - status: $status, message: $_errorMessage', name: _tag);
        _setLoading(false);
        return false;
      }
      developer.log('Signup successful for user: $u', name: _tag);
      _setLoading(false);
      return true;
    } catch (e, stackTrace) {
      _errorMessage = 'Signup failed';
      developer.log('Signup exception: $e', name: _tag, error: e, stackTrace: stackTrace);
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool v) {
    _isLoading = v;
    developer.log('Loading state changed: $v', name: _tag);
    notifyListeners();
  }
}

