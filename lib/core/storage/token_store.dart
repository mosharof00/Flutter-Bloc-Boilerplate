import 'package:enterprise_mvvm/core/storage/secure_store.dart';
import 'package:enterprise_mvvm/core/storage/storage_keys.dart';

final class TokenStore {
  TokenStore(this._secure);

  final SecureStore _secure;

  Future<String?> readAccess() => _secure.read(StorageKeys.accessToken);

  Future<String?> readRefresh() => _secure.read(StorageKeys.refreshToken);

  Future<void> write({required String access, required String refresh}) async {
    await _secure.write(StorageKeys.accessToken, access);
    await _secure.write(StorageKeys.refreshToken, refresh);
  }

  Future<void> clear() async {
    await _secure.delete(StorageKeys.accessToken);
    await _secure.delete(StorageKeys.refreshToken);
  }
}
