import 'package:dio/dio.dart';
import 'package:enterprise_mvvm/core/config/app_config.dart';
import 'package:enterprise_mvvm/core/config/app_flavor.dart';
import 'package:enterprise_mvvm/features/products/data/repositories/product_repository_impl.dart';
import 'package:enterprise_mvvm/features/products/data/services/fake_product_api_service.dart';
import 'package:enterprise_mvvm/features/products/data/services/product_api_service.dart';
import 'package:enterprise_mvvm/features/products/data/services/product_api_service_impl.dart';
import 'package:enterprise_mvvm/features/products/domain/repositories/product_repository.dart';
import 'package:get_it/get_it.dart';

void registerProducts(GetIt getIt) {
  final config = getIt<AppConfig>();
  final ProductApiService api;
  if (config.useFakeServices) {
    assert(
      config.flavor != AppFlavor.prod,
      'Fake product services are not registered in prod.',
    );
    api = FakeProductApiService(flavor: config.flavor);
  } else {
    api = ProductApiServiceImpl(getIt<Dio>());
  }
  getIt
    ..registerSingleton<ProductApiService>(api)
    ..registerSingleton<ProductRepository>(ProductRepositoryImpl(api));
}
