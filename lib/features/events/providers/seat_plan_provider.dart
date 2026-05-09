import 'package:evento_app/features/events/data/models/seat_map_models.dart';
import 'package:evento_app/network_services/core/seat_map_service.dart';
import 'package:flutter/foundation.dart';

class SeatPlanProvider extends ChangeNotifier {
  int _eventId;
  int _ticketId;
  int _slotUniqueId;

  SeatPlanProvider({
    int eventId = 0,
    int ticketId = 0,
    int slotUniqueId = 0,
  })  : _eventId = eventId,
        _ticketId = ticketId,
        _slotUniqueId = slotUniqueId;

  int get eventId => _eventId;
  int get ticketId => _ticketId;
  int get slotUniqueId => _slotUniqueId;

  /// Configure context (if changed) and optionally fetch immediately.
  Future<void> configure({
    required int eventId,
    required int ticketId,
    required int slotUniqueId,
    bool force = false,
    bool autoFetch = true,
    bool clearPrevious = true,
  }) async {
    final changed = force ||
        eventId != _eventId ||
        ticketId != _ticketId ||
        slotUniqueId != _slotUniqueId;
    if (!changed) return;
    _eventId = eventId;
    _ticketId = ticketId;
    _slotUniqueId = slotUniqueId;
    if (clearPrevious) {
      _response = null;
      _selectedSeatIds.clear();
      _seatNames.clear();
      _seatPrice.clear();
    }
    if (autoFetch) {
      await _fetch();
    } else {
      notifyListeners();
    }
  }

  bool _loading = false;
  String? _error;
  SeatMapResponse? _response;

  final Set<int> _selectedSeatIds = <int>{};
  final Map<int, String> _seatNames = <int, String>{};
  final Map<int, double> _seatPrice = <int, double>{};

  bool get loading => _loading;
  String? get error => _error;
  SeatMapResponse? get response => _response;
  Set<int> get selectedSeatIds => _selectedSeatIds;
  Map<int, String> get seatNames => _seatNames;
  Map<int, double> get seatPrice => _seatPrice;

  double get totalPrice =>
      _selectedSeatIds.fold<double>(0, (p, id) => p + (_seatPrice[id] ?? 0.0));

  Future<void> init() async {
    if (_eventId <= 0 || _ticketId <= 0 || _slotUniqueId <= 0) {
      return; // Not enough context yet; will fetch after configure.
    }
    await _fetch();
  }

  Future<void> reload({bool keepSelection = false}) async {
    await _fetch();
    if (!keepSelection) {
      _selectedSeatIds.clear();
      _seatNames.clear();
      notifyListeners();
    }
  }

  Future<void> _fetch() async {
    _setLoading(true);
    _error = null;
    try {
      if (_eventId <= 0 || _ticketId <= 0 || _slotUniqueId <= 0) {
        _response = null;
        _error = 'Seat plan context incomplete';
        return;
      }
      final resp = await SeatMapService.fetch(
        eventId: _eventId,
        ticketId: _ticketId,
        slotUniqueId: _slotUniqueId,
      );
      _response = resp;
      _seatPrice.clear();
      if (resp.slots.isNotEmpty) {
        for (final slot in resp.slots) {
          for (final seat in slot.seats) {
            // Prefer payable price if provided (>0), else fallback to base price
            final effective = seat.payablePrice > 0 ? seat.payablePrice : seat.price;
            _seatPrice[seat.id] = effective;
          }
        }
      }
    } catch (e) {
      _error = e.toString();
      _response = null;
    } finally {
      _setLoading(false);
    }
  }

  void toggleSeat(SeatItem seat) {
    if (seat.isBooked == 1 || seat.isDeactive == 1) return;
    // Logging removed for production
    if (_selectedSeatIds.contains(seat.id)) {
      _selectedSeatIds.remove(seat.id);
      _seatNames.remove(seat.id);
    } else {
      _selectedSeatIds.add(seat.id);
      _seatNames[seat.id] = seat.name;
      final effective = seat.payablePrice > 0 ? seat.payablePrice : seat.price;
      _seatPrice[seat.id] = effective;
    }
    notifyListeners();
  }

  void selectAllAvailableInSlot(SeatSlot slot) {
    final available = slot.seats
        .where((s) => s.isBooked == 0 && s.isDeactive == 0)
        .toList(growable: false);
    for (final seat in available) {
      _selectedSeatIds.add(seat.id);
      _seatNames[seat.id] = seat.name;
      final effective = seat.payablePrice > 0 ? seat.payablePrice : seat.price;
      _seatPrice[seat.id] = effective;
    }
    notifyListeners();
  }

  void deselectAllInSlot(SeatSlot slot) {
    for (final seat in slot.seats) {
      _selectedSeatIds.remove(seat.id);
      _seatNames.remove(seat.id);
      // keep price map for others; removing is optional
    }
    notifyListeners();
  }

  bool hasAnySelectedInSlot(SeatSlot slot) {
    for (final seat in slot.seats) {
      if (_selectedSeatIds.contains(seat.id)) return true;
    }
    return false;
  }

  void clearSelection() {
    _selectedSeatIds.clear();
    _seatNames.clear();
    notifyListeners();
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }
}
