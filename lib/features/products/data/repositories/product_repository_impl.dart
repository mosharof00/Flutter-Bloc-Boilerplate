import 'package:enterprise_mvvm/core/error/app_exception.dart';
import 'package:enterprise_mvvm/core/error/failure.dart';
import 'package:enterprise_mvvm/core/result/result.dart';
import 'package:enterprise_mvvm/features/products/data/dto/product_mapper.dart';
import 'package:enterprise_mvvm/features/products/data/services/product_api_service.dart';
import 'package:enterprise_mvvm/features/products/domain/repositories/product_repository.dart';

final class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl(this._api);

  final ProductApiService _api;

  static const pageSize = 10;

  @override
  Future<Result<ProductPage>> fetch({required int page}) async {
    final skip = (page - 1) * pageSize;
    try {
      final response = await _api.fetch(limit: pageSize, skip: skip);
      final items = response.products.map((dto) => dto.toDomain()).toList();
      return Success<ProductPage>(
        ProductPage(
          items: items,
          hasMore: skip + items.length < response.total,
        ),
      );
    } on NetworkException {
      return const Err<ProductPage>(NetworkFailure());
    } on UnauthorizedException {
      return const Err<ProductPage>(UnauthorizedFailure());
    } on AppException {
      return const Err<ProductPage>(UnknownFailure());
    }
  }
}
