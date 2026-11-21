/// Turns a relative media path into an absolute URL.
///
/// Values that already have a scheme (`https`, `http`, `data`) are returned
/// unchanged. Empty values stay empty.
String resolveMediaUrl(String? url, {required String baseUrl}) {
  final value = url?.trim() ?? '';
  if (value.isEmpty) {
    return '';
  }
  final parsed = Uri.tryParse(value);
  if (parsed != null && parsed.hasScheme) {
    return value;
  }
  final root = baseUrl.endsWith('/')
      ? baseUrl.substring(0, baseUrl.length - 1)
      : baseUrl;
  final path = value.startsWith('/') ? value.substring(1) : value;
  return '$root/$path';
}
