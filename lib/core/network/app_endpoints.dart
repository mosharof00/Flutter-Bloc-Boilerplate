import 'package:enterprise_mvvm/core/config/app_config.dart';

/// Catalog host selection for the products sample feature.
///
/// Dev uses the public DummyJSON demo so the fetch cycle works without a
/// backend. Staging and prod use [AppConfig.baseUrl] so a forgotten sample
/// cannot ship traffic to a public demo API.
abstract final class AppEndpoints {
  static const productsDemoBaseUrl = 'https://dummyjson.com';

  static String productsBaseUrl(AppConfig config) {
    return config.useFakeServices ? productsDemoBaseUrl : config.baseUrl;
  }
}
