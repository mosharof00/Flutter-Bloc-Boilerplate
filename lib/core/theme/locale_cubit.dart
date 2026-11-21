import 'package:enterprise_mvvm/core/storage/preferences_store.dart';
import 'package:enterprise_mvvm/core/storage/storage_keys.dart';
import 'package:enterprise_mvvm/core/ui/view_model/base_view_model.dart';
import 'package:flutter/material.dart';

final class LocaleCubit extends BaseViewModel<Locale> {
  LocaleCubit(this._preferences, {Locale initial = const Locale('en')})
    : super(initial);

  final PreferencesStore _preferences;

  static const List<Locale> supported = <Locale>[Locale('en'), Locale('bn')];

  static Locale fromCode(String? code) {
    if (code == 'bn') {
      return const Locale('bn');
    }
    return const Locale('en');
  }

  Future<void> toggle() async {
    final next = state.languageCode == 'en'
        ? const Locale('bn')
        : const Locale('en');
    safeEmit(next);
    await _preferences.write(StorageKeys.locale, next.languageCode);
  }
}
