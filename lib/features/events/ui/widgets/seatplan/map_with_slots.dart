import 'package:evento_app/features/common/ui/widgets/custom_cpi.dart';
import 'package:evento_app/features/common/ui/widgets/safe_network_image.dart';
import 'package:evento_app/features/events/data/models/seat_map_models.dart';
import 'package:flutter/material.dart';

class MapWithSlots extends StatefulWidget {
  final String imageUrl;
  final List<SeatSlot> slots;
  final void Function(SeatSlot) onSlotTap;
  final VoidCallback onReload;
  // Optional: selected seat ids to visually highlight slots that contain selections
  final Set<int>? selectedSeatIds;
  const MapWithSlots({
    super.key,
    required this.imageUrl,
    required this.slots,
    required this.onSlotTap,
    required this.onReload,
    this.selectedSeatIds,
  });

  @override
  State<MapWithSlots> createState() => _MapWithSlotsState();
}

class _MapWithSlotsState extends State<MapWithSlots> {
  Size? _imageSize;
  final TransformationController _tc = TransformationController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolveImageSize();
  }

  void _resolveImageSize() {
    final img = NetworkImage(widget.imageUrl);
    img
        .resolve(const ImageConfiguration())
        .addListener(
          ImageStreamListener((info, _) {
            if (mounted) {
              setState(() {
                _imageSize = Size(
                  info.image.width.toDouble(),
                  info.image.height.toDouble(),
                );
              });
            }
          }),
        );
  }

  void _zoom(double factor) {
    final m = _tc.value.clone();
    m.scaleByDouble(factor, factor, 1.0, 1.0);
    setState(() => _tc.value = m);
  }

  @override
  Widget build(BuildContext context) {
    if (_imageSize == null) {
      return const Center(child: CustomCPI());
    }
    final imgSize = _imageSize!;
    return Stack(
      children: [
        InteractiveViewer(
          transformationController: _tc,
          minScale: 0.3,
          maxScale: 8,
          panEnabled: true,
          scaleEnabled: true,
          constrained: false,
          boundaryMargin: const EdgeInsets.all(400),
          // Prevent the seat image from painting over siblings above
          clipBehavior: Clip.hardEdge,
          child: Stack(
            children: [
              SizedBox(
                width: imgSize.width,
                height: imgSize.height,
                child: SafeNetworkImage(
                  widget.imageUrl,
                  width: imgSize.width,
                  height: imgSize.height,
                  fit: BoxFit.cover,
                ),
              ),
              for (final slot in widget.slots)
                _SlotBox(
                  slot: slot,
                  onTap: widget.onSlotTap,
                  selectedSeatIds: widget.selectedSeatIds,
                ),
            ],
          ),
        ),
        Positioned(
          right: 12,
          top: 12,
          child: Column(
            children: [
              _ZoomBtn(icon: Icons.add, onTap: () => _zoom(1.2)),
              const SizedBox(height: 8),
              _ZoomBtn(icon: Icons.remove, onTap: () => _zoom(0.8)),
              const SizedBox(height: 8),
              _ZoomBtn(icon: Icons.refresh, onTap: widget.onReload),
            ],
          ),
        ),
      ],
    );
  }
}

class _ZoomBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ZoomBtn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF3DD1C4),
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(8),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}

class _SlotBox extends StatelessWidget {
  final SeatSlot slot;
  final void Function(SeatSlot) onTap;
  final Set<int>? selectedSeatIds;
  const _SlotBox({
    required this.slot,
    required this.onTap,
    this.selectedSeatIds,
  });
  @override
  Widget build(BuildContext context) {
    final slotAvailable = slot.isBooked == 0;
    final hasFreeSeat = slot.seats.any(
      (s) => s.isBooked == 0 && s.isDeactive == 0,
    );
    final available = slotAvailable && hasFreeSeat;
    final anySelected = () {
      if (selectedSeatIds == null || selectedSeatIds!.isEmpty) return false;
      for (final s in slot.seats) {
        if (selectedSeatIds!.contains(s.id)) return true;
      }
      return false;
    }();
    final bg = !available
        ? Colors.grey.shade400
        : anySelected
        ? Colors.orange
        : (_tryParseColor(slot.backgroundColor) ?? Colors.tealAccent);
    // Increase size by 10%
    final double boxW = slot.width * 1.10;
    final double boxH = slot.height * 1.10;
    return Positioned(
      left: slot.posX,
      top: slot.posY,
      child: Transform.rotate(
        angle: slot.rotate * 3.1415926535 / 180,
        child: GestureDetector(
          onTap: available ? () => onTap(slot) : null,
          child: Container(
            width: boxW,
            height: boxH,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(slot.round),
              border: Border.all(
                color: _tryParseColor(slot.borderColor) ?? Colors.black26,
              ),
            ),
            child: Text(
              slot.slotName,
              style: TextStyle(
                fontSize: slot.fontSize.toDouble(),
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color? _tryParseColor(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    var v = hex.replaceAll('#', '');
    if (v.length == 6) v = 'FF$v';
    try {
      return Color(int.parse(v, radix: 16));
    } catch (_) {
      return null;
    }
  }
}
