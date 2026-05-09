import 'package:evento_app/features/events/data/models/event_details_models.dart';
import 'package:flutter/foundation.dart';

class TicketSeatSelection {
  final List<int> seatIds;
  final List<String> seatNames;
  final List<Map<String, dynamic>> seatDetails;
  final double total;
  const TicketSeatSelection({
    required this.seatIds,
    required this.seatNames,
    required this.seatDetails,
    required this.total,
  });
}

class TicketsProvider extends ChangeNotifier {
  final Map<String, int> _qty = <String, int>{};
  final Map<String, TicketSeatSelection> _seatSelections =
      <String, TicketSeatSelection>{};

  bool _verifying = false;
  String? _verifyError;

  Map<String, int> get qty => _qty;
  Map<String, TicketSeatSelection> get seatSelections => _seatSelections;
  bool get verifying => _verifying;
  String? get verifyError => _verifyError;

  bool get hasSelection {
    final hasQty = _qty.values.any((v) => v > 0);
    final hasSeats = _seatSelections.values.any((s) => s.seatIds.isNotEmpty);
    return hasQty || hasSeats;
  }

  void setVerifyState({required bool verifying, String? error}) {
    _verifying = verifying;
    _verifyError = error;
    notifyListeners();
  }

  void clearVerifyError() {
    _verifyError = null;
    notifyListeners();
  }

  void inc(String key, {int step = 1, int? max}) {
    final current = _qty[key] ?? 0;
    final next = current + step;
    if (max != null && next > max) return;
    _qty[key] = next;
    notifyListeners();
  }

  void dec(String key, {int step = 1}) {
    final current = _qty[key] ?? 0;
    final next = current - step;
    _qty[key] = next <= 0 ? 0 : next;
    notifyListeners();
  }

  void setSeatSelection(String key, TicketSeatSelection sel) {
    _seatSelections[key] = sel;
    notifyListeners();
  }

  void clearSeatSelection(String key) {
    _seatSelections.remove(key);
    notifyListeners();
  }

  void clearAll() {
    _qty.clear();
    _seatSelections.clear();
    _verifying = false;
    _verifyError = null;
    notifyListeners();
  }

  double computeTotal(EventDetailsPageModel? details) {
    if (details == null) return 0.0;
    double total = 0.0;
    // Add totals from seat selections
    for (final sel in _seatSelections.values) {
      total += sel.total;
    }
    // Add totals from non-seat quantity map
    for (final entry in _qty.entries) {
      final parts = entry.key.split('|');
      if (parts.length < 3) continue;
      final ticketIdx = int.tryParse(parts[1]);
      final optIdx = int.tryParse(parts[2]);
      if (ticketIdx == null ||
          ticketIdx < 0 ||
          ticketIdx >= details.tickets.length) {
        continue;
      }
      final t = details.tickets[ticketIdx];
      final isVariation = parts[0] == 'var';
      final price = isVariation
          ? (optIdx != null && optIdx >= 0 && optIdx < t.variations.length
                ? t.variations[optIdx].price
                : 0.0)
          : t.price;
      total += price * (entry.value);
    }
    return total;
  }
}
