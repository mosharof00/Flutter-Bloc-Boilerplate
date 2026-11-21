import 'package:enterprise_mvvm/core/access/app_role.dart';
import 'package:enterprise_mvvm/core/access/permission.dart';
import 'package:enterprise_mvvm/core/session/session_user.dart';
import 'package:equatable/equatable.dart';

final class User with Equatable {
  const User({
    required this.id,
    required this.email,
    required this.displayName,
    required this.roles,
    this.permissions,
  });

  final String id;
  final String email;
  final String displayName;
  final Set<AppRole> roles;
  final Set<Permission>? permissions;

  SessionUser toSessionUser() {
    return SessionUser(
      id: id,
      displayName: displayName,
      roles: roles,
      permissions: permissions,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    email,
    displayName,
    roles,
    permissions,
  ];
}
