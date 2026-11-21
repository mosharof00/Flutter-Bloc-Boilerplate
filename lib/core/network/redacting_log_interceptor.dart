import 'package:dio/dio.dart';
import 'package:enterprise_mvvm/core/network/redaction.dart';
import 'package:enterprise_mvvm/core/services/app_logger.dart';

final class RedactingLogInterceptor extends Interceptor {
  RedactingLogInterceptor(this._logger);

  final AppLogger _logger;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.info(
      '--> ${options.method} ${options.uri} '
      'headers=${redactHeaders(options.headers)} '
      'body=${redactSensitive(options.data)}',
    );
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _logger.info(
      '<-- ${response.statusCode} ${response.requestOptions.uri} '
      'body=${redactSensitive(response.data)}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.warning(
      'xx ${err.response?.statusCode ?? '-'} ${err.requestOptions.uri} ${err.type}',
    );
    handler.next(err);
  }
}
