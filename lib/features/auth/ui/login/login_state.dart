import 'package:enterprise_mvvm/core/error/failure.dart';
import 'package:equatable/equatable.dart';

sealed class LoginState with Equatable {
  const LoginState();
}

final class LoginInitial extends LoginState {
  const LoginInitial();

  @override
  List<Object?> get props => const <Object?>[];
}

final class LoginLoading extends LoginState {
  const LoginLoading();

  @override
  List<Object?> get props => const <Object?>[];
}

final class LoginSuccess extends LoginState {
  const LoginSuccess();

  @override
  List<Object?> get props => const <Object?>[];
}

final class LoginFailure extends LoginState {
  const LoginFailure(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => <Object?>[failure];
}
