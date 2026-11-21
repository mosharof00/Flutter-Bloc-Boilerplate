import 'package:enterprise_mvvm/app/app_dependencies.dart';
import 'package:enterprise_mvvm/app/app_scope.dart';
import 'package:enterprise_mvvm/core/theme/app_theme.dart';
import 'package:enterprise_mvvm/core/theme/locale_cubit.dart';
import 'package:enterprise_mvvm/core/theme/theme_cubit.dart';
import 'package:enterprise_mvvm/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Widget buildTestApp({
  required AppDependencies dependencies,
  required Widget child,
}) {
  return AppScope(
    dependencies: dependencies,
    child: MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>.value(value: dependencies.themeCubit),
        BlocProvider<LocaleCubit>.value(value: dependencies.localeCubit),
      ],
      child: MaterialApp(
        locale: dependencies.localeCubit.state,
        theme: AppTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    ),
  );
}
