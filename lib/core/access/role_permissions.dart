import 'package:enterprise_mvvm/core/access/app_role.dart';
import 'package:enterprise_mvvm/core/access/permission.dart';

/// Default role-to-permission map used when the server did not send grants.
abstract final class RolePermissions {
  static const Map<AppRole, Set<Permission>> grants =
      <AppRole, Set<Permission>>{
        AppRole.member: <Permission>{Permission.viewMemberHome},
        AppRole.admin: <Permission>{Permission.viewAdminHome},
        // GENERATOR: role-permissions
      };

  static Set<Permission> of(AppRole role) {
    return grants[role] ?? const <Permission>{};
  }
}
