import 'package:enterprise_mvvm/core/network/json_body.dart';

final class ProductDto {
  const ProductDto({
    required this.id,
    required this.title,
    required this.price,
    this.thumbnail,
  });

  factory ProductDto.fromJson(Map<String, dynamic> json) {
    return ProductDto(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      thumbnail: json['thumbnail'] as String?,
    );
  }

  final int id;
  final String title;
  final double price;
  final String? thumbnail;
}

final class ProductPageDto {
  const ProductPageDto({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
  });

  factory ProductPageDto.fromJson(Map<String, dynamic> json) {
    final raw = json['products'];
    final products = <ProductDto>[];
    if (raw is List<dynamic>) {
      for (final item in raw) {
        products.add(ProductDto.fromJson(asJsonMap(item)));
      }
    }
    return ProductPageDto(
      products: products,
      total: json['total'] as int? ?? products.length,
      skip: json['skip'] as int? ?? 0,
      limit: json['limit'] as int? ?? products.length,
    );
  }

  final List<ProductDto> products;
  final int total;
  final int skip;
  final int limit;
}
