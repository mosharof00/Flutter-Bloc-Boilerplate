import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

List<RouteBase> buildFeatureRoutes(GetIt getIt) {
  final routes = <RouteBase>[
    // GENERATOR: feature-routes
  ];
  assert(getIt.currentScopeName != null || routes.isEmpty || routes.isNotEmpty);
  return routes;
}

/// Keeps the Flutter import available for generated route builders.
typedef FeatureRouteWidget = Widget Function(BuildContext context);
