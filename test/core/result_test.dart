import 'package:enterprise_mvvm/core/error/failure.dart';
import 'package:enterprise_mvvm/core/result/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fold maps both sides', () {
    const success = Success<int>(2);
    const failure = Err<int>(NetworkFailure());
    expect(
      success.fold(onSuccess: (int value) => value, onFailure: (_) => 0),
      2,
    );
    expect(
      failure.fold(
        onSuccess: (int value) => value,
        onFailure: (failure) => failure.messageKey,
      ),
      'failureNetwork',
    );
  });
}
