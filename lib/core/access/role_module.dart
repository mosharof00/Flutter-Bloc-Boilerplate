import 'package:enterprise_mvvm/core/access/app_role.dart';
import 'package:enterprise_mvvm/core/access/permission.dart';
import 'package:enterprise_mvvm/core/access/role_destination.dart';

/// Data a role contributes. Routes and dependency registration live in `app/`,
/// because those depend on the composition root.
abstract interface class RoleModule {
  AppRole get role;
  String get homePath;
  Permission get homePermission;
  List<RoleDestination> get destinations;
}
