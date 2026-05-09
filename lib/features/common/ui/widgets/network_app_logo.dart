import 'dart:typed_data';
import 'package:evento_app/app/assets_path.dart';
import 'package:evento_app/network_services/core/basic_service.dart';
import 'package:flutter/material.dart';

class NetworkAppLogo extends StatefulWidget {
  final double? width;
  final double height;
  final String type;

  const NetworkAppLogo({
    super.key,
    this.width,
    required this.height,
    this.type = 'logo',
  });

  @override
  State<NetworkAppLogo> createState() => _NetworkAppLogoState();
}

class _NetworkAppLogoState extends State<NetworkAppLogo> {
  Uint8List? _bytes;
  late final VoidCallback _listener;

  @override
  void initState() {
    super.initState();
    _loadOnce();
    _listener = () => _loadOnce();
    try {
      BasicService.brandingVersion.addListener(_listener);
    } catch (_) {}
  }

  Future<void> _loadOnce() async {
    try {
      final b = await BasicService.getCachedBrandingBytes(widget.type);
      if (!mounted) return;
      setState(() => _bytes = (b != null && b.isNotEmpty) ? b : null);
    } catch (_) {
      if (!mounted) return;
      setState(() => _bytes = null);
    }
  }

  String _getFallbackAsset() {
    switch (widget.type) {
      case 'favicon':
        return AssetsPath.errorFavPng;
      case 'text':
        return AssetsPath.logoBlackPng;
      case 'logo':
      default:
        return AssetsPath.logoBlackPng;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String fallback = _getFallbackAsset();

    if (_bytes != null && _bytes!.isNotEmpty) {
      return Image.memory(
        _bytes!,
        width: widget.width,
        height: widget.height,
        fit: BoxFit.contain,
      );
    }

    return Image.asset(
      fallback,
      width: widget.width,
      height: widget.height,
      fit: BoxFit.contain,
    );
  }

  @override
  void dispose() {
    try {
      BasicService.brandingVersion.removeListener(_listener);
    } catch (_) {}
    super.dispose();
  }
}
