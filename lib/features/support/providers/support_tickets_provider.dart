import 'package:evento_app/features/support/data/models/support_ticket_models.dart';
import 'package:evento_app/network_services/core/http_errors.dart';
import 'package:evento_app/network_services/core/support_ticket_store_service.dart';
import 'package:evento_app/network_services/core/support_tickets_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class SupportTicketsProvider extends ChangeNotifier {
  bool _loading = false;
  String? _error;
  String _pageTitle = 'Support Tickets';
  List<SupportTicket> _tickets = const [];
  String _lastToken = '';
  bool _initialized = false;
  bool _authRequired = false;
  String _query = '';
  final TextEditingController searchController = TextEditingController();

  bool get loading => _loading;
  String? get error => _error;
  String get pageTitle => _pageTitle;
  String get query => _query;
  List<SupportTicket> get tickets {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return List.unmodifiable(_tickets);
    bool contains(String? s) => (s ?? '').toLowerCase().contains(q);
    return _tickets
        .where((t) {
          if (contains(t.ticketNumber)) return true;
          if (contains(t.subject)) return true;
          if (contains(t.email)) return true;
          if (contains(t.description)) return true;
          if (contains(t.lastMessage)) return true;
          if (contains(t.userType)) return true;
          if (contains(t.createdAt)) return true;
          if (contains(t.updatedAt)) return true;
          if (t.status.toString().contains(q)) return true;
          if ((t.userId?.toString() ?? '').contains(q)) return true;
          if ((t.adminId?.toString() ?? '').contains(q)) return true;
          return false;
        })
        .toList(growable: false);
  }

  String get lastToken => _lastToken;
  bool get initialized => _initialized;
  bool get authRequired => _authRequired;

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
      final res = await SupportTicketsService.fetch(token: token);
      _pageTitle = (res.pageTitle).isNotEmpty ? res.pageTitle : _pageTitle;
      _tickets = res.tickets;
      _initialized = true;
    } catch (e) {
      _tickets = const [];
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

  Future<Map<String, dynamic>> createTicket({
    required String token,
    required String subject,
    required String email,
    required String description,
    PlatformFile? attachment,
  }) async {
    final res = await SupportTicketStoreService.create(
      token: token,
      subject: subject,
      email: email,
      description: description,
      attachmentPath: attachment?.path,
      attachmentFileName: attachment?.name,
      attachmentBytes: attachment?.bytes,
    );
    return res;
  }

  Future<void> refresh(String token) async {
    await init(token);
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
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
