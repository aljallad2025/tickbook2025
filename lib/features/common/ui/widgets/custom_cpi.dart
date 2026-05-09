import 'dart:async';
import 'package:evento_app/app/app_colors.dart';
import 'package:evento_app/features/common/ui/widgets/network_app_logo.dart';
import 'package:flutter/material.dart';

class CustomCPI extends StatefulWidget {
  final Duration? delay;

  const CustomCPI({super.key, this.delay});

  @override
  State<CustomCPI> createState() => _CustomCPIState();
}

class _CustomCPIState extends State<CustomCPI> {
  bool _showLoader = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.delay != null) {
      _timer = Timer(widget.delay!, () {
        if (mounted) setState(() => _showLoader = false);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primaryColor,
      ),
      child: SizedBox(
        height: 52,
        width: 52,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (_showLoader)
              const SizedBox(
                height: 40,
                width: 40,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3,
                ),
              ),
            const NetworkAppLogo(type: 'favicon', width: 24, height: 24),
          ],
        ),
      ),
    );
  }
}
