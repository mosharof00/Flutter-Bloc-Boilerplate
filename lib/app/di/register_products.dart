import 'package:dio/dio.dart';
import 'package:enterprise_mvvm/core/config/app_config.dart';
import 'package:enterprise_mvvm/core/network/dio_client.dart';
import 'package:enterprise_mvvm/core/network/redacting_log_interceptor.dart';
import 'package:enterprise_mvvm/core/services/app_logger.dart';
import 'package:enterprise_mvvm/features/products/data/repositories/product_repository_impl.dart';
import 'package:enterprise_mvvm/features/products/data/services/product_api_service.dart';
import 'package:enterprise_mvvm/features/products/data/services/product_api_service_impl.dart';
import 'package:enterprise_mvvm/features/products/domain/repositories/product_repository.dart';
import 'package:get_it/get_it.dart';

void registerProducts(GetIt getIt) {
  final config = getIt<AppConfig>();
  final catalogDio = createCatalogDio(config);
  if (config.enableHttpLogs) {
    catalogDio.interceptors.add(RedactingLogInterceptor(getIt<AppLogger>()));
  }
  getIt
    ..registerSingleton<Dio>(catalogDio, instanceName: DioNames.catalog)
    ..registerSingleton<ProductApiService>(ProductApiServiceImpl(catalogDio))
    ..registerSingleton<ProductRepository>(
      ProductRepositoryImpl(getIt<ProductApiService>()),
    );
}
