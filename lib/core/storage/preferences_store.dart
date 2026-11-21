import 'package:shared_preferences/shared_preferences.dart';

final class PreferencesStore {
  PreferencesStore(this._preferences);

  final SharedPreferences _preferences;

  String? read(String key) => _preferences.getString(key);

  Future<void> write(String key, String value) async {
    await _preferences.setString(key, value);
  }

  Future<void> delete(String key) async {
    await _preferences.remove(key);
  }
}
