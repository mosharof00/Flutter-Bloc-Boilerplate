const Set<String> _secretFragments = <String>{
  'password',
  'token',
  'secret',
  'authorization',
  'apikey',
};

bool isSecretKey(String key) {
  final normalized = key.toLowerCase().replaceAll('_', '');
  for (final fragment in _secretFragments) {
    if (normalized.contains(fragment)) {
      return true;
    }
  }
  return false;
}

Object? redactSensitive(Object? value) {
  if (value is Map<dynamic, dynamic>) {
    final redacted = <String, Object?>{};
    for (final MapEntry<dynamic, dynamic> entry in value.entries) {
      final key = '${entry.key}';
      redacted[key] = isSecretKey(key) ? '***' : redactSensitive(entry.value);
    }
    return redacted;
  }
  if (value is List<dynamic>) {
    return value.map(redactSensitive).toList();
  }
  return value;
}

Map<String, Object?> redactHeaders(Map<String, dynamic> headers) {
  final redacted = <String, Object?>{};
  for (final MapEntry<String, dynamic> entry in headers.entries) {
    redacted[entry.key] = isSecretKey(entry.key) ? '***' : entry.value;
  }
  return redacted;
}
