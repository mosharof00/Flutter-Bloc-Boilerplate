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
  const member = SessionAuthenticated(
    activeRole: AppRole.member,
    user: SessionUser(
      id: '1',
      displayName: 'Member Demo',
      roles: <AppRole>{AppRole.member},
    ),
  );
  const both = SessionAuthenticated(
    activeRole: AppRole.admin,
    user: SessionUser(
      id: '2',
      displayName: 'Both Demo',
      roles: <AppRole>{AppRole.member, AppRole.admin},
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

  test('a member cannot open the admin shell', () {
    expect(redirect(member, AppRoutes.adminHome), AppRoutes.memberHome);
    expect(redirect(member, AppRoutes.memberHome), isNull);
    expect(redirect(member, AppRoutes.login), AppRoutes.memberHome);
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
        member,
        '${AppRoutes.login}?from=${Uri.encodeQueryComponent(AppRoutes.adminHome)}',
      ),
      AppRoutes.memberHome,
    );
  });
}
