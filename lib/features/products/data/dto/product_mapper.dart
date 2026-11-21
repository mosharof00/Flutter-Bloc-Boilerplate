import 'package:enterprise_mvvm/features/products/data/dto/product_dto.dart';
import 'package:enterprise_mvvm/features/products/domain/models/product.dart';

extension ProductDtoMapper on ProductDto {
  Product toDomain() {
    return Product(id: id, title: title, price: price, thumbnail: thumbnail);
  }
}
