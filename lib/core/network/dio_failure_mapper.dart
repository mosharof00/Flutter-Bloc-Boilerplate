import 'package:dio/dio.dart';
import 'package:enterprise_mvvm/core/error/app_exception.dart';

AppException mapDioException(DioException exception) {
  return switch (exception.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout ||
    DioExceptionType.transformTimeout ||
    DioExceptionType.connectionError => const NetworkException(),
    DioExceptionType.badResponse => _fromStatus(exception.response?.statusCode),
    DioExceptionType.cancel ||
    DioExceptionType.badCertificate ||
    DioExceptionType.unknown => UnknownException(exception),
  };
}

AppException _fromStatus(int? status) {
  return switch (status) {
    401 => const UnauthorizedException(),
    403 => const ForbiddenException(),
    400 || 422 => const ValidationException(),
    _ => const ServerException(),
  };
}
