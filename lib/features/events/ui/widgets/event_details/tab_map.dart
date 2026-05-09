import 'dart:async';
import 'package:evento_app/app/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as ll;

class MapSection extends StatefulWidget {
  const MapSection({
    super.key,
    required this.lat,
    required this.lon,
    required this.title,
  });
  final double? lat;
  final double? lon;
  final String title;
  @override
  State<MapSection> createState() => _MapSectionState();
}

class _MapSectionState extends State<MapSection> {
  bool _failed = false;
  final int _attempt = 0;
  ll.LatLng? _user;
  bool _starting = false;
  StreamSubscription<Position>? _posSub;
  String? _error;
  final MapController _mapController = MapController();

  void _safeSet(VoidCallback fn) {
    if (!mounted) return;
    setState(fn);
  }

  @override
  void initState() {
    super.initState();
    // Delay starting location updates until user explicitly requests.
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _posSub = null;
    super.dispose();
  }

  Future<void> _beginLocation() async {
    if (_starting) return;
    _starting = true;
    await _posSub?.cancel();
    _posSub = null;
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        _safeSet(() => _error = 'Location services disabled');
      }
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied) {
        _safeSet(() => _error = 'Location permission denied');
        return;
      }
      if (perm == LocationPermission.deniedForever) {
        _safeSet(
          () => _error = 'Permission permanently denied, open settings.',
        );
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      final me = ll.LatLng(pos.latitude, pos.longitude);
      _safeSet(() => _user = me);
      _mapController.move(me, 13);
      _posSub =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 5,
            ),
          ).listen(
            (p) {
              _safeSet(() => _user = ll.LatLng(p.latitude, p.longitude));
            },
            onError: (e) {
              _safeSet(() => _error = 'Location stream error: $e');
            },
          );
    } catch (e) {
      _safeSet(() => _error = 'Location error: $e');
    } finally {
      _starting = false;
    }
  }

  void _centerOnMe() {
    if (_user != null) {
      _mapController.move(_user!, 13);
    } else {
      // Request permission and start tracking only when user taps.
      _beginLocation();
    }
  }

  void _centerOnPin(ll.LatLng center) {
    _mapController.move(center, 13);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.lat == null || widget.lon == null) {
      return const Text('Location unavailable');
    }
    final center = ll.LatLng(widget.lat!, widget.lon!);
    if (_failed) {
      return Container(
        height: 260,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade100,
          border: Border.all(color: Colors.grey.shade300),
        ),
        alignment: Alignment.center,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, size: 42, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'Map unavailable offline',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }
    return SizedBox(
      height: 260,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            FlutterMap(
              key: ValueKey(_attempt),
              mapController: _mapController,
              options: MapOptions(initialCenter: center, initialZoom: 13),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.ticbook.ticbookapp',
                  errorTileCallback: (tile, error, stackTrace) {
                    if (mounted) setState(() => _failed = true);
                  },
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: center,
                      width: 46,
                      height: 46,
                      alignment: Alignment.bottomCenter,
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 46,
                      ),
                    ),
                    if (_user != null)
                      Marker(
                        point: _user!,
                        width: 22,
                        height: 22,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue.withValues(alpha: 0.5),
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: const [
                              BoxShadow(color: Colors.black26, blurRadius: 6),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                RichAttributionWidget(
                  attributions: const [
                    TextSourceAttribution('© OpenStreetMap contributors'),
                  ],
                ),
              ],
            ),
            Positioned(
              right: 10,
              bottom: 10,
              child: Column(
                children: [
                  FloatingActionButton.small(
                    backgroundColor: AppColors.primaryColor,
                    heroTag: 'centerMeBtn',
                    onPressed: _centerOnMe,
                    child: const Icon(Icons.my_location, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  FloatingActionButton.small(
                    backgroundColor: AppColors.primaryColor,
                    heroTag: 'centerPinBtn',
                    onPressed: () => _centerOnPin(center),
                    child: const Icon(Icons.location_pin, color: Colors.white),
                  ),
                ],
              ),
            ),
            if (_error != null)
              Positioned(
                left: 12,
                right: 12,
                top: 12,
                child: Material(
                  color: Colors.red.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
