import 'package:enterprise_mvvm/app/app_scope.dart';
import 'package:enterprise_mvvm/app/role_modules.dart';
import 'package:enterprise_mvvm/app/roles/app_role_module.dart';
import 'package:enterprise_mvvm/app/router/app_routes.dart';
import 'package:enterprise_mvvm/app/router/feature_routes.dart';
import 'package:enterprise_mvvm/app/router/redirect.dart';
import 'package:enterprise_mvvm/app/router/session_listenable.dart';
import 'package:enterprise_mvvm/app/splash/splash_screen.dart';
import 'package:enterprise_mvvm/core/access/access_policy.dart';
import 'package:enterprise_mvvm/core/ui/view_model/view_model_host.dart';
import 'package:enterprise_mvvm/features/auth/ui/login/login_screen.dart';
import 'package:enterprise_mvvm/features/auth/ui/login/login_state.dart';
import 'package:enterprise_mvvm/features/auth/ui/login/login_view_model.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

GoRouter createRouter({
  required SessionListenable sessionListenable,
  required AccessPolicy policy,
  required List<AppRoleModule> modules,
  required GetIt getIt,
}) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: sessionListenable,
    redirect: (BuildContext context, GoRouterState state) {
      return resolveRedirect(
        session: sessionListenable.session,
        uri: state.uri,
        policy: policy,
        modules: modules,
      );
    },
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.splash,
        builder: (BuildContext context, GoRouterState state) =>
            const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (BuildContext context, GoRouterState state) {
          final repository = AppScope.of(context).authRepository;
          return ViewModelHost<LoginViewModel, LoginState>(
            create: () => LoginViewModel(repository),
            builder: (LoginViewModel viewModel) =>
                LoginScreen(viewModel: viewModel),
          );
        },
      ),
      for (final AppRoleModule module in modules) module.route(),
      ...buildFeatureRoutes(getIt),
    ],
  );
}

GoRouter createAppRouter({
  required SessionListenable sessionListenable,
  required AccessPolicy policy,
  required GetIt getIt,
}) {
  return createRouter(
    sessionListenable: sessionListenable,
    policy: policy,
    modules: buildRoleModules(),
    getIt: getIt,
  );
}
