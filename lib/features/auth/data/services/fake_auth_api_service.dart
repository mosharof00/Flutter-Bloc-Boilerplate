import 'package:enterprise_mvvm/core/config/app_flavor.dart';
import 'package:enterprise_mvvm/core/error/app_exception.dart';
import 'package:enterprise_mvvm/features/auth/data/dto/login_response_dto.dart';
import 'package:enterprise_mvvm/features/auth/data/dto/user_dto.dart';
import 'package:enterprise_mvvm/features/auth/data/services/auth_api_service.dart';

final class _DemoAccount {
  const _DemoAccount({
    required this.id,
    required this.email,
    required this.displayName,
    required this.roles,
    this.permissions,
  });

  final String id;
  final String email;
  final String displayName;
  final List<String> roles;
  final List<String>? permissions;

  UserDto toDto() {
    return UserDto(
      id: id,
      email: email,
      displayName: displayName,
      roles: roles,
      permissions: permissions,
    );
  }
}

/// In-memory auth API for the dev flavor.
///
/// The first access token is expired. [me] rejects it and [refresh] rotates it,
/// so token refresh can be exercised without a backend.
final class FakeAuthApiService implements AuthApiService {
  FakeAuthApiService({required AppFlavor flavor}) {
    assert(
      flavor != AppFlavor.prod,
      'FakeAuthApiService must not be used in prod.',
    );
    if (flavor == AppFlavor.prod) {
      throw StateError('FakeAuthApiService must not be used in prod.');
    }
  }

  static const password = '123456';

  static const Map<String, _DemoAccount> _accounts = <String, _DemoAccount>{
    'user@demo.com': _DemoAccount(
      id: 'user-user',
      email: 'user@demo.com',
      displayName: 'User Demo',
      roles: <String>['user'],
    ),
    'admin@demo.com': _DemoAccount(
      id: 'user-admin',
      email: 'admin@demo.com',
      displayName: 'Admin Demo',
      roles: <String>['admin'],
    ),
    'both@demo.com': _DemoAccount(
      id: 'user-both',
      email: 'both@demo.com',
      displayName: 'Both Demo',
      roles: <String>['user', 'admin'],
    ),
    'limited@demo.com': _DemoAccount(
      id: 'user-limited',
      email: 'limited@demo.com',
      displayName: 'Limited Demo',
      roles: <String>['user'],
      permissions: <String>[],
    ),
  };

  final Map<String, _DemoAccount> _byRefresh = <String, _DemoAccount>{};
  int _refreshCount = 0;

  @override
  Future<LoginResponseDto> login({
    required String email,
    required String password,
  }) async {
    final account = _accounts[email.trim().toLowerCase()];
    if (account == null || password != FakeAuthApiService.password) {
      throw const InvalidCredentialsException();
    }
    final refresh = 'refresh.${account.id}';
    _byRefresh[refresh] = account;
    return LoginResponseDto(
      accessToken: 'expired.${account.id}',
      refreshToken: refresh,
      user: account.toDto(),
    );
  }

  @override
  Future<LoginResponseDto> refresh({required String refreshToken}) async {
    final account = _byRefresh[refreshToken];
    if (account == null) {
      throw const UnauthorizedException();
    }
    _refreshCount += 1;
    return LoginResponseDto(
      accessToken: 'access.${account.id}.$_refreshCount',
      refreshToken: refreshToken,
      user: account.toDto(),
    );
  }

  @override
  Future<void> logout({required String refreshToken}) async {
    _byRefresh.remove(refreshToken);
  }

  @override
  Future<UserDto> me({required String accessToken}) async {
    if (accessToken.startsWith('expired.')) {
      throw const UnauthorizedException();
    }
    final id = _idFromAccess(accessToken);
    for (final _DemoAccount account in _accounts.values) {
      if (account.id == id) {
        return account.toDto();
      }
    }
    throw const UnauthorizedException();
  }

  String _idFromAccess(String accessToken) {
    final parts = accessToken.split('.');
    if (parts.length < 2) {
      return '';
    }
    return parts[1];
  }
}
