import 'package:enterprise_mvvm/app/router/app_routes.dart';
import 'package:enterprise_mvvm/core/access/access_policy.dart';
import 'package:enterprise_mvvm/core/access/role_module.dart';
import 'package:enterprise_mvvm/core/session/session.dart';

String? resolveRedirect({
  required Session session,
  required Uri uri,
  required AccessPolicy policy,
  required List<RoleModule> modules,
}) {
  final path = uri.path;
  final from = uri.queryParameters['from'];

  if (session is SessionUnknown) {
    return path == AppRoutes.splash ? null : AppRoutes.splash;
  }

  if (session is SessionUnauthenticated) {
    if (path == AppRoutes.login) {
      return null;
    }
    if (path == AppRoutes.splash || !_isInternalPath(path)) {
      return AppRoutes.login;
    }
    return '${AppRoutes.login}?from=${Uri.encodeQueryComponent(path)}';
  }

  final home = _homeFor(session, modules);
  if (path == AppRoutes.splash || path == AppRoutes.login) {
    if (from != null &&
        _isInternalPath(from) &&
        _canAccess(session, from, policy, modules)) {
      return from;
    }
    return home;
  }
  if (!_canAccess(session, path, policy, modules)) {
    return home;
  }
  return null;
}

bool _isInternalPath(String path) {
  return path.startsWith('/') && !path.startsWith('//');
}

String _homeFor(Session session, List<RoleModule> modules) {
  if (session is SessionAuthenticated) {
    for (final RoleModule module in modules) {
      if (module.role == session.activeRole) {
        return module.homePath;
      }
    }
  }
  return modules.first.homePath;
}

bool _canAccess(
  Session session,
  String path,
  AccessPolicy policy,
  List<RoleModule> modules,
) {
  if (session is! SessionAuthenticated) {
    return false;
  }
  for (final RoleModule module in modules) {
    final home = module.homePath;
    final matches = path == home || path.startsWith('$home/');
    if (matches) {
      return policy.can(session, module.homePermission);
    }
  }
  return true;
}
