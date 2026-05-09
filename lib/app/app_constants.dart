import 'package:evento_app/app/urls.dart';

/// Central app-wide constants and aliases for convenience.
///
/// Provides `pgwBaseUrl` used by PGW helper services.
class AppConstants {
  AppConstants._();
}

/// Base URL for payment-gateway (PGW) helper endpoints hosted on server.
const String pgwBaseUrl = AppUrls.pgwBaseUrl;

