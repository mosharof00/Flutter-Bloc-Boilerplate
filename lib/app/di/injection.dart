import 'package:dio/dio.dart';
import 'package:enterprise_mvvm/app/app_dependencies.dart';
import 'package:enterprise_mvvm/app/di/app_container.dart';
import 'package:enterprise_mvvm/app/di/register_features.dart';
import 'package:enterprise_mvvm/app/role_modules.dart';
import 'package:enterprise_mvvm/core/access/access_policy.dart';
import 'package:enterprise_mvvm/core/access/app_role.dart';
import 'package:enterprise_mvvm/core/config/app_config.dart';
import 'package:enterprise_mvvm/core/config/app_flavor.dart';
import 'package:enterprise_mvvm/core/network/auth_events.dart';
import 'package:enterprise_mvvm/core/network/dio_client.dart';
import 'package:enterprise_mvvm/core/network/redacting_log_interceptor.dart';
import 'package:enterprise_mvvm/core/services/analytics_service.dart';
import 'package:enterprise_mvvm/core/services/app_logger.dart';
import 'package:enterprise_mvvm/core/services/connectivity_service.dart';
import 'package:enterprise_mvvm/core/services/crash_reporter.dart';
import 'package:enterprise_mvvm/core/services/feature_flags.dart';
import 'package:enterprise_mvvm/core/session/session_repository.dart';
import 'package:enterprise_mvvm/core/storage/preferences_store.dart';
import 'package:enterprise_mvvm/core/storage/secure_store.dart';
import 'package:enterprise_mvvm/core/storage/storage_keys.dart';
import 'package:enterprise_mvvm/core/storage/token_store.dart';
import 'package:enterprise_mvvm/core/theme/locale_cubit.dart';
import 'package:enterprise_mvvm/core/theme/theme_cubit.dart';
import 'package:enterprise_mvvm/features/auth/domain/repositories/auth_repository.dart';
import 'package:enterprise_mvvm/features/products/domain/repositories/product_repository.dart';
import 'package:get_it/get_it.dart';

Future<AppContainer> buildContainer(
  AppConfig config, {
  PreferencesStore? preferencesStore,
}) async {
  final preferences = preferencesStore ?? await PreferencesStore.open();
  final secure = FlutterSecureStore();
  final tokenStore = TokenStore(secure);
  final AppLogger logger = config.flavor == AppFlavor.prod
      ? const NoopAppLogger()
      : ConsoleAppLogger(enabled: true);
  const crashReporter = NoopCrashReporter();
  const analytics = NoopAnalyticsService();
  const connectivity = DefaultConnectivityService();
  const flags = NoopFeatureFlags();
  final authEvents = AuthEvents();
  const policy = AccessPolicy();
  final apiDio = createBaseDio(config);
  final refreshDio = createBaseDio(config);
  if (config.enableHttpLogs) {
    refreshDio.interceptors.add(RedactingLogInterceptor(logger));
  }

  final getIt = GetIt.asNewInstance();
  getIt
    ..registerSingleton<AppConfig>(config)
    ..registerSingleton<AppLogger>(logger)
    ..registerSingleton<CrashReporter>(crashReporter)
    ..registerSingleton<AnalyticsService>(analytics)
    ..registerSingleton<ConnectivityService>(connectivity)
    ..registerSingleton<FeatureFlags>(flags)
    ..registerSingleton<AuthEvents>(authEvents)
    ..registerSingleton<AccessPolicy>(policy)
    ..registerSingleton<SecureStore>(secure)
    ..registerSingleton<PreferencesStore>(preferences)
    ..registerSingleton<TokenStore>(tokenStore)
    ..registerSingleton<Dio>(apiDio)
    ..registerSingleton<Dio>(refreshDio, instanceName: DioNames.refresh);

  registerFeatures(getIt);

  final themeCubit = ThemeCubit(
    preferences,
    initial: ThemeCubit.fromName(preferences.read(StorageKeys.themeMode)),
  );
  final localeCubit = LocaleCubit(
    preferences,
    initial: LocaleCubit.fromCode(preferences.read(StorageKeys.locale)),
  );
  getIt
    ..registerSingleton<ThemeCubit>(themeCubit)
    ..registerSingleton<LocaleCubit>(localeCubit);

  final dependencies = AppDependencies(
    config: config,
    authRepository: getIt<AuthRepository>(),
    sessionRepository: getIt<SessionRepository>(),
    productRepository: getIt<ProductRepository>(),
    themeCubit: themeCubit,
    localeCubit: localeCubit,
    connectivity: connectivity,
    accessPolicy: policy,
  );

  return AppContainer(
    getIt: getIt,
    dependencies: dependencies,
    registerRoleScope: (GetIt scope, AppRole role) {
      for (final module in buildRoleModules()) {
        if (module.role == role) {
          module.registerScope(scope);
          return;
        }
      }
      throw StateError('No role module registered for ${role.name}.');
    },
  );
}
