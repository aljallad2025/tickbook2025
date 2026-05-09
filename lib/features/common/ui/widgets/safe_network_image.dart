import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class SafeNetworkImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const SafeNetworkImage(
    this.url, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    int? memCacheSize(double? v) {
      if (v == null) return null;
      if (!v.isFinite) return null;
      if (v <= 0) return null;
      return (v * 1.5).round();
    }

    final bool widthFinite = width != null && width!.isFinite && width! > 0;
    final bool heightFinite = height != null && height!.isFinite && height! > 0;

    final Widget image = CachedNetworkImage(
      imageUrl: url,
      width: widthFinite ? width : null,
      height: heightFinite ? height : null,
      fit: fit,
      fadeInDuration: const Duration(milliseconds: 150),
      fadeOutDuration: const Duration(milliseconds: 150),
      memCacheWidth: memCacheSize(width),
      memCacheHeight: memCacheSize(height),
      placeholder: (_, __) =>
          placeholder ??
          Container(
            width: widthFinite ? width : null,
            height: heightFinite ? height : null,
            color: Colors.grey.shade200,
            alignment: Alignment.center,
            child: const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
      errorWidget: (_, __, ___) =>
          errorWidget ??
          Container(
            width: widthFinite ? width : null,
            height: heightFinite ? height : null,
            color: Colors.grey.shade200,
            alignment: Alignment.center,
            child: const Icon(Icons.broken_image, size: 36, color: Colors.grey),
          ),
    );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }
}
