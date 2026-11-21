import 'package:dio/dio.dart';
import 'package:enterprise_mvvm/app/di/api_token_refresher.dart';
import 'package:enterprise_mvvm/core/config/app_config.dart';
import 'package:enterprise_mvvm/core/config/app_flavor.dart';
import 'package:enterprise_mvvm/core/network/auth_events.dart';
import 'package:enterprise_mvvm/core/network/dio_client.dart';
import 'package:enterprise_mvvm/core/services/app_logger.dart';
import 'package:enterprise_mvvm/core/session/session_repository.dart';
import 'package:enterprise_mvvm/core/storage/preferences_store.dart';
import 'package:enterprise_mvvm/core/storage/secure_store.dart';
import 'package:enterprise_mvvm/core/storage/token_store.dart';
import 'package:enterprise_mvvm/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:enterprise_mvvm/features/auth/data/services/auth_api_service.dart';
import 'package:enterprise_mvvm/features/auth/data/services/auth_api_service_impl.dart';
import 'package:enterprise_mvvm/features/auth/data/services/auth_local_service.dart';
import 'package:enterprise_mvvm/features/auth/data/services/fake_auth_api_service.dart';
import 'package:enterprise_mvvm/features/auth/domain/repositories/auth_repository.dart';
import 'package:get_it/get_it.dart';

void registerAuth(GetIt getIt) {
  final config = getIt<AppConfig>();
  final apiDio = getIt<Dio>();
  final refreshDio = getIt<Dio>(instanceName: DioNames.refresh);
  final AuthApiService api;
  if (config.useFakeServices) {
    assert(
      config.flavor != AppFlavor.prod,
      'Fake auth services are not registered in prod.',
    );
    api = FakeAuthApiService(flavor: config.flavor);
  } else {
    api = AuthApiServiceImpl(dio: apiDio, refreshDio: refreshDio);
  }

  addApiInterceptors(
    dio: apiDio,
    config: config,
    tokenStore: getIt<TokenStore>(),
    refresher: ApiTokenRefresher(api),
    authEvents: getIt<AuthEvents>(),
    logger: getIt<AppLogger>(),
  );

  final local = AuthLocalService(
    secure: getIt<SecureStore>(),
    preferences: getIt<PreferencesStore>(),
  );
  final repository = AuthRepositoryImpl(
    api: api,
    local: local,
    authEvents: getIt<AuthEvents>(),
  );

  getIt
    ..registerSingleton<AuthApiService>(api)
    ..registerSingleton<AuthLocalService>(local)
    ..registerSingleton<AuthRepositoryImpl>(repository)
    ..registerSingleton<AuthRepository>(repository)
    ..registerSingleton<SessionRepository>(repository);
}
