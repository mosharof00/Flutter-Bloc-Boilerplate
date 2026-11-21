import 'package:enterprise_mvvm/core/access/app_role.dart';
import 'package:enterprise_mvvm/core/session/session_user.dart';
import 'package:equatable/equatable.dart';

sealed class Session with Equatable {
  const Session();
}

final class SessionUnknown extends Session {
  const SessionUnknown();

  @override
  List<Object?> get props => const <Object?>[];
}

final class SessionUnauthenticated extends Session {
  const SessionUnauthenticated();

  @override
  List<Object?> get props => const <Object?>[];
}

final class SessionAuthenticated extends Session {
  const SessionAuthenticated({required this.user, required this.activeRole});

  final SessionUser user;
  final AppRole activeRole;

  @override
  List<Object?> get props => <Object?>[user, activeRole];
}
