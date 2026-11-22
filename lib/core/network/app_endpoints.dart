/// Public demo catalog used by the products feature.
///
/// Auth still uses [AppConfig.baseUrl]. Products use this host so the fetch
/// cycle works without a real backend.
abstract final class AppEndpoints {
  static const productsBaseUrl = 'https://dummyjson.com';
}
