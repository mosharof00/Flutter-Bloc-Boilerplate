import 'dart:async';

import 'package:enterprise_mvvm/app/app_dependencies.dart';
import 'package:enterprise_mvvm/app/app_scope.dart';
import 'package:enterprise_mvvm/app/di/app_container.dart';
import 'package:enterprise_mvvm/app/di/session_scope_coordinator.dart';
import 'package:enterprise_mvvm/app/router/app_router.dart';
import 'package:enterprise_mvvm/app/router/session_listenable.dart';
import 'package:enterprise_mvvm/core/theme/app_theme.dart';
import 'package:enterprise_mvvm/core/theme/locale_cubit.dart';
import 'package:enterprise_mvvm/core/theme/theme_cubit.dart';
import 'package:enterprise_mvvm/core/ui/widgets/offline_banner.dart';
import 'package:enterprise_mvvm/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class EnterpriseApp extends StatefulWidget {
  const EnterpriseApp({
    super.key,
    required this.dependencies,
    required this.container,
    required this.coordinator,
  });

  final AppDependencies dependencies;
  final AppContainer container;
  final SessionScopeCoordinator coordinator;

  @override
  State<EnterpriseApp> createState() => _EnterpriseAppState();
}

class _EnterpriseAppState extends State<EnterpriseApp> {
  late final SessionListenable _sessionListenable = SessionListenable(
    widget.dependencies.sessionRepository,
  );
  late final GoRouter _router = createAppRouter(
    sessionListenable: _sessionListenable,
    policy: widget.dependencies.accessPolicy,
    getIt: widget.container.getIt,
  );

  @override
  void dispose() {
    _router.dispose();
    _sessionListenable.dispose();
    unawaited(widget.coordinator.dispose());
    unawaited(widget.dependencies.themeCubit.close());
    unawaited(widget.dependencies.localeCubit.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      dependencies: widget.dependencies,
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ThemeCubit>.value(value: widget.dependencies.themeCubit),
          BlocProvider<LocaleCubit>.value(
            value: widget.dependencies.localeCubit,
          ),
        ],
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (BuildContext context, ThemeMode themeMode) {
            return BlocBuilder<LocaleCubit, Locale>(
              builder: (BuildContext context, Locale locale) {
                return MaterialApp.router(
                  title: 'Enterprise MVVM',
                  theme: AppTheme.light(),
                  darkTheme: AppTheme.dark(),
                  themeMode: themeMode,
                  locale: locale,
                  supportedLocales: AppLocalizations.supportedLocales,
                  localizationsDelegates:
                      AppLocalizations.localizationsDelegates,
                  routerConfig: _router,
                  builder: (BuildContext context, Widget? child) {
                    return OfflineBanner(
                      connectivity: widget.dependencies.connectivity,
                      child: child ?? const SizedBox.shrink(),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
