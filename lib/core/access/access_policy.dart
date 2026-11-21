import 'package:enterprise_mvvm/core/access/permission.dart';
import 'package:enterprise_mvvm/core/access/role_permissions.dart';
import 'package:enterprise_mvvm/core/session/session.dart';

/// Decides what the active role may see.
///
/// The active role is the ceiling. When the backend sends permissions they
/// narrow that ceiling; they do not grant a permission the active role lacks.
/// The server must still enforce access on every request.
final class AccessPolicy {
  const AccessPolicy();

  bool can(Session session, Permission permission) {
    if (session is! SessionAuthenticated) {
      return false;
    }
    final roleAllows = RolePermissions.of(session.activeRole)
        .contains(permission);
    final granted = session.user.permissions;
    if (granted == null) {
      return roleAllows;
    }
    return roleAllows && granted.contains(permission);
  }
}
