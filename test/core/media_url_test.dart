import 'package:enterprise_mvvm/core/network/media_url.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const base = 'https://api.example.com';

  test('keeps absolute urls and joins relative paths', () {
    expect(
      resolveMediaUrl('https://cdn.example.com/a.png', baseUrl: base),
      'https://cdn.example.com/a.png',
    );
    expect(
      resolveMediaUrl('products/1.png', baseUrl: base),
      'https://api.example.com/products/1.png',
    );
    expect(
      resolveMediaUrl('/products/1.png', baseUrl: '$base/'),
      'https://api.example.com/products/1.png',
    );
    expect(resolveMediaUrl('  ', baseUrl: base), isEmpty);
    expect(resolveMediaUrl(null, baseUrl: base), isEmpty);
  });
}
