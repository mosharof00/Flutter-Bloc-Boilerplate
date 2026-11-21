import 'package:json_annotation/json_annotation.dart';

part 'refresh_request_dto.g.dart';

@JsonSerializable()
class RefreshRequestDto {
  const RefreshRequestDto({required this.refreshToken});

  factory RefreshRequestDto.fromJson(Map<String, dynamic> json) =>
      _$RefreshRequestDtoFromJson(json);

  final String refreshToken;

  Map<String, dynamic> toJson() => _$RefreshRequestDtoToJson(this);
}
