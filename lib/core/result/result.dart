import 'package:enterprise_mvvm/core/error/failure.dart';
import 'package:equatable/equatable.dart';

sealed class Result<T> with Equatable {
  const Result();

  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(Failure failure) onFailure,
  }) {
    return switch (this) {
      Success<T>(:final value) => onSuccess(value),
      Err<T>(:final failure) => onFailure(failure),
    };
  }
}

final class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;

  @override
  List<Object?> get props => <Object?>[value];
}

final class Err<T> extends Result<T> {
  const Err(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => <Object?>[failure];
}
