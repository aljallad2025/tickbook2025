import 'package:evento_app/features/checkout/ui/widgets/webview_message_dialog.dart';
import 'package:evento_app/features/common/ui/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../widgets/web_checkout_config.dart';
import '../../providers/checkout_view_provider.dart';

class CheckoutWebView extends StatelessWidget {
  const CheckoutWebView({super.key});

  @override
  Widget build(BuildContext context) {
    final config = WebCheckoutConfig.fromArguments(Get.arguments);
    return ChangeNotifierProvider(
      create: (ctx) => CheckoutWebViewProvider(config, (result) {
        try {
          Navigator.of(ctx).pop(result);
        } catch (_) {}
      }),
      child: Consumer<CheckoutWebViewProvider>(
        builder: (context, viewProv, _) {
          return Scaffold(
            appBar: CustomAppBar(title: viewProv.title),
            body: Stack(
              children: [
                WebViewWidget(controller: viewProv.controller),
                if (viewProv.loading)
                  const Center(
                    child: SizedBox(
                      height: 28,
                      width: 28,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                if (viewProv.verifying)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Verifying payment... (${viewProv.attempts}/${viewProv.statusPollMaxAttempts})',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (viewProv.timedOut)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      color: Colors.red.shade700,
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.white),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Verification timeout. If payment was deducted, please wait or refresh bookings.',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (viewProv.cancelled)
                  const WebViewMessageDialog(
                    title: 'Payment Cancelled',
                    message:
                        'You cancelled the payment. No charge was captured.',
                  ),
                if (viewProv.timedOut && !viewProv.cancelled)
                  const WebViewMessageDialog(
                    title: 'Payment Verification Timeout',
                    message:
                        'We could not confirm the payment. If funds were deducted, please check your bookings later or contact support.',
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
