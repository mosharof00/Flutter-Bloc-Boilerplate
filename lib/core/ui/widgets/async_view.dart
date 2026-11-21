import 'package:enterprise_mvvm/core/ui/view_model/view_state.dart';
import 'package:enterprise_mvvm/core/ui/widgets/empty_view.dart';
import 'package:enterprise_mvvm/core/ui/widgets/error_view.dart';
import 'package:enterprise_mvvm/core/ui/widgets/shimmer_list.dart';
import 'package:flutter/material.dart';

class AsyncView<T> extends StatelessWidget {
  const AsyncView({
    super.key,
    required this.state,
    required this.onData,
    this.onRetry,
    this.isEmpty,
  });

  final ViewState<T> state;
  final Widget Function(T data) onData;
  final VoidCallback? onRetry;
  final bool Function(T data)? isEmpty;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      ViewIdle<T>() || ViewLoading<T>() => const ShimmerList(),
      ViewFailure<T>(:final failure) => ErrorView(
        failure: failure,
        onRetry: onRetry,
      ),
      ViewSuccess<T>(:final data) =>
        (isEmpty?.call(data) ?? false) ? const EmptyView() : onData(data),
    };
  }
}
