import 'package:dio/dio.dart';
import 'package:enterprise_mvvm/core/network/dio_failure_mapper.dart';
import 'package:enterprise_mvvm/features/profile/data/dto/profile_dto.dart';

abstract interface class ProfileApiService {
  Future<List<ProfileDto>> fetch();
}

final class ProfileApiServiceImpl implements ProfileApiService {
  ProfileApiServiceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<ProfileDto>> fetch() async {
    try {
      final response = await _dio.get<List<dynamic>>('/profile');
      final data = response.data ?? <dynamic>[];
      return data
          .whereType<Map<String, dynamic>>()
          .map(ProfileDto.fromJson)
          .toList();
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }
}
