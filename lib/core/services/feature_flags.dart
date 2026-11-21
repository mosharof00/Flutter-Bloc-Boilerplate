abstract interface class FeatureFlags {
  bool isEnabled(String flag);
}

final class NoopFeatureFlags implements FeatureFlags {
  const NoopFeatureFlags();

  @override
  bool isEnabled(String flag) => false;
}
