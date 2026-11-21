import 'package:enterprise_mvvm/features/auth/data/dto/login_response_dto.dart';
import 'package:enterprise_mvvm/features/auth/data/dto/user_dto.dart';

abstract interface class AuthApiService {
  Future<LoginResponseDto> login({
    required String email,
    required String password,
  });

  Future<LoginResponseDto> refresh({required String refreshToken});

  Future<void> logout({required String refreshToken});

  /// Protected call used to exercise an expired access token.
  Future<UserDto> me({required String accessToken});
}
