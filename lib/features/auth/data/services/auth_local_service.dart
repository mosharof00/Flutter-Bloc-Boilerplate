import 'dart:convert';

import 'package:enterprise_mvvm/core/access/app_role.dart';
import 'package:enterprise_mvvm/core/error/app_exception.dart';
import 'package:enterprise_mvvm/core/storage/preferences_store.dart';
import 'package:enterprise_mvvm/core/storage/secure_store.dart';
import 'package:enterprise_mvvm/core/storage/storage_keys.dart';
import 'package:enterprise_mvvm/features/auth/data/dto/user_dto.dart';

final class StoredAuth {
  const StoredAuth({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    required this.activeRole,
  });

  final String accessToken;
  final String refreshToken;
  final UserDto user;
  final AppRole activeRole;
}

final class AuthLocalService {
  AuthLocalService({required this._secure, required this._preferences});

  final SecureStore _secure;
  final PreferencesStore _preferences;

  Future<void> save({
    required String accessToken,
    required String refreshToken,
    required UserDto user,
    required AppRole activeRole,
  }) async {
    await _secure.write(StorageKeys.accessToken, accessToken);
    await _secure.write(StorageKeys.refreshToken, refreshToken);
    await _secure.write(StorageKeys.user, jsonEncode(user.toJson()));
    await _preferences.write(StorageKeys.activeRole, activeRole.name);
  }

  Future<StoredAuth?> read() async {
    final access = await _secure.read(StorageKeys.accessToken);
    final refresh = await _secure.read(StorageKeys.refreshToken);
    final rawUser = await _secure.read(StorageKeys.user);
    if (access == null || refresh == null || rawUser == null) {
      return null;
    }
    final role = AppRole.values
        .asNameMap()[_preferences.read(StorageKeys.activeRole)];
    if (role == null) {
      return null;
    }
    final decoded = jsonDecode(rawUser);
    if (decoded is! Map<String, dynamic>) {
      throw const CacheException();
    }
    return StoredAuth(
      accessToken: access,
      refreshToken: refresh,
      user: UserDto.fromJson(decoded),
      activeRole: role,
    );
  }

  Future<AppRole?> readActiveRole() async {
    return AppRole.values.asNameMap()[_preferences.read(
      StorageKeys.activeRole,
    )];
  }

  Future<void> saveActiveRole(AppRole role) {
    return _preferences.write(StorageKeys.activeRole, role.name);
  }

  Future<String?> readRefreshToken() => _secure.read(StorageKeys.refreshToken);

  Future<void> clear() async {
    await _secure.delete(StorageKeys.accessToken);
    await _secure.delete(StorageKeys.refreshToken);
    await _secure.delete(StorageKeys.user);
    await _preferences.delete(StorageKeys.activeRole);
  }
}
