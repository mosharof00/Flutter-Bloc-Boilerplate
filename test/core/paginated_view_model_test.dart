import 'package:enterprise_mvvm/core/error/failure.dart';
import 'package:enterprise_mvvm/core/result/result.dart';
import 'package:enterprise_mvvm/core/ui/view_model/base_view_model.dart';
import 'package:enterprise_mvvm/core/ui/view_model/paginated_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('refresh, load more, end of list, and retry', () async {
    final viewModel = _NumbersViewModel(<Result<PageResult<int>>>[
      const Success<PageResult<int>>(
        PageResult<int>(items: <int>[1], hasMore: true, nextCursor: 'a'),
      ),
      const Err<PageResult<int>>(NetworkFailure()),
      const Success<PageResult<int>>(
        PageResult<int>(items: <int>[2], hasMore: false),
      ),
    ]);

    await viewModel.refresh();
    expect(
      viewModel.state,
      isA<PaginatedReady<int>>()
          .having((PaginatedReady<int> state) => state.items, 'items', <int>[1])
          .having(
            (PaginatedReady<int> state) => state.hasMore,
            'hasMore',
            isTrue,
          ),
    );

    await viewModel.loadMore();
    final afterError = viewModel.state as PaginatedReady<int>;
    expect(afterError.items, <int>[1]);
    expect(afterError.loadMoreFailure, isA<NetworkFailure>());

    await viewModel.loadMore();
    final loaded = viewModel.state as PaginatedReady<int>;
    expect(loaded.items, <int>[1, 2]);
    expect(loaded.hasMore, isFalse);

    final calls = viewModel.calls;
    await viewModel.loadMore();
    expect(viewModel.calls, calls);
    await viewModel.close();
  });
}

final class _NumbersViewModel extends BaseViewModel<PaginatedState<int>>
    with PaginatedViewModel<int> {
  _NumbersViewModel(this._pages) : super(const PaginatedIdle<int>());

  final List<Result<PageResult<int>>> _pages;
  int calls = 0;

  @override
  Future<Result<PageResult<int>>> loadPage({
    required int page,
    String? cursor,
  }) async {
    final result = _pages[calls];
    calls += 1;
    return result;
  }
}
