import 'package:enterprise_mvvm/app/app_dependencies.dart';
import 'package:enterprise_mvvm/app/roles/role_context.dart';
import 'package:enterprise_mvvm/core/access/app_role.dart';
import 'package:enterprise_mvvm/core/session/session.dart';
import 'package:get_it/get_it.dart';

typedef RoleScopeRegistrar = void Function(GetIt scope, AppRole role);

final class AppContainer {
  AppContainer({
    required this.getIt,
    required this.dependencies,
    required this._registerRoleScope,
  });

  static const sessionScopeName = 'session';
  static const roleScopeName = 'role';

  final GetIt getIt;
  final AppDependencies dependencies;
  final RoleScopeRegistrar _registerRoleScope;

  void openSessionScope(SessionAuthenticated session) {
    if (getIt.hasScope(sessionScopeName)) {
      return;
    }
    getIt.pushNewScope(
      scopeName: sessionScopeName,
      init: (GetIt scope) {
        scope.registerSingleton<SessionContext>(
          SessionContext(userId: session.user.id),
        );
      },
    );
  }

  Future<void> openRoleScope(AppRole role) async {
    if (getIt.hasScope(roleScopeName)) {
      await getIt.dropScope(roleScopeName);
    }
    getIt.pushNewScope(
      scopeName: roleScopeName,
      init: (GetIt scope) => _registerRoleScope(scope, role),
    );
  }

  Future<void> closeSessionScope() async {
    if (getIt.hasScope(roleScopeName)) {
      await getIt.dropScope(roleScopeName);
    }
    if (getIt.hasScope(sessionScopeName)) {
      await getIt.dropScope(sessionScopeName);
    }
  }
}
