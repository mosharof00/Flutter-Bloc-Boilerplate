import 'package:enterprise_mvvm/core/config/app_flavor.dart';
import 'package:enterprise_mvvm/features/products/data/dto/product_dto.dart';
import 'package:enterprise_mvvm/features/products/data/services/product_api_service.dart';

/// In-memory catalog so the product list can page without a backend.
final class FakeProductApiService implements ProductApiService {
  FakeProductApiService({required AppFlavor flavor}) {
    assert(
      flavor != AppFlavor.prod,
      'FakeProductApiService must not be used in prod.',
    );
    if (flavor == AppFlavor.prod) {
      throw StateError('FakeProductApiService must not be used in prod.');
    }
  }

  static const catalog = <ProductDto>[
    ProductDto(id: 1, title: 'Notebook', price: 12.5),
    ProductDto(id: 2, title: 'Desk lamp', price: 24),
    ProductDto(id: 3, title: 'Ceramic mug', price: 8.75),
    ProductDto(id: 4, title: 'Backpack', price: 46),
    ProductDto(id: 5, title: 'Keyboard', price: 79),
    ProductDto(id: 6, title: 'Headphones', price: 59.5),
    ProductDto(id: 7, title: 'Water bottle', price: 15),
    ProductDto(id: 8, title: 'Notebook stand', price: 32),
    ProductDto(id: 9, title: 'Pen set', price: 6.25),
    ProductDto(id: 10, title: 'Monitor', price: 220),
    ProductDto(id: 11, title: 'Chair', price: 140),
    ProductDto(id: 12, title: 'Plant', price: 18),
  ];

  @override
  Future<ProductPageDto> fetch({required int limit, required int skip}) async {
    final products = catalog.skip(skip).take(limit).toList();
    return ProductPageDto(
      products: products,
      total: catalog.length,
      skip: skip,
      limit: limit,
    );
  }
}
