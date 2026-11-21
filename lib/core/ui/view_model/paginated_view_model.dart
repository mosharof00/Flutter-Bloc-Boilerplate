import 'package:enterprise_mvvm/core/error/failure.dart';
import 'package:enterprise_mvvm/core/result/result.dart';
import 'package:enterprise_mvvm/core/ui/view_model/base_view_model.dart';
import 'package:equatable/equatable.dart';

final class PageResult<T> with Equatable {
  const PageResult({
    required this.items,
    required this.hasMore,
    this.nextCursor,
  });

  final List<T> items;
  final bool hasMore;
  final String? nextCursor;

  @override
  List<Object?> get props => <Object?>[items, hasMore, nextCursor];
}

sealed class PaginatedState<T> with Equatable {
  const PaginatedState();
}

final class PaginatedIdle<T> extends PaginatedState<T> {
  const PaginatedIdle();

  @override
  List<Object?> get props => const <Object?>[];
}

final class PaginatedLoading<T> extends PaginatedState<T> {
  const PaginatedLoading();

  @override
  List<Object?> get props => const <Object?>[];
}

final class PaginatedReady<T> extends PaginatedState<T> {
  const PaginatedReady({
    required this.items,
    required this.hasMore,
    this.nextCursor,
    this.page = 1,
    this.isLoadingMore = false,
    this.loadMoreFailure,
  });

  final List<T> items;
  final bool hasMore;
  final String? nextCursor;
  final int page;
  final bool isLoadingMore;
  final Failure? loadMoreFailure;

  @override
  List<Object?> get props => <Object?>[
    items,
    hasMore,
    nextCursor,
    page,
    isLoadingMore,
    loadMoreFailure,
  ];
}

final class PaginatedFailure<T> extends PaginatedState<T> {
  const PaginatedFailure(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => <Object?>[failure];
}

/// Page or cursor loading for lists. The subclass only implements [loadPage].
mixin PaginatedViewModel<T> on BaseViewModel<PaginatedState<T>> {
  Future<Result<PageResult<T>>> loadPage({required int page, String? cursor});

  Future<void> refresh() async {
    safeEmit(PaginatedLoading<T>());
    final result = await loadPage(page: 1);
    switch (result) {
      case Success<PageResult<T>>(:final value):
        safeEmit(
          PaginatedReady<T>(
            items: value.items,
            hasMore: value.hasMore,
            nextCursor: value.nextCursor,
          ),
        );
      case Err<PageResult<T>>(:final failure):
        safeEmit(PaginatedFailure<T>(failure));
    }
  }

  Future<void> loadMore() async {
    final current = state;
    if (current is! PaginatedReady<T> ||
        !current.hasMore ||
        current.isLoadingMore) {
      return;
    }
    safeEmit(
      PaginatedReady<T>(
        items: current.items,
        hasMore: current.hasMore,
        nextCursor: current.nextCursor,
        page: current.page,
        isLoadingMore: true,
      ),
    );
    final result = await loadPage(
      page: current.page + 1,
      cursor: current.nextCursor,
    );
    switch (result) {
      case Success<PageResult<T>>(:final value):
        safeEmit(
          PaginatedReady<T>(
            items: <T>[...current.items, ...value.items],
            hasMore: value.hasMore,
            nextCursor: value.nextCursor,
            page: current.page + 1,
          ),
        );
      case Err<PageResult<T>>(:final failure):
        safeEmit(
          PaginatedReady<T>(
            items: current.items,
            hasMore: current.hasMore,
            nextCursor: current.nextCursor,
            page: current.page,
            loadMoreFailure: failure,
          ),
        );
    }
  }

  Future<void> retry() => refresh();
}
