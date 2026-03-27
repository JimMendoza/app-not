import 'package:app_not/features/shared/infrastructure/services/key_value_storage_service.dart';
import 'package:app_not/features/shared/infrastructure/services/key_value_storage_service_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const String _themeModeStorageKey = 'app_theme_mode';

final NotifierProvider<AppThemeModeNotifier, ThemeMode> appThemeModeProvider =
    NotifierProvider<AppThemeModeNotifier, ThemeMode>(
      AppThemeModeNotifier.new,
    );

class AppThemeModeNotifier extends Notifier<ThemeMode> {
  KeyValueStorageService get _storage => ref.read(keyValueStorageServiceProvider);

  @override
  ThemeMode build() {
    Future<void>.microtask(_loadThemeMode);
    return ThemeMode.light;
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
      state = ThemeMode.light;
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
