import 'package:enterprise_mvvm/core/error/failure.dart';
import 'package:equatable/equatable.dart';

sealed class ViewState<T> with Equatable {
  const ViewState();
}

final class ViewIdle<T> extends ViewState<T> {
  const ViewIdle();

  @override
  List<Object?> get props => const <Object?>[];
}

final class ViewLoading<T> extends ViewState<T> {
  const ViewLoading();

  @override
  List<Object?> get props => const <Object?>[];
}

final class ViewSuccess<T> extends ViewState<T> {
  const ViewSuccess(this.data);

  final T data;

  @override
  List<Object?> get props => <Object?>[data];
}

final class ViewFailure<T> extends ViewState<T> {
  const ViewFailure(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => <Object?>[failure];
}
