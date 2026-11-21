import 'dart:developer' as developer;

abstract interface class AppLogger {
  void debug(String message);

  void info(String message);

  void warning(String message);

  void error(String message, {Object? error, StackTrace? stackTrace});
}

final class ConsoleAppLogger implements AppLogger {
  ConsoleAppLogger({required this.enabled});

  final bool enabled;

  @override
  void debug(String message) => _write(500, message);

  @override
  void info(String message) => _write(800, message);

  @override
  void warning(String message) => _write(900, message);

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) {
    _write(1000, message, error: error, stackTrace: stackTrace);
  }

  void _write(
    int level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!enabled) {
      return;
    }
    developer.log(
      message,
      name: 'enterprise_mvvm',
      level: level,
      error: error,
      stackTrace: stackTrace,
    );
  }
}

final class NoopAppLogger implements AppLogger {
  const NoopAppLogger();

  @override
  void debug(String message) {}

  @override
  void info(String message) {}

  @override
  void warning(String message) {}

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) {}
}
