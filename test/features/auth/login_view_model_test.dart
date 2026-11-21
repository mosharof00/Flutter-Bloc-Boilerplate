import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:enterprise_mvvm/core/access/app_role.dart';
import 'package:enterprise_mvvm/core/error/failure.dart';
import 'package:enterprise_mvvm/core/result/result.dart';
import 'package:enterprise_mvvm/features/auth/domain/models/user.dart';
import 'package:enterprise_mvvm/features/auth/domain/repositories/auth_repository.dart';
import 'package:enterprise_mvvm/features/auth/ui/login/login_state.dart';
import 'package:enterprise_mvvm/features/auth/ui/login/login_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../fakes/fake_auth_repository.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  const user = User(
    id: '1',
    email: 'member@demo.com',
    displayName: 'Member Demo',
    roles: <AppRole>{AppRole.member},
  );

  blocTest<LoginViewModel, LoginState>(
    'emits loading then success',
    build: () => LoginViewModel(
      FakeAuthRepository(loginResult: const Success<User>(user)),
    ),
    act: (LoginViewModel viewModel) =>
        viewModel.submit(email: 'member@demo.com', password: '123456'),
    expect: () => const <LoginState>[LoginLoading(), LoginSuccess()],
  );

  blocTest<LoginViewModel, LoginState>(
    'emits the repository failure',
    build: () => LoginViewModel(FakeAuthRepository()),
    act: (LoginViewModel viewModel) =>
        viewModel.submit(email: 'member@demo.com', password: 'nope'),
    expect: () => const <LoginState>[
      LoginLoading(),
      LoginFailure(InvalidCredentialsFailure()),
    ],
  );

  test('ignores a second submit while the first is running', () async {
    final repository = _MockAuthRepository();
    final completer = Completer<Result<User>>();
    when(
      () => repository.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) => completer.future);

    final viewModel = LoginViewModel(repository);
    final first = viewModel.submit(email: 'a@b.c', password: 'secret');
    final second = viewModel.submit(email: 'a@b.c', password: 'secret');
    completer.complete(const Success<User>(user));
    await Future.wait<void>(<Future<void>>[first, second]);

    verify(
      () => repository.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).called(1);
    await viewModel.close();
  });
}
