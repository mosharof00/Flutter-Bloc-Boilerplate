import 'package:enterprise_mvvm/core/access/access_policy.dart';
import 'package:enterprise_mvvm/core/access/app_role.dart';
import 'package:enterprise_mvvm/core/access/permission.dart';
import 'package:enterprise_mvvm/core/config/app_config.dart';
import 'package:enterprise_mvvm/core/config/app_flavor.dart';
import 'package:enterprise_mvvm/core/session/session.dart';
import 'package:enterprise_mvvm/core/session/session_user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const policy = AccessPolicy();

  SessionAuthenticated session({
    required AppRole activeRole,
    Set<AppRole> roles = const <AppRole>{AppRole.user, AppRole.admin},
    Set<Permission>? permissions,
  }) {
    return SessionAuthenticated(
      activeRole: activeRole,
      user: SessionUser(
        id: '1',
        displayName: 'Ada',
        roles: roles,
        permissions: permissions,
      ),
    );
  }

  test('role defaults allow only the active role home', () {
    final userSession = session(
      activeRole: AppRole.user,
      roles: const <AppRole>{AppRole.user},
    );
    expect(policy.can(userSession, Permission.viewUserHome), isTrue);
    expect(policy.can(userSession, Permission.viewAdminHome), isFalse);
    expect(
      policy.can(const SessionUnauthenticated(), Permission.viewUserHome),
      isFalse,
    );
  });

  test('server permissions narrow the active role and cannot widen it', () {
    final revoked = session(
      activeRole: AppRole.user,
      permissions: const <Permission>{},
    );
    final kept = session(
      activeRole: AppRole.user,
      permissions: const <Permission>{Permission.viewUserHome},
    );
    final widened = session(
      activeRole: AppRole.user,
      permissions: const <Permission>{
        Permission.viewUserHome,
        Permission.viewAdminHome,
      },
    );

    expect(policy.can(revoked, Permission.viewUserHome), isFalse);
    expect(policy.can(kept, Permission.viewUserHome), isTrue);
    expect(policy.can(widened, Permission.viewAdminHome), isFalse);
  });

  test('prod never enables http logs', () {
    expect(
      AppConfig.allowsHttpLogs(flavor: AppFlavor.prod, requested: true),
      isFalse,
    );
    expect(
      AppConfig.allowsHttpLogs(flavor: AppFlavor.dev, requested: true),
      isTrue,
    );
    expect(
      AppConfig.allowsHttpLogs(flavor: AppFlavor.staging, requested: false),
      isFalse,
    );
  });

  test('release builds require an explicit FLAVOR define', () {
    expect(
      () => AppConfig.resolveFlavor(
        rawFlavor: '',
        fallbackFlavor: AppFlavor.dev,
        isRelease: true,
      ),
      throwsA(isA<StateError>()),
    );
    expect(
      AppConfig.resolveFlavor(
        rawFlavor: '',
        fallbackFlavor: AppFlavor.dev,
        isRelease: false,
      ),
      AppFlavor.dev,
    );
    expect(
      AppConfig.resolveFlavor(
        rawFlavor: 'prod',
        fallbackFlavor: AppFlavor.dev,
        isRelease: true,
      ),
      AppFlavor.prod,
    );
  });
}
