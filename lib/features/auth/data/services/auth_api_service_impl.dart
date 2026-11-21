import 'package:dio/dio.dart';
import 'package:enterprise_mvvm/core/error/app_exception.dart';
import 'package:enterprise_mvvm/core/network/dio_failure_mapper.dart';
import 'package:enterprise_mvvm/features/auth/data/dto/login_request_dto.dart';
import 'package:enterprise_mvvm/features/auth/data/dto/login_response_dto.dart';
import 'package:enterprise_mvvm/features/auth/data/dto/refresh_request_dto.dart';
import 'package:enterprise_mvvm/features/auth/data/dto/user_dto.dart';
import 'package:enterprise_mvvm/features/auth/data/services/auth_api_service.dart';
import 'package:enterprise_mvvm/features/auth/data/services/json_body.dart';

final class AuthApiServiceImpl implements AuthApiService {
  AuthApiServiceImpl({required this._dio, required this._refreshDio});

  final Dio _dio;
  final Dio _refreshDio;

  static const _login = '/auth/login';
  static const _refresh = '/auth/refresh';
  static const _logout = '/auth/logout';
  static const _me = '/auth/me';

  @override
  Future<LoginResponseDto> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Object?>(
        _login,
        data: LoginRequestDto(email: email, password: password).toJson(),
      );
      return LoginResponseDto.fromJson(asJsonMap(response.data));
    } on DioException catch (error) {
      if (error.response?.statusCode == 401) {
        throw const InvalidCredentialsException();
      }
      throw mapDioException(error);
    }
  }

  @override
  Future<LoginResponseDto> refresh({required String refreshToken}) async {
    try {
      final response = await _refreshDio.post<Object?>(
        _refresh,
        data: RefreshRequestDto(refreshToken: refreshToken).toJson(),
      );
      return LoginResponseDto.fromJson(asJsonMap(response.data));
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  @override
  Future<void> logout({required String refreshToken}) async {
    try {
      await _dio.post<Object?>(
        _logout,
        data: RefreshRequestDto(refreshToken: refreshToken).toJson(),
      );
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  @override
  Future<UserDto> me({required String accessToken}) async {
    try {
      final response = await _dio.get<Object?>(
        _me,
        options: Options(
          headers: <String, Object>{'Authorization': 'Bearer $accessToken'},
        ),
      );
      return UserDto.fromJson(asJsonMap(response.data));
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }
}
