import 'package:enterprise_mvvm/app/roles/app_role_module.dart';
import 'package:enterprise_mvvm/app/roles/role_context.dart';
import 'package:enterprise_mvvm/app/roles/user/user_shell.dart';
import 'package:enterprise_mvvm/app/router/app_routes.dart';
import 'package:enterprise_mvvm/core/access/app_role.dart';
import 'package:enterprise_mvvm/core/access/permission.dart';
import 'package:enterprise_mvvm/core/access/role_destination.dart';
import 'package:enterprise_mvvm/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

final class UserRoleModule extends AppRoleModule {
  const UserRoleModule();

  @override
  AppRole get role => AppRole.user;

  @override
  String get homePath => AppRoutes.userHome;

  @override
  Permission get homePermission => Permission.viewUserHome;

  @override
  List<RoleDestination> get destinations => const <RoleDestination>[
    RoleDestination(labelKey: 'userHomeTitle', path: AppRoutes.userHome),
  ];

  @override
  String title(AppLocalizations l10n) => l10n.userHomeTitle;

  @override
  GoRoute route() {
    return GoRoute(
      path: homePath,
      builder: (BuildContext context, GoRouterState state) => const UserShell(),
    );
  }

  @override
  void registerScope(GetIt scope) {
    scope.registerSingleton<RoleContext>(const RoleContext(AppRole.user));
  }
}
