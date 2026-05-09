import 'dart:io';

import 'package:evento_app/app/app_colors.dart';
import 'package:evento_app/features/common/ui/widgets/custom_app_bar.dart';
import 'package:evento_app/features/common/ui/widgets/shimmer_widgets.dart';
import 'package:evento_app/network_services/core/http_headers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:evento_app/features/common/ui/widgets/custom_snack_bar_widget.dart';

class TicketViewerScreen extends StatelessWidget {
  final String title;
  final String url;

  const TicketViewerScreen({super.key, required this.title, required this.url});

  // Try a direct download first to avoid intermittent server disconnects
  Future<String?> _downloadPdfToTemp(String url) async {
    try {
      final uri = Uri.parse(url);
      final client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 20)
        ..idleTimeout = const Duration(seconds: 10);

      final req = await client.getUrl(uri);
      // Prefer PDF; add auth header if available
      try {
        final lang = HttpHeadersHelper.languageCode;
        req.headers.set(
          HttpHeaders.acceptHeader,
          'application/pdf,application/octet-stream,*/*',
        );
        req.headers.set(HttpHeaders.acceptLanguageHeader, lang);
        final auth = HttpHeadersHelper.auth()['Authorization'];
        if (auth != null && auth.isNotEmpty) {
          req.headers.set(HttpHeaders.authorizationHeader, auth);
        }
        req.headers.set(HttpHeaders.connectionHeader, 'close');
      } catch (_) {}

      final res = await req.close();
      if (res.statusCode != 200) {
        client.close(force: true);
        return null;
      }

      final tmp = await getTemporaryDirectory();
      final path =
          '${tmp.path}/ticket_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File(path);
      final sink = file.openWrite();
      await res.forEach(sink.add);
      await sink.flush();
      await sink.close();
      client.close();
      return file.path;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final uri = Uri.tryParse(url);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: AppColors.primaryColor,
        onPressed: () async {
          if (uri == null) {
            CustomSnackBar.show(
              iconBgColor: AppColors.snackError,
              context,
              'Invalid URL',
            );
            return;
          }
          final success = await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
          if (!success && context.mounted) {
            CustomSnackBar.show(
              iconBgColor: AppColors.snackError,
              context,
              'Could not open link',
            );
          }
        },
        child: const Icon(Icons.download, color: Colors.white),
      ),
      appBar: CustomAppBar(title: title),
      body: uri == null
          ? const Center(child: Text('Invalid PDF URL'))
          : FutureBuilder<String?>(
              future: _downloadPdfToTemp(url),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: ShimmerPdfPage());
                }
                final path = snap.data;
                if (path != null && path.isNotEmpty) {
                  return PDF(
                    enableSwipe: true,
                    swipeHorizontal: false,
                  ).fromPath(path);
                }
                // Fallback to plugin network loader (with cache)
                return PDF(
                  enableSwipe: true,
                  swipeHorizontal: false,
                ).cachedFromUrl(
                  url,
                  maxAgeCacheObject: const Duration(days: 1),
                  placeholder: (progress) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const ShimmerPdfPage(),
                        const SizedBox(height: 16),
                        Text('Loading PDF ${progress.toStringAsFixed(0)}%'),
                      ],
                    ),
                  ),
                  errorWidget: (error) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('Failed to load PDF: $error'),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
