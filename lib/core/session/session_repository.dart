import 'package:enterprise_mvvm/core/access/app_role.dart';
import 'package:enterprise_mvvm/core/result/result.dart';
import 'package:enterprise_mvvm/core/session/session.dart';

/// App-wide session. Owned by the data layer, observed by the router and UI.
abstract interface class SessionRepository {
  Stream<Session> get session;

  Session get current;

  Future<Result<void>> switchRole(AppRole role);

  Future<void> expire();
}
