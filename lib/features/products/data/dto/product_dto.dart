import 'package:json_annotation/json_annotation.dart';

part 'product_dto.g.dart';

@JsonSerializable()
class ProductDto {
  const ProductDto({
    required this.id,
    required this.title,
    required this.price,
    this.thumbnail,
  });

  factory ProductDto.fromJson(Map<String, dynamic> json) =>
      _$ProductDtoFromJson(json);

  final int id;
  final String title;
  final double price;
  final String? thumbnail;

  Map<String, dynamic> toJson() => _$ProductDtoToJson(this);
}

@JsonSerializable()
class ProductPageDto {
  const ProductPageDto({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
  });

  factory ProductPageDto.fromJson(Map<String, dynamic> json) =>
      _$ProductPageDtoFromJson(json);

  final List<ProductDto> products;
  final int total;
  final int skip;
  final int limit;

  Map<String, dynamic> toJson() => _$ProductPageDtoToJson(this);
}
