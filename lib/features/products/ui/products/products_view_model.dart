import 'package:enterprise_mvvm/core/result/result.dart';
import 'package:enterprise_mvvm/core/ui/view_model/base_view_model.dart';
import 'package:enterprise_mvvm/core/ui/view_model/paginated_view_model.dart';
import 'package:enterprise_mvvm/features/products/domain/models/product.dart';
import 'package:enterprise_mvvm/features/products/domain/repositories/product_repository.dart';

final class ProductsViewModel extends BaseViewModel<PaginatedState<Product>>
    with PaginatedViewModel<Product> {
  ProductsViewModel(this._repository) : super(const PaginatedIdle<Product>());

  final ProductRepository _repository;

  @override
  Future<Result<PageResult<Product>>> loadPage({
    required int page,
    String? cursor,
  }) async {
    final result = await _repository.fetch(page: page);
    return result.fold(
      onSuccess: (ProductPage value) => Success<PageResult<Product>>(
        PageResult<Product>(items: value.items, hasMore: value.hasMore),
      ),
      onFailure: Err<PageResult<Product>>.new,
    );
  }
}
