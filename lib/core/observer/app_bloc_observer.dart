import 'dart:async';

import 'package:enterprise_mvvm/core/services/app_logger.dart';
import 'package:enterprise_mvvm/core/services/crash_reporter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final class AppBlocObserver extends BlocObserver {
  AppBlocObserver({required this._logger, required this._crashReporter});

  final AppLogger _logger;
  final CrashReporter _crashReporter;

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    _logger.debug(
      '${bloc.runtimeType} ${change.currentState.runtimeType} -> ${change.nextState.runtimeType}',
    );
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    _logger.error(
      '${bloc.runtimeType} failed',
      error: error,
      stackTrace: stackTrace,
    );
    unawaited(_crashReporter.record(error, stackTrace));
  }
}
