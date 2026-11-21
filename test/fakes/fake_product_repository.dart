import 'package:enterprise_mvvm/core/result/result.dart';
import 'package:enterprise_mvvm/features/products/domain/models/product.dart';
import 'package:enterprise_mvvm/features/products/domain/repositories/product_repository.dart';

final class FakeProductRepository implements ProductRepository {
  @override
  Future<Result<ProductPage>> fetch({required int page}) async {
    return const Success<ProductPage>(
      ProductPage(items: <Product>[], hasMore: false),
    );
  }
}
