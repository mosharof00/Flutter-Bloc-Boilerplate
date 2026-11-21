import 'package:dio/dio.dart';
import 'package:enterprise_mvvm/core/network/anonymous_paths.dart';
import 'package:enterprise_mvvm/core/storage/token_store.dart';

final class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._tokenStore);

  final TokenStore _tokenStore;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!AnonymousPaths.matches(options.uri)) {
      final token = await _tokenStore.readAccess();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }
}
