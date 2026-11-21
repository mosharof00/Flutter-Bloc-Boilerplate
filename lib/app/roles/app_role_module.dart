import 'package:enterprise_mvvm/core/access/role_module.dart';
import 'package:enterprise_mvvm/l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

abstract class AppRoleModule implements RoleModule {
  const AppRoleModule();

  GoRoute route();

  void registerScope(GetIt scope);

  String title(AppLocalizations l10n);
}
