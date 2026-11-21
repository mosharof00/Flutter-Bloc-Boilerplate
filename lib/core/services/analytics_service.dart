abstract interface class AnalyticsService {
  Future<void> track(String name, {Map<String, Object>? properties});
}

final class NoopAnalyticsService implements AnalyticsService {
  const NoopAnalyticsService();

  @override
  Future<void> track(String name, {Map<String, Object>? properties}) async {}
}
