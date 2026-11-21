import 'package:enterprise_mvvm/core/result/result.dart';
import 'package:enterprise_mvvm/core/session/session.dart';
import 'package:enterprise_mvvm/features/auth/domain/models/user.dart';

abstract interface class AuthRepository {
  Future<Result<User>> login({required String email, required String password});

  Future<Result<void>> logout();

  Future<Result<Session>> restore();
}
