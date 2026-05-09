import 'package:evento_app/features/categories/models/category_model.dart';
import 'package:evento_app/features/events/providers/events_provider.dart';
import 'package:evento_app/features/events/ui/widgets/events/filter_dropdowns.dart';
import 'package:evento_app/features/events/ui/widgets/events/location_text_fields.dart';
import 'package:evento_app/features/events/ui/widgets/events/price_n_date_picker.dart';
import 'package:evento_app/features/home/providers/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:evento_app/features/common/ui/widgets/custom_snack_bar_widget.dart';
import 'package:evento_app/app/app_colors.dart';
import 'package:evento_app/app/keys.dart';
import 'package:evento_app/network_services/core/google_geocode_service.dart';
import 'package:evento_app/network_services/core/basic_service.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:evento_app/features/events/data/models/location_models.dart';

class EventsFiltersSheet extends StatefulWidget {
  final VoidCallback? onApplied;
  const EventsFiltersSheet({super.key, this.onApplied});

  @override
  State<EventsFiltersSheet> createState() => _EventsFiltersSheetState();
}

class _EventsFiltersSheetState extends State<EventsFiltersSheet> {
  final TextEditingController _location = TextEditingController();
  final TextEditingController _country = TextEditingController();
  final TextEditingController _state = TextEditingController();
  final TextEditingController _city = TextEditingController();
  CountryItem? _selectedCountry;
  StateItem? _selectedState;
  CityItem? _selectedCity;
  String? _eventType;
  String? _from;
  String? _to;
  CategoryModel? _selectedCategory;
  double? _priceStart;
  double? _priceEnd;
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    _initializeFilters();
  }

  void _initializeFilters() {
    final p = context.read<EventsProvider>();
    _country.text = p.country ?? '';
    _state.text = p.stateName ?? '';
    _city.text = p.city ?? '';
    // Kick off loading of location options (countries/states/cities)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<EventsProvider>().ensureFilterOptions();
    });
    // Try to preselect from provider strings using slug or name
    if (p.countries.isNotEmpty) {
      _selectedCountry = p.countries.firstWhere(
        (c) =>
            c.slug.toLowerCase() == (p.country ?? '').toLowerCase() ||
            c.name.toLowerCase() == (p.country ?? '').toLowerCase(),
        orElse: () => CountryItem(id: 0, name: '', slug: ''),
      );
      if (_selectedCountry?.id == 0) _selectedCountry = null;
    }
    if (p.states.isNotEmpty) {
      _selectedState = p.states.firstWhere(
        (s) =>
            s.slug.toLowerCase() == (p.stateName ?? '').toLowerCase() ||
            s.name.toLowerCase() == (p.stateName ?? '').toLowerCase(),
        orElse: () => StateItem(id: 0, countryId: 0, name: '', slug: ''),
      );
      if (_selectedState?.id == 0) _selectedState = null;
    }
    if (p.cities.isNotEmpty) {
      _selectedCity = p.cities.firstWhere(
        (c) =>
            c.slug.toLowerCase() == (p.city ?? '').toLowerCase() ||
            c.name.toLowerCase() == (p.city ?? '').toLowerCase(),
        orElse: () =>
            CityItem(id: 0, countryId: 0, stateId: 0, name: '', slug: ''),
      );
      if (_selectedCity?.id == 0) _selectedCity = null;
    }
    _eventType = p.eventType;
    _from = p.fromDate;
    _to = p.toDate;

    final minB = p.priceMinBound;
    final maxB = p.priceMaxBound;
    if ((p.priceMinSelected ?? p.priceMaxSelected) != null) {
      _priceStart = p.priceMinSelected ?? minB;
      _priceEnd = p.priceMaxSelected ?? maxB;
    }

    final hp = context.read<HomeProvider>();
    final cats = hp.data?.categories ?? const <CategoryModel>[];
    if (p.categoryId != null) {
      final byId = cats.where((c) => c.id == p.categoryId).toList();
      if (byId.isNotEmpty) _selectedCategory = byId.first;
    } else if ((p.categoryName ?? '').isNotEmpty) {
      final byName = cats
          .where((c) => c.name.toLowerCase() == p.categoryName!.toLowerCase())
          .toList();
      if (byName.isNotEmpty) _selectedCategory = byName.first;
    }
  }

  Future<void> _pickDate(BuildContext context, {required bool isFrom}) async {
    DateTime initial = DateTime.now();
    final current = (isFrom ? _from : _to);
    if (current != null) {
      final parsed = DateTime.tryParse(current);
      if (parsed != null) initial = parsed;
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      final s = _fmtDate(picked);
      setState(() {
        if (isFrom) {
          _from = s;
        } else {
          _to = s;
        }
      });
    }
  }

  String _fmtDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _handleApplyFilters(EventsProvider p) async {
    FocusScope.of(context).unfocus();

    if (_selectedCategory != null) {
      p.setCategoryFilter(
        id: _selectedCategory!.id,
        name: _selectedCategory!.name,
        slug: _selectedCategory!.slug,
      );
    } else {
      p.clearCategoryFilter();
    }

    p.setAdvancedFilters(
      country: _selectedCountry?.slug.isNotEmpty == true
          ? _selectedCountry!.slug
          : (_country.text.trim().isEmpty ? null : _country.text.trim()),
      state: _selectedState?.slug.isNotEmpty == true
          ? _selectedState!.slug
          : (_state.text.trim().isEmpty ? null : _state.text.trim()),
      city: _selectedCity?.slug.isNotEmpty == true
          ? _selectedCity!.slug
          : (_city.text.trim().isEmpty ? null : _city.text.trim()),
      eventType: _eventType,
      fromDate: _from,
      toDate: _to,
      minPrice: _priceStart,
      maxPrice: _priceEnd,
    );

    // If user entered a free-form location, try to geocode it using Google
    final locQuery = _location.text.trim();
    if (locQuery.isNotEmpty) {
      try {
        final gKey = await AppKeys.getGoogleMapKey() ?? '';
        final google = GoogleGeocodeService(gKey);
        double? lat;
        double? lon;
        if (google.enabled) {
          final g = await google.forward(locQuery);
          if (g != null) {
            lat = g.lat;
            lon = g.lon;
          }
        }
        if (lat == null || lon == null) {
          // Fallback to platform geocoding
          final list = await locationFromAddress(locQuery);
          if (list.isNotEmpty) {
            lat = list.first.latitude;
            lon = list.first.longitude;
          }
        }
        if (lat != null && lon != null) {
          // Clear country/state/city filters to avoid mixing with radius
          _country.clear();
          _state.clear();
          _city.clear();
          p.setAdvancedFilters(country: null, state: null, city: null);
          double radius = 100.0;
          try {
            radius = await BasicService.getGoogleMapRadiusKm(allowRemote: true);
          } catch (_) {}
          p.setGeoRadius(lat: lat, lon: lon, radiusKm: radius);
        }
      } catch (_) {
        // Ignore geocode failure; keep non-geo filters
      }
    }
    if (!mounted) return;
    Navigator.of(context).pop();
    if (widget.onApplied != null) widget.onApplied!();
  }

  void _handleResetFilters(EventsProvider p) {
    FocusScope.of(context).unfocus();
    p.clearCategoryFilter();
    p.clearQuery();
    p.clearAdvancedFilters();
    p.clearAllFilters();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final hp = context.read<HomeProvider>();
    final categories = hp.data?.categories ?? const <CategoryModel>[];
    final p = context.watch<EventsProvider>();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filters'.tr,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Category Dropdown/TextField
              CategoryDropdown(
                selectedCategory: _selectedCategory,
                categories: categories,
                onChanged: (v) => setState(() => _selectedCategory = v),
              ),
              const SizedBox(height: 8),

              // Event Type Dropdown
              // EventTypeDropdown(
              //   eventType: _eventType,
              //   onChanged: (v) => setState(() => _eventType = v),
              // ),
              // const SizedBox(height: 8),

              // // Location Search (current position)
              // LocationTextField(
              //   controller: _location,
              //   labelText: 'Location',
              //   onLocate: _handleLocate,
              //   locating: _locating,
              // ),
              // const SizedBox(height: 8),

              // Country / State / City dropdowns
              // _CountryDropdown(
              //   selected: _selectedCountry,
              //   onChanged: (v) => setState(() {
              //     // Make selection independent: do not force-clear state/city
              //     _selectedCountry = v;
              //   }),
              // ),
              // const SizedBox(height: 8),
              // _StateDropdown(
              //   selectedCountry: _selectedCountry,
              //   selected: _selectedState,
              //   onChanged: (v) => setState(() {
              //     // Keep city selection if user wants independent selection
              //     _selectedState = v;
              //   }),
              // ),
              // const SizedBox(height: 8),
              // _CityDropdown(
              //   selectedCountry: _selectedCountry,
              //   selectedState: _selectedState,
              //   selected: _selectedCity,
              //   onChanged: (v) => setState(() => _selectedCity = v),
              // ),
              // const SizedBox(height: 8),

              // Date Pickers
              DatePickersRow(fromDate: _from, toDate: _to, pickDate: _pickDate),
              const SizedBox(height: 8),

              // Price Range Slider
              PriceRangeSlider(
                provider: p,
                priceStart: _priceStart,
                priceEnd: _priceEnd,
                onChanged: (range) {
                  setState(() {
                    _priceStart = range.start;
                    _priceEnd = range.end;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Action Buttons
              ActionButtonsRow(
                onReset: () => _handleResetFilters(p),
                onApply: () => _handleApplyFilters(p),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _location.dispose();
    _country.dispose();
    _state.dispose();
    _city.dispose();
    super.dispose();
  }

  Future<void> _handleLocate() async {
    if (_locating) return;
    setState(() => _locating = true);
    try {
      final eventsProv = context.read<EventsProvider>();
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        throw Exception('Location services disabled');
      }
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
        if (perm == LocationPermission.denied) {
          throw Exception('Permission denied');
        }
      }
      if (perm == LocationPermission.deniedForever) {
        throw Exception('Permission permanently denied');
      }
      Position? best;
      final stream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
          timeLimit: Duration(seconds: 8),
        ),
      );
      int taken = 0;
      await for (final p in stream) {
        if (!mounted) break;
        if (best == null || p.accuracy < best.accuracy) best = p;
        taken++;
        if (best.accuracy <= 25 || taken >= 5) break;
      }
      final pos =
          best ??
          await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              timeLimit: Duration(seconds: 8),
            ),
          );

      String? formatted;

      final gKey = await AppKeys.getGoogleMapKey() ?? '';
      final google = GoogleGeocodeService(gKey);
      if (google.enabled) {
        final g = await google.reverse(pos.latitude, pos.longitude);
        if (g != null && g.formattedAddress.trim().isNotEmpty) {
          formatted = g.formattedAddress.trim();
        }
      }

      if (formatted == null) {
        final placemarks = await placemarkFromCoordinates(
          pos.latitude,
          pos.longitude,
        );
        if (placemarks.isNotEmpty) {
          final pm = placemarks.first;
          final parts =
              [
                    pm.name,
                    pm.locality ?? pm.subAdministrativeArea,
                    pm.administrativeArea,
                    pm.country,
                  ]
                  .where((e) => (e ?? '').trim().isNotEmpty)
                  .map((e) => e!.trim())
                  .toList();
          if (parts.isNotEmpty) {
            formatted = parts.join(', ');
          }
        }
      }

      if (!mounted) return;
      if (formatted != null) _location.text = formatted;
      _country.clear();
      _state.clear();
      _city.clear();
      eventsProv.setAdvancedFilters(country: null, state: null, city: null);
      double radius = 100.0;
      try {
        radius = await BasicService.getGoogleMapRadiusKm(allowRemote: true);
      } catch (_) {}
      eventsProv.setGeoRadius(
        lat: pos.latitude,
        lon: pos.longitude,
        radiusKm: radius,
      );
      if (widget.onApplied != null) widget.onApplied!();
    } catch (_) {
      if (!mounted) return;
      CustomSnackBar.show(
        context,
        'Unable to fetch location'.tr,
        icon: Icons.location_off,
        iconBgColor: AppColors.snackError,
      );
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }
}

Future<void> openEventsFilterSheet(
  BuildContext context, {
  VoidCallback? onApplied,
}) async {
  FocusScope.of(context).unfocus();
  await showModalBottomSheet(
    backgroundColor: Colors.grey.shade100,
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => EventsFiltersSheet(onApplied: onApplied),
  );
}

class _CountryDropdown extends StatelessWidget {
  final CountryItem? selected;
  final ValueChanged<CountryItem?> onChanged;
  const _CountryDropdown({required this.selected, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    final p = context.watch<EventsProvider>();
    final items = p.countries;
    return DropdownButtonFormField<CountryItem>(
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(12),
      initialValue: selected != null && items.any((e) => e.id == selected!.id)
          ? items.firstWhere((e) => e.id == selected!.id)
          : null,
      items: [
        for (final c in items) DropdownMenuItem(value: c, child: Text(c.name)),
      ],
      decoration: const InputDecoration(labelText: 'Country'),
      onChanged: p.filtersLoading ? null : onChanged,
    );
  }
}

class _StateDropdown extends StatelessWidget {
  final CountryItem? selectedCountry;
  final StateItem? selected;
  final ValueChanged<StateItem?> onChanged;
  const _StateDropdown({
    required this.selectedCountry,
    required this.selected,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) {
    final p = context.watch<EventsProvider>();
    final states = p.states;
    // Show all states if no country selected; otherwise filter by country
    final filtered = selectedCountry == null
        ? states
        : states.where((s) => s.countryId == selectedCountry!.id).toList();
    return DropdownButtonFormField<StateItem>(
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(12),
      initialValue: (selected != null && filtered.any((e) => e.id == selected!.id))
          ? filtered.firstWhere((e) => e.id == selected!.id)
          : null,
      items: [
        for (final s in filtered)
          DropdownMenuItem(value: s, child: Text(s.name)),
      ],
      decoration: const InputDecoration(labelText: 'State'),
      onChanged: filtered.isEmpty ? null : onChanged,
    );
  }
}

class _CityDropdown extends StatelessWidget {
  final CountryItem? selectedCountry;
  final StateItem? selectedState;
  final CityItem? selected;
  final ValueChanged<CityItem?> onChanged;
  const _CityDropdown({
    required this.selectedCountry,
    required this.selectedState,
    required this.selected,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) {
    final p = context.watch<EventsProvider>();
    final cities = p.cities;
    // If a state is selected, filter by state. Else if country is selected, filter by country.
    // Otherwise, show all cities.
    final filtered = selectedState != null
        ? cities.where((c) => c.stateId == selectedState!.id).toList()
        : (selectedCountry != null
            ? cities.where((c) => c.countryId == selectedCountry!.id).toList()
            : cities);
    return DropdownButtonFormField<CityItem>(
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(12),
      initialValue: (selected != null && filtered.any((e) => e.id == selected!.id))
          ? filtered.firstWhere((e) => e.id == selected!.id)
          : null,
      items: [
        for (final c in filtered)
          DropdownMenuItem(value: c, child: Text(c.name)),
      ],
      decoration: const InputDecoration(labelText: 'City'),
      onChanged: filtered.isEmpty ? null : onChanged,
    );
  }
}

class ActionButtonsRow extends StatelessWidget {
  final VoidCallback onReset;
  final VoidCallback onApply;

  const ActionButtonsRow({
    super.key,
    required this.onReset,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade300,
              foregroundColor: Colors.black,
            ),
            onPressed: onReset,
            child: Text('Reset'.tr),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: onApply,
            child: Text('Apply Filters'.tr),
          ),
        ),
      ],
    );
  }
}
