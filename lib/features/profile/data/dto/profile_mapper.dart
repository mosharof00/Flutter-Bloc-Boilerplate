import 'package:enterprise_mvvm/features/profile/data/dto/profile_dto.dart';
import 'package:enterprise_mvvm/features/profile/domain/models/profile.dart';

extension ProfileDtoMapper on ProfileDto {
  Profile toDomain() => Profile(id: id, title: title);
}
