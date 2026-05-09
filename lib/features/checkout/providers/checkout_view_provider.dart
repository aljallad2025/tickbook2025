import 'dart:async';
import 'dart:convert';
import 'package:evento_app/network_services/core/http_headers.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
import '../ui/widgets/web_checkout_config.dart';
import '../ui/widgets/web_checkout_utils.dart';

class CheckoutWebViewProvider extends ChangeNotifier {
  final WebCheckoutConfig config;
  final void Function(bool) onPop;

  late final WebViewController controller;

  bool loading = true;
  bool verifying = false;
  bool timedOut = false;
  bool cancelled = false;

  Timer? _pollTimer;
  int attempts = 0;

  String get url => config.url;
  String get title => config.title;
  String? get finishScheme => config.finishScheme;
  String? get cancelScheme => config.cancelScheme;
  String? get invoiceId => config.invoiceId;
  String? get statusUrlTemplate => config.statusUrlTemplate;
  int get statusPollIntervalSeconds => config.statusPollIntervalSeconds;
  int get statusPollMaxAttempts => config.statusPollMaxAttempts;
  List<String> get successUrlContains => config.successUrlContains;

  CheckoutWebViewProvider(this.config, this.onPop) {
    _initController();
  }

  void _initController() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (req) {
            final uri = req.url;
            final fs = finishScheme;
            if (fs != null && uri.startsWith(fs)) {
              if (statusUrlTemplate != null && invoiceId != null) {
                _tryImmediateVerifyAndMaybePop();
                return NavigationDecision.prevent;
              }
              onPop(true);
              return NavigationDecision.prevent;
            }
            final cs = cancelScheme;
            if (cs != null && uri.startsWith(cs)) {
              cancelled = true;
              verifying = false;
              notifyListeners();
              return NavigationDecision.prevent;
            }
            if (successUrlContains.isNotEmpty) {
              final lower = uri.toLowerCase();
              for (final frag in successUrlContains) {
                if (lower.contains(frag)) {
                // Logging removed.
                  if (statusUrlTemplate != null && invoiceId != null) {
                    _tryImmediateVerifyAndMaybePop();
                    return NavigationDecision.prevent;
                  }
                  onPop(true);
                  return NavigationDecision.prevent;
                }
              }
            }
            return NavigationDecision.navigate;
          },
          onPageStarted: (_) {
            loading = true;
            notifyListeners();
          },
          onPageFinished: (_) {
            loading = false;
            if (statusUrlTemplate != null && invoiceId != null) {
              verifying = true;
            }
            notifyListeners();
            _maybeStartPolling();
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  void _maybeStartPolling() {
    if (_pollTimer != null) return;
    if (invoiceId == null || statusUrlTemplate == null) return;
    if (statusPollIntervalSeconds <= 0 || statusPollMaxAttempts <= 0) return;
    final pollUrl = WebCheckoutUtils.buildStatusUrl(
      statusUrlTemplate!,
      invoiceId!,
    );
  // Logging removed.
    _pollTimer = Timer.periodic(Duration(seconds: statusPollIntervalSeconds), (
      timer,
    ) async {
      attempts++;
      if (attempts > statusPollMaxAttempts) {
  // Logging removed.
        timer.cancel();
        verifying = false;
        timedOut = true;
        notifyListeners();
        return;
      }
      try {
        final res = await http.get(
          Uri.parse(pollUrl),
          headers: HttpHeadersHelper.base(),
        );
        if (res.statusCode < 300) {
          final body = res.body.trim();
          dynamic decoded;
          try {
            decoded = jsonDecode(body);
          } catch (_) {
            decoded = body;
          }
          final success = WebCheckoutUtils.evaluatePaid(decoded);
          // Logging removed.
          if (success) {
            timer.cancel();
            verifying = false;
            notifyListeners();
            onPop(true);
            return;
          }
        } else {
          if (res.statusCode != 400 && res.statusCode != 404) {
            // Logging removed.
          }
        }
      } catch (e) {
  // Logging removed.
      }
    });
  }

  Future<void> _tryImmediateVerifyAndMaybePop() async {
    if (invoiceId == null || statusUrlTemplate == null) return;
    verifying = true;
    notifyListeners();
    final ok = await _checkStatusOnce();
    if (ok) {
      verifying = false;
      notifyListeners();
      onPop(true);
    } else {
      _maybeStartPolling();
    }
  }

  Future<bool> _checkStatusOnce() async {
    if (invoiceId == null || statusUrlTemplate == null) return false;
    final url = WebCheckoutUtils.buildStatusUrl(statusUrlTemplate!, invoiceId!);
    try {
      final res = await http.get(
        Uri.parse(url),
        headers: HttpHeadersHelper.base(),
      );
      if (res.statusCode < 300) {
        final body = res.body.trim();
        dynamic decoded;
        try {
          decoded = jsonDecode(body);
        } catch (_) {
          decoded = body;
        }
        return WebCheckoutUtils.evaluatePaid(decoded);
      }
    } catch (e) {
  // Logging removed.
    }
    return false;
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}
