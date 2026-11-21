import 'package:dio/dio.dart';
import 'package:enterprise_mvvm/core/network/dio_failure_mapper.dart';
import 'package:enterprise_mvvm/core/network/json_body.dart';
import 'package:enterprise_mvvm/features/products/data/dto/product_dto.dart';
import 'package:enterprise_mvvm/features/products/data/services/product_api_service.dart';

final class ProductApiServiceImpl implements ProductApiService {
  ProductApiServiceImpl(this._dio);

  final Dio _dio;

  @override
  Future<ProductPageDto> fetch({required int limit, required int skip}) async {
    try {
      final response = await _dio.get<Object>(
        '/products',
        queryParameters: <String, Object>{'limit': limit, 'skip': skip},
      );
      return ProductPageDto.fromJson(asJsonMap(response.data));
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }
}
