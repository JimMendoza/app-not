import 'package:app_gore_callao/features/shared/infrastructure/services/key_value_storage_service.dart';
import 'package:app_gore_callao/features/shared/infrastructure/services/key_value_storage_service_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

const String _themeModeStorageKey = 'app_theme_mode';

final StateNotifierProvider<AppThemeModeNotifier, ThemeMode>
appThemeModeProvider = StateNotifierProvider<AppThemeModeNotifier, ThemeMode>((
  ref,
) {
  final KeyValueStorageService storage = ref.watch(
    keyValueStorageServiceProvider,
  );

  return AppThemeModeNotifier(storage);
});

class AppThemeModeNotifier extends StateNotifier<ThemeMode> {
  final KeyValueStorageService _storage;

  AppThemeModeNotifier(this._storage) : super(ThemeMode.system) {
    _loadThemeMode();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (state == mode) {
      return;
    }

    state = mode;
    await _storage.setKeyValue<String>(_themeModeStorageKey, _serialize(mode));
  }

  Future<void> _loadThemeMode() async {
    final String? storedValue = await _storage.getValue<String>(
      _themeModeStorageKey,
    );

    if (storedValue == null || storedValue.isEmpty) {
      state = ThemeMode.system;
      return;
    }

    state = _deserialize(storedValue);
  }

  String _serialize(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  ThemeMode _deserialize(String value) {
    switch (value.toLowerCase()) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
}
