import 'package:evento_app/features/support/data/models/support_ticket_details_models.dart';
import 'package:evento_app/network_services/core/http_errors.dart';
import 'package:evento_app/network_services/core/support_ticket_details_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class SupportTicketDetailsProvider extends ChangeNotifier {
  bool _loading = false;
  String? _error;
  String _pageTitle = 'Ticket Details';
  SupportTicketDetails? _details;
  bool _initialized = false;
  String _lastToken = '';
  int _lastTicketId = 0;
  bool _authRequired = false;
  bool _sending = false;
  // UI state managed by provider
  final TextEditingController replyController = TextEditingController();
  PlatformFile? _attachment;

  bool get loading => _loading;
  String? get error => _error;
  String get pageTitle => _pageTitle;
  SupportTicketDetails? get details => _details;
  bool get initialized => _initialized;
  bool get authRequired => _authRequired;
  bool get sending => _sending;
  PlatformFile? get attachment => _attachment;
  String get lastToken => _lastToken;
  int get lastTicketId => _lastTicketId;

  Future<void> ensureInitialized({
    required String token,
    required int ticketId,
  }) async {
    if (!_initialized || token != _lastToken || ticketId != _lastTicketId) {
      await init(token: token, ticketId: ticketId);
    }
  }

  Future<void> init({required String token, required int ticketId}) async {
    if (_loading) return; // prevent concurrent fetches
    _setLoading(true);
    _error = null;
    _authRequired = false;
    _lastToken = token;
    _lastTicketId = ticketId;
    try {
      final res = await SupportTicketDetailsService.fetch(
        token: token,
        ticketId: ticketId,
      );
      _pageTitle = (res.pageTitle).isNotEmpty ? res.pageTitle : _pageTitle;
      _details = res.ticket;
      _initialized = true;
    } catch (e) {
      _details = null;
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

  Future<Map<String, dynamic>> reply({
    required String token,
    required int ticketId,
    String? message,
    PlatformFile? attachment,
  }) async {
    _sending = true;
    notifyListeners();
    try {
      final res = await SupportTicketDetailsService.reply(
        token: token,
        ticketId: ticketId,
        message: message,
        attachmentPath: attachment?.path,
        attachmentFileName: attachment?.name,
        attachmentBytes: attachment?.bytes,
      );
      return res;
    } finally {
      _sending = false;
      notifyListeners();
    }
  }

  void setAttachment(PlatformFile? file) {
    _attachment = file;
    notifyListeners();
  }

  void clearAttachment() {
    _attachment = null;
    notifyListeners();
  }

  void clearReplyText() {
    try {
      replyController.clear();
    } catch (_) {}
  }

  Future<void> refresh(String token) async {
    if (_lastTicketId != 0) {
      await init(token: token, ticketId: _lastTicketId);
    }
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  @override
  void dispose() {
    try {
      replyController.dispose();
    } catch (_) {}
    super.dispose();
  }
}
