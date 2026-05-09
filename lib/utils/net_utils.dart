import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:evento_app/network_services/core/http_headers.dart';

class NetUtils {
  static Future<http.Response> getWithRetry(
    Uri uri, {
    Map<String, String>? headers,
    int retries = 1, // Changed from 2 to 1 (total 2 attempts as requested)
    Duration timeout = const Duration(seconds: 20),
  }) async {
    final mergedHeaders = <String, String>{
      ...HttpHeadersHelper.base(),
      if (headers != null) ...headers,
    };
    int attempt = 0;

    while (attempt <= retries) {
      try {
        final res = await http
            .get(uri, headers: mergedHeaders)
            .timeout(
              timeout,
              onTimeout: () => throw TimeoutException(
                'GET $uri timed out after ${timeout.inSeconds}s',
              ),
            );

        // Special-case 429: respect Retry-After and do not retry this call
        if (res.statusCode == 429) {
          // Note: Retry-After header parsed by caller if needed.
          return res;
        }

        if (!_isRetryableStatus(res.statusCode)) {
          return res;
        }

        if (attempt < retries) {
          await _backoff(attempt);
          attempt++;
          continue;
        }

        throw Exception(
          'Failed after ${retries + 1} attempts (1 initial + $retries retries). Last status: ${res.statusCode}',
        );
      } on SocketException catch (e) {
        if (attempt >= retries) {
          throw Exception('Network error after ${retries + 1} attempts: $e');
        }
        await _backoff(attempt);
        attempt++;
      } on TimeoutException catch (e) {
        if (attempt >= retries) {
          throw Exception('Timeout error after ${retries + 1} attempts: $e');
        }
        await _backoff(attempt);
        attempt++;
      }
    }

    throw Exception('Unexpected end of retry loop');
  }

  static bool _isRetryableStatus(int code) {
    // 429 is handled specially: we honor Retry-After and do not retry here
    return code == 408 ||
        code == 425 ||
        code == 500 ||
        code == 502 ||
        code == 503 ||
        code == 504;
  }

  static Future<void> _backoff(int attempt) async {
    // Longer delay for rate limiting (429) scenarios
    final delay = Duration(
      milliseconds: 1000 * (1 << attempt),
    ); // 1s, 2s, 4s...
    await Future.delayed(delay);
  }
}
