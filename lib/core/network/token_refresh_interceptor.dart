import 'package:dio/dio.dart';
import 'package:enterprise_mvvm/core/network/anonymous_paths.dart';
import 'package:enterprise_mvvm/core/network/auth_events.dart';
import 'package:enterprise_mvvm/core/network/token_refresher.dart';
import 'package:enterprise_mvvm/core/storage/token_store.dart';

/// Retries one 401 after a single in-flight refresh. Concurrent 401s share
/// that refresh. A failed refresh emits [AuthEvents.sessionExpired].
final class TokenRefreshInterceptor extends Interceptor {
  TokenRefreshInterceptor({
    required this._dio,
    required this._tokenStore,
    required this._refresher,
    required this._authEvents,
  });

  final Dio _dio;
  final TokenStore _tokenStore;
  final TokenRefresher _refresher;
  final AuthEvents _authEvents;

  static const retriedKey = 'retried';

  Future<String?>? _inFlight;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final status = err.response?.statusCode;
    final options = err.requestOptions;
    final alreadyRetried = options.extra[retriedKey] == true;
    if (status != 401 ||
        alreadyRetried ||
        AnonymousPaths.matches(options.uri)) {
      handler.next(err);
      return;
    }

    try {
      final token = await _singleFlight();
      if (token == null) {
        _authEvents.notifySessionExpired();
        handler.next(err);
        return;
      }
      options.extra[retriedKey] = true;
      options.headers['Authorization'] = 'Bearer $token';
      final response = await _dio.fetch<dynamic>(options);
      handler.resolve(response);
    } on Object {
      _authEvents.notifySessionExpired();
      handler.next(err);
    }
  }

  Future<String?> _singleFlight() {
    final existing = _inFlight;
    if (existing != null) {
      return existing;
    }
    final future = _refresh();
    _inFlight = future;
    return future.whenComplete(() {
      if (identical(_inFlight, future)) {
        _inFlight = null;
      }
    });
  }

  Future<String?> _refresh() async {
    final refreshToken = await _tokenStore.readRefresh();
    if (refreshToken == null || refreshToken.isEmpty) {
      return null;
    }
    final tokens = await _refresher.refresh(refreshToken);
    await _tokenStore.write(
      access: tokens.accessToken,
      refresh: tokens.refreshToken,
    );
    return tokens.accessToken;
  }
}
