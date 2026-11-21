import 'package:enterprise_mvvm/core/access/app_role.dart';
import 'package:enterprise_mvvm/core/access/permission.dart';
import 'package:equatable/equatable.dart';

final class SessionUser with Equatable {
  const SessionUser({
    required this.id,
    required this.displayName,
    required this.roles,
    this.permissions,
  });

  final String id;
  final String displayName;
  final Set<AppRole> roles;

  /// Null means the server did not send grants, so role defaults apply.
  /// An empty set means the server explicitly granted nothing.
  final Set<Permission>? permissions;

  @override
  List<Object?> get props => <Object?>[id, displayName, roles, permissions];
}
