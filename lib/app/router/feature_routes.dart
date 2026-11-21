import 'package:enterprise_mvvm/app/router/app_routes.dart';
import 'package:enterprise_mvvm/core/ui/view_model/view_model_host.dart';
import 'package:enterprise_mvvm/core/ui/view_model/view_state.dart';
import 'package:enterprise_mvvm/features/profile/domain/models/profile.dart';
import 'package:enterprise_mvvm/features/profile/domain/repositories/profile_repository.dart';
import 'package:enterprise_mvvm/features/profile/ui/profile/profile_screen.dart';
import 'package:enterprise_mvvm/features/profile/ui/profile/profile_view_model.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

List<RouteBase> buildFeatureRoutes(GetIt getIt) {
  final routes = <RouteBase>[
    GoRoute(
      path: AppRoutes.profile,
      builder: (BuildContext context, GoRouterState state) {
        return ViewModelHost<ProfileViewModel, ViewState<List<Profile>>>(
          create: () => ProfileViewModel(getIt<ProfileRepository>()),
          builder: (ProfileViewModel viewModel) =>
              ProfileScreen(viewModel: viewModel),
        );
      },
    ),
    // GENERATOR: feature-routes
  ];
  assert(getIt.currentScopeName != null || routes.isEmpty || routes.isNotEmpty);
  return routes;
}

/// Keeps the Flutter import available for generated route builders.
typedef FeatureRouteWidget = Widget Function(BuildContext context);
