import 'package:enterprise_mvvm/app/roles/admin/admin_role_module.dart';
import 'package:enterprise_mvvm/app/roles/app_role_module.dart';
import 'package:enterprise_mvvm/app/roles/member/member_role_module.dart';

// GENERATOR: role-imports

List<AppRoleModule> buildRoleModules() {
  return <AppRoleModule>[
    const MemberRoleModule(),
    const AdminRoleModule(),
    // GENERATOR: role-modules
  ];
}
