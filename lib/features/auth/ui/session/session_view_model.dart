import 'dart:async';

import 'package:enterprise_mvvm/core/access/app_role.dart';
import 'package:enterprise_mvvm/core/session/session.dart';
import 'package:enterprise_mvvm/core/session/session_repository.dart';
import 'package:enterprise_mvvm/core/ui/view_model/base_view_model.dart';
import 'package:enterprise_mvvm/features/auth/domain/repositories/auth_repository.dart';

class SessionViewModel extends BaseViewModel<Session> {
  SessionViewModel({
    required SessionRepository sessionRepository,
    required this._authRepository,
  }) : _sessionRepository = sessionRepository,
       super(sessionRepository.current) {
    _subscription = _sessionRepository.session.listen(safeEmit);
  }

  final SessionRepository _sessionRepository;
  final AuthRepository _authRepository;
  late final StreamSubscription<Session> _subscription;

  Future<void> switchRole(AppRole role) {
    return _sessionRepository.switchRole(role);
  }

  Future<void> logout() {
    return _authRepository.logout();
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
