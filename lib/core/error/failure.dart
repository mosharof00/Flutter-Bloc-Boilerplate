import 'package:equatable/equatable.dart';

/// A failure the UI can show. [messageKey] is an l10n key, never a raw sentence.
sealed class Failure with Equatable {
  const Failure(this.messageKey);

  final String messageKey;

  @override
  List<Object?> get props => <Object?>[messageKey];
}

final class NetworkFailure extends Failure {
  const NetworkFailure() : super('failureNetwork');
}

final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure() : super('failureUnauthorized');
}

final class ValidationFailure extends Failure {
  const ValidationFailure() : super('failureValidation');
}

final class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure() : super('failureInvalidCredentials');
}

final class ServerFailure extends Failure {
  const ServerFailure() : super('failureServer');
}

final class CacheFailure extends Failure {
  const CacheFailure() : super('failureCache');
}

final class ForbiddenFailure extends Failure {
  const ForbiddenFailure() : super('failureForbidden');
}

final class UnknownFailure extends Failure {
  const UnknownFailure([this.cause]) : super('failureUnknown');

  final Object? cause;

  @override
  List<Object?> get props => <Object?>[messageKey, cause];
}
