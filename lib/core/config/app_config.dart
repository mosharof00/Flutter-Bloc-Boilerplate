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
    const rawFlavor = String.fromEnvironment('FLAVOR');
    // `dart.vm.product` is true for release/AOT builds without importing Flutter.
    const isRelease = bool.fromEnvironment('dart.vm.product');
    final flavor = resolveFlavor(
      rawFlavor: rawFlavor,
      fallbackFlavor: fallbackFlavor,
      isRelease: isRelease,
    );
    const defaultUrl = 'https://api.example.com';
    final baseUrl = const String.fromEnvironment('API_BASE_URL');
    final logsRequested = const bool.fromEnvironment('ENABLE_HTTP_LOGS');
    return AppConfig(
      flavor: flavor,
      baseUrl: baseUrl.isEmpty ? defaultUrl : baseUrl,
      enableHttpLogs: allowsHttpLogs(flavor: flavor, requested: logsRequested),
    );
  }

  /// Resolves [FLAVOR] from dart-defines.
  ///
  /// Release builds must pass `--dart-define-from-file=config/<flavor>.json`
  /// (or an equivalent `FLAVOR` define). Without it, a `--flavor prod` install
  /// that still uses `lib/main.dart` would otherwise fall back to the
  /// entrypoint default and boot fake login.
  static AppFlavor resolveFlavor({
    required String rawFlavor,
    required AppFlavor fallbackFlavor,
    required bool isRelease,
  }) {
    if (rawFlavor.isEmpty) {
      if (isRelease) {
        throw StateError(
          'FLAVOR is missing. Pass --dart-define-from-file=config/<flavor>.json '
          'so release builds cannot boot as the entrypoint fallback.',
        );
      }
      return fallbackFlavor;
    }
    return AppFlavor.values.byName(rawFlavor);
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
