import 'package:enterprise_mvvm/core/error/failure.dart';
import 'package:enterprise_mvvm/l10n/app_localizations.dart';

String failureMessage(AppLocalizations l10n, Failure failure) {
  return switch (failure) {
    NetworkFailure() => l10n.failureNetwork,
    UnauthorizedFailure() => l10n.failureUnauthorized,
    ValidationFailure() => l10n.failureValidation,
    InvalidCredentialsFailure() => l10n.failureInvalidCredentials,
    ServerFailure() => l10n.failureServer,
    CacheFailure() => l10n.failureCache,
    ForbiddenFailure() => l10n.failureForbidden,
    UnknownFailure() => l10n.failureUnknown,
  };
}
