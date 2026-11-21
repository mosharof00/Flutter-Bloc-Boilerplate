import 'dart:async';

import 'package:enterprise_mvvm/app/di/app_container.dart';
import 'package:enterprise_mvvm/core/session/session.dart';
import 'package:enterprise_mvvm/core/session/session_repository.dart';

/// Opens the session scope after login and the role scope for the active role.
/// Logout drops both. Switching role drops only the role scope.
final class SessionScopeCoordinator {
  SessionScopeCoordinator({
    required SessionRepository repository,
    required this._container,
  }) {
    _subscription = repository.session.listen(_enqueue);
    _enqueue(repository.current);
  }

  final AppContainer _container;
  late final StreamSubscription<Session> _subscription;
  Future<void> _queue = Future<void>.value();

  void _enqueue(Session session) {
    _queue = _queue.then((_) => _apply(session));
  }

  Future<void> _apply(Session session) async {
    if (session is SessionAuthenticated) {
      _container.openSessionScope(session);
      await _container.openRoleScope(session.activeRole);
      return;
    }
    if (session is SessionUnauthenticated) {
      await _container.closeSessionScope();
    }
  }

  Future<void> dispose() => _subscription.cancel();
}
