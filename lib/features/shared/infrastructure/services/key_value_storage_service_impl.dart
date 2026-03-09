import 'package:shared_preferences/shared_preferences.dart';
import 'key_value_storage_service.dart';

class KeyValueStorageServiceImpl extends KeyValueStorageService {
  Future<SharedPreferences> _getSharedPrefs() async {
    return SharedPreferences.getInstance();
  }

  @override
  Future<T?> getValue<T>(String key) async {
    final prefs = await _getSharedPrefs();

    if (T == int) {
      return prefs.getInt(key) as T?;
    }

    if (T == String) {
      return prefs.getString(key) as T?;
    }

    throw UnimplementedError('GET not implemented for type $T');
  }

  @override
  Future<bool> removeKey(String key) async {
    final prefs = await _getSharedPrefs();
    return await prefs.remove(key);
  }

  @override
  Future<void> setKeyValue<T>(String key, T value) async {
    final prefs = await _getSharedPrefs();

    if (T == int) {
      await prefs.setInt(key, value as int);
      return;
    }

    if (T == String) {
      await prefs.setString(key, value as String);
      return;
    }

    throw UnimplementedError('Set not implemented for type $T');
  }

  @override
  Future<void> removeKeys(Iterable<String> keys) async {
    final SharedPreferences prefs = await _getSharedPrefs();

    for (final String key in keys) {
      await prefs.remove(key);
    }
  }
}
