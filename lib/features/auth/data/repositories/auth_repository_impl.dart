import 'dart:async';

import 'package:enterprise_mvvm/core/access/app_role.dart';
import 'package:enterprise_mvvm/core/error/app_exception.dart';
import 'package:enterprise_mvvm/core/error/failure.dart';
import 'package:enterprise_mvvm/core/network/auth_events.dart';
import 'package:enterprise_mvvm/core/result/result.dart';
import 'package:enterprise_mvvm/core/session/session.dart';
import 'package:enterprise_mvvm/core/session/session_repository.dart';
import 'package:enterprise_mvvm/features/auth/data/dto/user_mapper.dart';
import 'package:enterprise_mvvm/features/auth/data/services/auth_api_service.dart';
import 'package:enterprise_mvvm/features/auth/data/services/auth_local_service.dart';
import 'package:enterprise_mvvm/features/auth/domain/models/user.dart';
import 'package:enterprise_mvvm/features/auth/domain/repositories/auth_repository.dart';

final class AuthRepositoryImpl implements AuthRepository, SessionRepository {
  AuthRepositoryImpl({
    required this._api,
    required this._local,
    required this._authEvents,
  }) {
    _expiredSubscription = _authEvents.sessionExpired.listen((_) {
      unawaited(expire());
    });
  }

  final AuthApiService _api;
  final AuthLocalService _local;
  final AuthEvents _authEvents;
  final StreamController<Session> _sessions =
      StreamController<Session>.broadcast();
  late final StreamSubscription<void> _expiredSubscription;

  Session _current = const SessionUnknown();

  @override
  Stream<Session> get session => _sessions.stream;

  @override
  Session get current => _current;

  @override
  Future<Result<User>> login({
    required String email,
    required String password,
  }) async {
    final trimmed = email.trim();
    if (trimmed.isEmpty || password.isEmpty) {
      return const Err<User>(ValidationFailure());
    }
    try {
      final response = await _api.login(email: trimmed, password: password);
      final user = response.user.toDomain();
      if (user.roles.isEmpty) {
        return const Err<User>(ForbiddenFailure());
      }
      final persisted = await _local.readActiveRole();
      final active = persisted != null && user.roles.contains(persisted)
          ? persisted
          : user.roles.first;
      await _local.save(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        user: response.user,
        activeRole: active,
      );
      _publish(
        SessionAuthenticated(user: user.toSessionUser(), activeRole: active),
      );
      return Success<User>(user);
    } on InvalidCredentialsException {
      return const Err<User>(InvalidCredentialsFailure());
    } on NetworkException {
      return const Err<User>(NetworkFailure());
    } on ForbiddenException {
      return const Err<User>(ForbiddenFailure());
    } on CacheException {
      return const Err<User>(CacheFailure());
    } on AppException {
      return const Err<User>(UnknownFailure());
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      final refresh = await _local.readRefreshToken();
      if (refresh != null && refresh.isNotEmpty) {
        try {
          await _api.logout(refreshToken: refresh);
        } on AppException {
          // Local sign-out still proceeds when the server is unreachable.
        }
      }
    } finally {
      await expire();
    }
    return const Success<void>(null);
  }

  @override
  Future<Result<Session>> restore() async {
    try {
      final stored = await _local.read();
      if (stored == null) {
        _publish(const SessionUnauthenticated());
        return const Success<Session>(SessionUnauthenticated());
      }
      final user = stored.user.toDomain();
      if (user.roles.isEmpty) {
        await expire();
        return const Err<Session>(CacheFailure());
      }
      final active = user.roles.contains(stored.activeRole)
          ? stored.activeRole
          : user.roles.first;
      if (active != stored.activeRole) {
        await _local.saveActiveRole(active);
      }
      final session = SessionAuthenticated(
        user: user.toSessionUser(),
        activeRole: active,
      );
      _publish(session);
      return Success<Session>(session);
    } on CacheException {
      await expire();
      return const Err<Session>(CacheFailure());
    } on ArgumentError {
      await expire();
      return const Err<Session>(CacheFailure());
    }
  }

  @override
  Future<Result<void>> switchRole(AppRole role) async {
    final current = _current;
    if (current is! SessionAuthenticated) {
      return const Err<void>(UnauthorizedFailure());
    }
    if (!current.user.roles.contains(role)) {
      return const Err<void>(ForbiddenFailure());
    }
    if (current.activeRole == role) {
      return const Success<void>(null);
    }
    await _local.saveActiveRole(role);
    _publish(SessionAuthenticated(user: current.user, activeRole: role));
    return const Success<void>(null);
  }

  @override
  Future<void> expire() async {
    await _local.clear();
    if (_current is! SessionUnauthenticated) {
      _publish(const SessionUnauthenticated());
    }
  }

  Future<void> dispose() async {
    await _expiredSubscription.cancel();
    await _sessions.close();
  }

  void _publish(Session next) {
    _current = next;
    if (!_sessions.isClosed) {
      _sessions.add(next);
    }
  }
}
