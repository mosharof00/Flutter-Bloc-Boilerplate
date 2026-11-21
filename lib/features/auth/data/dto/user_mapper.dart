import 'package:enterprise_mvvm/core/access/app_role.dart';
import 'package:enterprise_mvvm/core/access/permission.dart';
import 'package:enterprise_mvvm/features/auth/data/dto/user_dto.dart';
import 'package:enterprise_mvvm/features/auth/domain/models/user.dart';

extension UserDtoMapper on UserDto {
  User toDomain() {
    return User(
      id: id,
      email: email,
      displayName: displayName,
      roles: roles.map(AppRole.values.byName).toSet(),
      permissions: permissions?.map(Permission.values.byName).toSet(),
    );
  }
}
