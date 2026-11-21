import 'dart:async';

import 'package:enterprise_mvvm/core/access/app_role.dart';
import 'package:enterprise_mvvm/core/error/failure.dart';
import 'package:enterprise_mvvm/core/result/result.dart';
import 'package:enterprise_mvvm/core/session/session.dart';
import 'package:enterprise_mvvm/core/session/session_repository.dart';

final class FakeSessionRepository implements SessionRepository {
  FakeSessionRepository(this._current);

  final StreamController<Session> _controller =
      StreamController<Session>.broadcast();
  Session _current;

  void publish(Session session) {
    _current = session;
    _controller.add(session);
  }

  @override
  Session get current => _current;

  @override
  Stream<Session> get session => _controller.stream;

  @override
  Future<void> expire() async {
    publish(const SessionUnauthenticated());
  }

  @override
  Future<Result<void>> switchRole(AppRole role) async {
    final active = _current;
    if (active is! SessionAuthenticated) {
      return const Err<void>(UnauthorizedFailure());
    }
    if (!active.user.roles.contains(role)) {
      return const Err<void>(ForbiddenFailure());
    }
    publish(SessionAuthenticated(user: active.user, activeRole: role));
    return const Success<void>(null);
  }

  Future<void> dispose() => _controller.close();
}
