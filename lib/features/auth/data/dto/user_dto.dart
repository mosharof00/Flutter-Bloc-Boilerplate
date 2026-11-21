import 'package:json_annotation/json_annotation.dart';

part 'user_dto.g.dart';

@JsonSerializable()
class UserDto {
  const UserDto({
    required this.id,
    required this.email,
    required this.displayName,
    required this.roles,
    this.permissions,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);

  final String id;
  final String email;
  final String displayName;
  final List<String> roles;
  final List<String>? permissions;

  Map<String, dynamic> toJson() => _$UserDtoToJson(this);
}
