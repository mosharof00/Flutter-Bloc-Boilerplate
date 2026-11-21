import 'package:enterprise_mvvm/core/storage/preferences_store.dart';
import 'package:enterprise_mvvm/core/storage/storage_keys.dart';
import 'package:enterprise_mvvm/core/ui/view_model/base_view_model.dart';
import 'package:flutter/material.dart';

final class ThemeCubit extends BaseViewModel<ThemeMode> {
  ThemeCubit(this._preferences, {ThemeMode initial = ThemeMode.light})
    : super(initial);

  final PreferencesStore _preferences;

  static ThemeMode fromName(String? name) {
    return ThemeMode.values.asNameMap()[name] ?? ThemeMode.light;
  }

  Future<void> toggle() async {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    safeEmit(next);
    await _preferences.write(StorageKeys.themeMode, next.name);
  }
}
