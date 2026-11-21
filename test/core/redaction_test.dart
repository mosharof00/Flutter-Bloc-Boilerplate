import 'package:enterprise_mvvm/core/network/redaction.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('redacts passwords, tokens, and authorization', () {
    final redacted = redactSensitive(<String, Object?>{
      'email': 'member@demo.com',
      'password': '123456',
      'nested': <String, Object?>{
        'accessToken': 'secret-access',
        'refresh_token': 'secret-refresh',
        'name': 'Ada',
      },
    });

    expect(redacted, <String, Object?>{
      'email': 'member@demo.com',
      'password': '***',
      'nested': <String, Object?>{
        'accessToken': '***',
        'refresh_token': '***',
        'name': 'Ada',
      },
    });

    expect(
      redactHeaders(<String, dynamic>{
        'Authorization': 'Bearer secret',
        'Accept': 'application/json',
      }),
      <String, Object?>{'Authorization': '***', 'Accept': 'application/json'},
    );
  });
}
