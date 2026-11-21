import 'package:enterprise_mvvm/core/config/app_flavor.dart';

/// Runtime configuration loaded from `--dart-define-from-file`.
///
/// Secrets never belong in [AppConfig] or in `config/*.json`.
final class AppConfig {
  const AppConfig({
    required this.flavor,
    required this.baseUrl,
    required this.enableHttpLogs,
  });

  factory AppConfig.fromEnvironment({required AppFlavor fallbackFlavor}) {
    final rawFlavor = const String.fromEnvironment('FLAVOR');
    final flavor = rawFlavor.isEmpty
        ? fallbackFlavor
        : AppFlavor.values.byName(rawFlavor);
    const defaultUrl = 'https://api.example.com';
    final baseUrl = const String.fromEnvironment('API_BASE_URL');
    final logsRequested = const bool.fromEnvironment('ENABLE_HTTP_LOGS');
    return AppConfig(
      flavor: flavor,
      baseUrl: baseUrl.isEmpty ? defaultUrl : baseUrl,
      enableHttpLogs: allowsHttpLogs(flavor: flavor, requested: logsRequested),
    );
  }

  static bool allowsHttpLogs({
    required AppFlavor flavor,
    required bool requested,
  }) {
    return requested && flavor != AppFlavor.prod;
  }

  final AppFlavor flavor;
  final String baseUrl;

  /// HTTP logs are forced off for [AppFlavor.prod], even if the define is set.
  final bool enableHttpLogs;

  bool get useFakeServices => flavor == AppFlavor.dev;
}
