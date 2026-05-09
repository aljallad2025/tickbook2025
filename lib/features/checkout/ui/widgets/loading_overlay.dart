import 'package:flutter/material.dart';
import 'package:evento_app/app/app_text_styles.dart';

class LoadingOverlay extends StatelessWidget {
  final bool visible;
  final bool initializingPayment;
  final bool bookingStarted;
  final String? error;
  const LoadingOverlay({super.key, required this.visible, required this.initializingPayment, required this.bookingStarted, required this.error});
  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    return AnimatedOpacity(
      opacity: 0.85,
      duration: const Duration(milliseconds: 250),
      child: Container(
        color: Colors.black54,
        alignment: Alignment.center,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 36, width: 36, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)),
            const SizedBox(height: 16),
            Text(initializingPayment
                ? 'Initializing payment...'
                : (bookingStarted ? 'Finalizing booking...' : 'Submitting...'),
                style: AppTextStyles.bodyLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12, left: 24, right: 24),
                child: Text(error!, textAlign: TextAlign.center, style: AppTextStyles.bodySmall.copyWith(color: Colors.red.shade200)),
              ),
        ]),
      ),
    );
  }
}
