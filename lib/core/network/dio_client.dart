import 'package:dio/dio.dart';
import 'package:enterprise_mvvm/core/config/app_config.dart';
import 'package:enterprise_mvvm/core/network/app_endpoints.dart';
import 'package:enterprise_mvvm/core/network/auth_events.dart';
import 'package:enterprise_mvvm/core/network/auth_interceptor.dart';
import 'package:enterprise_mvvm/core/network/redacting_log_interceptor.dart';
import 'package:enterprise_mvvm/core/network/token_refresh_interceptor.dart';
import 'package:enterprise_mvvm/core/network/token_refresher.dart';
import 'package:enterprise_mvvm/core/services/app_logger.dart';
import 'package:enterprise_mvvm/core/storage/token_store.dart';

abstract final class DioNames {
  static const refresh = 'refresh';
  static const catalog = 'catalog';
}

BaseOptions dioOptions(AppConfig config) {
  return BaseOptions(
    baseUrl: config.baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 20),
    headers: <String, Object>{
      Headers.acceptHeader: Headers.jsonContentType,
      Headers.contentTypeHeader: Headers.jsonContentType,
    },
  );
}

BaseOptions catalogDioOptions(AppConfig config) {
  return BaseOptions(
    baseUrl: AppEndpoints.productsBaseUrl(config),
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 20),
    headers: <String, Object>{
      Headers.acceptHeader: Headers.jsonContentType,
      Headers.contentTypeHeader: Headers.jsonContentType,
    },
  );
}

Dio createBaseDio(AppConfig config) => Dio(dioOptions(config));

Dio createCatalogDio(AppConfig config) => Dio(catalogDioOptions(config));

void addApiInterceptors({
  required Dio dio,
  required AppConfig config,
  required TokenStore tokenStore,
  required TokenRefresher refresher,
  required AuthEvents authEvents,
  required AppLogger logger,
}) {
  dio.interceptors.add(AuthInterceptor(tokenStore));
  dio.interceptors.add(
    TokenRefreshInterceptor(
      dio: dio,
      tokenStore: tokenStore,
      refresher: refresher,
      authEvents: authEvents,
    ),
  );
  if (config.enableHttpLogs) {
    dio.interceptors.add(RedactingLogInterceptor(logger));
  }
}
