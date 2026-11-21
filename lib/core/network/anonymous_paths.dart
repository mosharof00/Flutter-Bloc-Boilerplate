abstract final class AnonymousPaths {
  static const Set<String> paths = <String>{'/auth/login', '/auth/refresh'};

  static bool matches(Uri uri) => paths.contains(uri.path);
}
