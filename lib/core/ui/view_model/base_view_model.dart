import 'package:enterprise_mvvm/core/error/failure.dart';
import 'package:enterprise_mvvm/core/result/result.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

/// Cubit base for view models.
///
/// [run] is the command: it emits loading, maps a [Result] to success or
/// failure, and ignores a second call while the first is still running.
abstract class BaseViewModel<S> extends Cubit<S> {
  BaseViewModel(super.initialState);

  var _running = false;

  @protected
  void safeEmit(S next) {
    if (isClosed) {
      return;
    }
    emit(next);
  }

  @protected
  Future<void> run<T>({
    required Future<Result<T>> Function() action,
    required S Function() onLoading,
    required S Function(T value) onSuccess,
    required S Function(Failure failure) onFailure,
  }) async {
    if (_running) {
      return;
    }
    _running = true;
    safeEmit(onLoading());
    try {
      final result = await action();
      if (isClosed) {
        return;
      }
      switch (result) {
        case Success<T>(:final value):
          safeEmit(onSuccess(value));
        case Err<T>(:final failure):
          safeEmit(onFailure(failure));
      }
    } on Object catch (error) {
      safeEmit(onFailure(UnknownFailure(error)));
    } finally {
      _running = false;
    }
  }
}
