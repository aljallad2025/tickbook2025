class WebCheckoutConfig {
  final String url;
  final String title;
  final String? finishScheme;
  final String? cancelScheme;
  final String? invoiceId;
  final String? statusUrlTemplate;
  final int statusPollIntervalSeconds;
  final int statusPollMaxAttempts;
  final List<String> successUrlContains;

  const WebCheckoutConfig({
    required this.url,
    required this.title,
    required this.finishScheme,
    required this.cancelScheme,
    required this.invoiceId,
    required this.statusUrlTemplate,
    required this.statusPollIntervalSeconds,
    required this.statusPollMaxAttempts,
    required this.successUrlContains,
  });

  static WebCheckoutConfig fromArguments(dynamic args) {
    String url = '';
    String title = 'Checkout';
    String? finishScheme;
    String? cancelScheme;
    String? invoiceId;
    String? statusUrlTemplate;
    int pollInterval = 0;
    int pollMax = 0;
    List<String> successFragments = const [];

    if (args is Map) {
      try {
        final m = Map<String, dynamic>.from(args);
        url = (m['url'] ?? '').toString();
        if (url.isEmpty) {
          url = (m['checkoutUrl'] ?? '').toString();
        }
        title = (m['title'] ?? title).toString();
        finishScheme = (m['finishScheme'] ?? m['successScheme'])?.toString();
        cancelScheme = m['cancelScheme']?.toString();
        invoiceId = m['invoiceId']?.toString();
        statusUrlTemplate = m['statusUrlTemplate']?.toString();
        pollInterval =
            int.tryParse(m['statusPollIntervalSeconds']?.toString() ?? '') ?? 0;
        pollMax =
            int.tryParse(m['statusPollMaxAttempts']?.toString() ?? '') ?? 0;
        final rawSuccess = m['successUrlContains'];
        if (rawSuccess is List) {
          successFragments = rawSuccess
              .whereType<String>()
              .map((e) => e.toLowerCase())
              .toList();
        }
      } catch (_) {}
    }

    return WebCheckoutConfig(
      url: url,
      title: title,
      finishScheme: finishScheme,
      cancelScheme: cancelScheme,
      invoiceId: invoiceId,
      statusUrlTemplate: statusUrlTemplate,
      statusPollIntervalSeconds: pollInterval,
      statusPollMaxAttempts: pollMax,
      successUrlContains: successFragments,
    );
  }
}
