/// Exceptions thrown by services. Repositories map these to [Failure]s.
sealed class AppException implements Exception {
  const AppException();
}

final class InvalidCredentialsException extends AppException {
  const InvalidCredentialsException();
}

final class UnauthorizedException extends AppException {
  const UnauthorizedException();
}

final class ForbiddenException extends AppException {
  const ForbiddenException();
}

final class ValidationException extends AppException {
  const ValidationException();
}

final class NetworkException extends AppException {
  const NetworkException();
}

final class ServerException extends AppException {
  const ServerException();
}

final class CacheException extends AppException {
  const CacheException();
}

final class UnknownException extends AppException {
  const UnknownException([this.cause]);

  final Object? cause;
}
