import 'package:enterprise_mvvm/features/auth/data/dto/user_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'login_response_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class LoginResponseDto {
  const LoginResponseDto({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseDtoFromJson(json);

  final String accessToken;
  final String refreshToken;
  final UserDto user;

  Map<String, dynamic> toJson() => _$LoginResponseDtoToJson(this);
}
