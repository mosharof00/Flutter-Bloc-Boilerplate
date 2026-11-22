import 'package:hive/hive.dart';

/// String key-value storage. Production uses Hive; tests can use [PreferencesStore.memory].
final class PreferencesStore {
  PreferencesStore._(this._box, this._memory);

  PreferencesStore(Box<String> box) : this._(box, null);

  /// In-memory store for unit and widget tests. Does not touch Hive.
  factory PreferencesStore.memory([Map<String, String>? seed]) {
    return PreferencesStore._(null, Map<String, String>.of(seed ?? const {}));
  }

  static const boxName = 'preferences';

  final Box<String>? _box;
  final Map<String, String>? _memory;

  static Future<PreferencesStore> open() async {
    final box = await Hive.openBox<String>(boxName);
    return PreferencesStore(box);
  }

  String? read(String key) {
    final memory = _memory;
    if (memory != null) {
      return memory[key];
    }
    return _box!.get(key);
  }

  Future<void> write(String key, String value) async {
    final memory = _memory;
    if (memory != null) {
      memory[key] = value;
      return;
    }
    await _box!.put(key, value);
  }

  Future<void> delete(String key) async {
    final memory = _memory;
    if (memory != null) {
      memory.remove(key);
      return;
    }
    await _box!.delete(key);
  }
}
