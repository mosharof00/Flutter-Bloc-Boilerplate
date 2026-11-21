import 'package:enterprise_mvvm/app/role_modules.dart';
import 'package:enterprise_mvvm/app/router/app_routes.dart';
import 'package:enterprise_mvvm/app/router/redirect.dart';
import 'package:enterprise_mvvm/core/access/access_policy.dart';
import 'package:enterprise_mvvm/core/access/app_role.dart';
import 'package:enterprise_mvvm/core/session/session.dart';
import 'package:enterprise_mvvm/core/session/session_user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const policy = AccessPolicy();
  final modules = buildRoleModules();
  const userSession = SessionAuthenticated(
    activeRole: AppRole.user,
    user: SessionUser(
      id: '1',
      displayName: 'User Demo',
      roles: <AppRole>{AppRole.user},
    ),
  );
  const both = SessionAuthenticated(
    activeRole: AppRole.admin,
    user: SessionUser(
      id: '2',
      displayName: 'Both Demo',
      roles: <AppRole>{AppRole.user, AppRole.admin},
    ),
  );

  String? redirect(Session session, String location) {
    return resolveRedirect(
      session: session,
      uri: Uri.parse(location),
      policy: policy,
      modules: modules,
    );
  }

  test('unknown stays on splash and other paths go there', () {
    expect(redirect(const SessionUnknown(), AppRoutes.splash), isNull);
    expect(redirect(const SessionUnknown(), AppRoutes.login), AppRoutes.splash);
  });

  test('unauthenticated users go to login and keep the target', () {
    expect(
      redirect(const SessionUnauthenticated(), AppRoutes.splash),
      AppRoutes.login,
    );
    expect(
      redirect(const SessionUnauthenticated(), AppRoutes.adminHome),
      '${AppRoutes.login}?from=${Uri.encodeQueryComponent(AppRoutes.adminHome)}',
    );
    expect(redirect(const SessionUnauthenticated(), AppRoutes.login), isNull);
  });

  test('a user cannot open the admin shell', () {
    expect(redirect(userSession, AppRoutes.adminHome), AppRoutes.userHome);
    expect(redirect(userSession, AppRoutes.userHome), isNull);
    expect(redirect(userSession, AppRoutes.login), AppRoutes.userHome);
  });

  test('login returns to a location the active role can access', () {
    expect(
      redirect(
        both,
        '${AppRoutes.login}?from=${Uri.encodeQueryComponent(AppRoutes.adminHome)}',
      ),
      AppRoutes.adminHome,
    );
    expect(
      redirect(
        userSession,
        '${AppRoutes.login}?from=${Uri.encodeQueryComponent(AppRoutes.adminHome)}',
      ),
      AppRoutes.userHome,
    );
  });
}
