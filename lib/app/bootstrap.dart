import 'dart:async';
import 'dart:ui';

import 'package:enterprise_mvvm/app/app.dart';
import 'package:enterprise_mvvm/app/di/app_container.dart';
import 'package:enterprise_mvvm/app/di/injection.dart';
import 'package:enterprise_mvvm/app/di/session_scope_coordinator.dart';
import 'package:enterprise_mvvm/core/config/app_config.dart';
import 'package:enterprise_mvvm/core/config/app_flavor.dart';
import 'package:enterprise_mvvm/core/observer/app_bloc_observer.dart';
import 'package:enterprise_mvvm/core/services/app_logger.dart';
import 'package:enterprise_mvvm/core/services/crash_reporter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> bootstrap(AppFlavor flavor) async {
  WidgetsFlutterBinding.ensureInitialized();
  final config = AppConfig.fromEnvironment(fallbackFlavor: flavor);
  final container = await buildContainer(config);
  installErrorHandlers(container);
  runApp(startApp(container));
}

void installErrorHandlers(AppContainer container) {
  final crashReporter = container.getIt<CrashReporter>();
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    unawaited(
      crashReporter.record(
        details.exception,
        details.stack ?? StackTrace.current,
      ),
    );
  };
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    unawaited(crashReporter.record(error, stack));
    return true;
  };
  Bloc.observer = AppBlocObserver(
    logger: container.getIt<AppLogger>(),
    crashReporter: crashReporter,
  );
}

EnterpriseApp startApp(AppContainer container) {
  final coordinator = SessionScopeCoordinator(
    repository: container.dependencies.sessionRepository,
    container: container,
  );
  unawaited(container.dependencies.authRepository.restore());
  return EnterpriseApp(
    dependencies: container.dependencies,
    container: container,
    coordinator: coordinator,
  );
}
