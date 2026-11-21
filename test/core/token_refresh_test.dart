import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:enterprise_mvvm/core/network/auth_events.dart';
import 'package:enterprise_mvvm/core/network/auth_interceptor.dart';
import 'package:enterprise_mvvm/core/network/auth_tokens.dart';
import 'package:enterprise_mvvm/core/network/token_refresh_interceptor.dart';
import 'package:enterprise_mvvm/core/network/token_refresher.dart';
import 'package:enterprise_mvvm/core/storage/token_store.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/memory_secure_store.dart';

void main() {
  test('concurrent 401s share one refresh and then succeed', () async {
    final store = TokenStore(MemorySecureStore());
    await store.write(access: 'old', refresh: 'refresh-token');
    final refresher = _CountingRefresher();
    final events = AuthEvents();
    final dio = _dio(
      store: store,
      refresher: refresher,
      events: events,
      adapter: (RequestOptions options) async {
        final header = options.headers['Authorization'];
        final status = header == 'Bearer new' ? 200 : 401;
        return _body(status);
      },
    );

    final responses = await Future.wait<Response<dynamic>>(
      <Future<Response<dynamic>>>[
        dio.get<dynamic>('/items'),
        dio.get<dynamic>('/items'),
      ],
    );

    expect(refresher.calls, 1);
    expect(responses.map((Response<dynamic> response) => response.statusCode), [
      200,
      200,
    ]);
    expect(await store.readAccess(), 'new');
    await events.dispose();
  });

  test('a failed refresh expires the session once', () async {
    final store = TokenStore(MemorySecureStore());
    await store.write(access: 'old', refresh: 'refresh-token');
    final refresher = _CountingRefresher()..fail = true;
    final events = AuthEvents();
    final dio = _dio(
      store: store,
      refresher: refresher,
      events: events,
      adapter: (RequestOptions options) async => _body(401),
    );

    final expired = events.sessionExpired.first;
    await expectLater(dio.get<dynamic>('/items'), throwsA(isA<DioException>()));
    await expired;
    expect(refresher.calls, 1);
    await events.dispose();
  });
}

Dio _dio({
  required TokenStore store,
  required TokenRefresher refresher,
  required AuthEvents events,
  required Future<ResponseBody> Function(RequestOptions options) adapter,
}) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
  dio.httpClientAdapter = _ScriptedAdapter(adapter);
  dio.interceptors
    ..add(AuthInterceptor(store))
    ..add(
      TokenRefreshInterceptor(
        dio: dio,
        tokenStore: store,
        refresher: refresher,
        authEvents: events,
      ),
    );
  return dio;
}

ResponseBody _body(int status) {
  return ResponseBody.fromString(
    jsonEncode(<String, Object>{'ok': status == 200}),
    status,
    headers: <String, List<String>>{
      Headers.contentTypeHeader: <String>[Headers.jsonContentType],
    },
  );
}

final class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter(this._handler);

  final Future<ResponseBody> Function(RequestOptions options) _handler;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return _handler(options);
  }
}

final class _CountingRefresher implements TokenRefresher {
  int calls = 0;
  bool fail = false;

  @override
  Future<AuthTokens> refresh(String refreshToken) async {
    calls += 1;
    await Future<void>.delayed(const Duration(milliseconds: 40));
    if (fail) {
      throw StateError('refresh failed');
    }
    return const AuthTokens(accessToken: 'new', refreshToken: 'refresh-token');
  }
}
