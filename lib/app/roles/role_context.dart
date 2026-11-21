import 'package:enterprise_mvvm/core/access/app_role.dart';

final class SessionContext {
  const SessionContext({required this.userId});

  final String userId;
}

final class RoleContext {
  const RoleContext(this.role);

  final AppRole role;
}
