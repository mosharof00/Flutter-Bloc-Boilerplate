import 'package:shared_preferences/shared_preferences.dart';

/// String key-value storage. Production uses [SharedPreferences];
/// tests can use [PreferencesStore.memory].
final class PreferencesStore {
  PreferencesStore._(this._prefs, this._memory);

  PreferencesStore(SharedPreferences prefs) : this._(prefs, null);

  /// In-memory store for unit and widget tests. Does not touch the platform.
  factory PreferencesStore.memory([Map<String, String>? seed]) {
    return PreferencesStore._(null, Map<String, String>.of(seed ?? const {}));
  }

  final SharedPreferences? _prefs;
  final Map<String, String>? _memory;

  static Future<PreferencesStore> open() async {
    final prefs = await SharedPreferences.getInstance();
    return PreferencesStore(prefs);
  }

  String? read(String key) {
    final memory = _memory;
    if (memory != null) {
      return memory[key];
    }
    return _prefs!.getString(key);
  }

  Future<void> write(String key, String value) async {
    final memory = _memory;
    if (memory != null) {
      memory[key] = value;
      return;
    }
    await _prefs!.setString(key, value);
  }

  Future<void> delete(String key) async {
    final memory = _memory;
    if (memory != null) {
      memory.remove(key);
      return;
    }
    await _prefs!.remove(key);
  }
}
