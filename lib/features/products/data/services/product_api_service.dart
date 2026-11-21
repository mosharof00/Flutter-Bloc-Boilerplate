import 'package:enterprise_mvvm/features/products/data/dto/product_dto.dart';

abstract interface class ProductApiService {
  Future<ProductPageDto> fetch({required int limit, required int skip});
}
