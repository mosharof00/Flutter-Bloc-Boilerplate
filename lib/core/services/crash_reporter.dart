abstract interface class CrashReporter {
  Future<void> record(Object error, StackTrace stackTrace);
}

final class NoopCrashReporter implements CrashReporter {
  const NoopCrashReporter();

  @override
  Future<void> record(Object error, StackTrace stackTrace) async {}
}
