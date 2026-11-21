import 'package:enterprise_mvvm/core/error/failure.dart';
import 'package:enterprise_mvvm/core/result/result.dart';
import 'package:enterprise_mvvm/core/session/session.dart';
import 'package:enterprise_mvvm/features/auth/domain/models/user.dart';
import 'package:enterprise_mvvm/features/auth/domain/repositories/auth_repository.dart';

final class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.loginResult});

  Result<User>? loginResult;
  int loginCalls = 0;
  int logoutCalls = 0;

  @override
  Future<Result<User>> login({
    required String email,
    required String password,
  }) async {
    loginCalls += 1;
    return loginResult ?? const Err<User>(InvalidCredentialsFailure());
  }

  @override
  Future<Result<void>> logout() async {
    logoutCalls += 1;
    return const Success<void>(null);
  }

  @override
  Future<Result<Session>> restore() async {
    return const Success<Session>(SessionUnauthenticated());
  }
}
