import 'package:json_annotation/json_annotation.dart';

part 'profile_dto.g.dart';

@JsonSerializable()
class ProfileDto {
  const ProfileDto({required this.id, required this.title});

  factory ProfileDto.fromJson(Map<String, dynamic> json) =>
      _$ProfileDtoFromJson(json);

  final String id;
  final String title;

  Map<String, dynamic> toJson() => _$ProfileDtoToJson(this);
}
