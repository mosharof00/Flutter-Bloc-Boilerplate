import 'package:enterprise_mvvm/core/result/result.dart';
import 'package:enterprise_mvvm/features/products/domain/models/product.dart';

final class ProductPage {
  const ProductPage({required this.items, required this.hasMore});

  final List<Product> items;
  final bool hasMore;
}

abstract interface class ProductRepository {
  Future<Result<ProductPage>> fetch({required int page});
}
