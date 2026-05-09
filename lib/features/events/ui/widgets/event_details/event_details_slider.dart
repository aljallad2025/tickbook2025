import 'dart:async';

import 'package:evento_app/features/common/ui/widgets/shimmer_widgets.dart';
import 'package:evento_app/features/common/ui/widgets/safe_network_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class EventDetailsSlider extends StatefulWidget {
  const EventDetailsSlider({super.key, required this.headerImages});
  final List<String> headerImages;

  @override
  State<EventDetailsSlider> createState() => _EventDetailsSliderState();
}

class _EventDetailsSliderState extends State<EventDetailsSlider> {
  late final PageController _controller;
  int _active = 0;
  Timer? _autoTimer;
  static const int _kMiddle = 10000;

  void _startAuto() {
    _autoTimer?.cancel();
    _autoTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final len = widget.headerImages.length;
      if (len <= 1) return;
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    final len = widget.headerImages.length;
    final initial = len > 0 ? _kMiddle - (_kMiddle % len) : 0;
    _controller = PageController(initialPage: initial);
    _active = 0;
    WidgetsBinding.instance.addPostFrameCallback((_) => _startAuto());
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final headerImages = widget.headerImages;
    if (headerImages.isEmpty) {
      return const AspectRatio(
        aspectRatio: 16 / 9,
        child: ShimmerBox(borderRadius: 12),
      );
    }

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        SizedBox(
          height: 300,
          width: double.infinity,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.headerImages.isNotEmpty ? null : 0,
            onPageChanged: (idx) => setState(() {
              final len = headerImages.length;
              final logical = len == 0 ? 0 : idx % len;
              _active = logical;
            }),
            itemBuilder: (context, index) {
              final url = headerImages[index % headerImages.length];
              return SafeNetworkImage(
                url,
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(0),
                placeholder: const ShimmerBox(height: 300, borderRadius: 0),
              );
            },
          ),
        ),

        Positioned(
          left: 0,
          right: 0,
          bottom: 12,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(255, 255, 255, 0.85),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.transparent, blurRadius: 4),
                ],
              ),
              height: 64,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  headerImages.length,
                  (i) => GestureDetector(
                    onTap: () {
                      final len = headerImages.length;
                      if (len == 0) return;
                      final base =
                          _controller.page?.round() ?? _controller.initialPage;

                      final target = base - (base % len) + i;
                      _controller.animateToPage(
                        target,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                      _startAuto();
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 64,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _active == i
                              ? Theme.of(context).primaryColor
                              : Colors.transparent,
                          width: 2,
                        ),
                        image: DecorationImage(
                          image: CachedNetworkImageProvider(headerImages[i]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
