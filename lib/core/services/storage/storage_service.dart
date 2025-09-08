import 'package:shared_preferences/shared_preferences.dart';

/// Local storage service for persisting data
class StorageService {
  static SharedPreferences? _prefs;

  /// Initialize shared preferences
  static Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Get shared preferences instance
  SharedPreferences get _preferences {
    if (_prefs == null) {
      throw Exception(
        'StorageService not initialized. Call StorageService.initialize() first.',
      );
    }
    return _prefs!;
  }

  /// Store a string value
  Future<bool> setString(String key, String value) async {
    return await _preferences.setString(key, value);
  }

  /// Get a string value
  String? getString(String key) {
    return _preferences.getString(key);
  }

  /// Store a boolean value
  Future<bool> setBool(String key, bool value) async {
    return await _preferences.setBool(key, value);
  }

  /// Get a boolean value
  bool? getBool(String key) {
    return _preferences.getBool(key);
  }

  /// Store an integer value
  Future<bool> setInt(String key, int value) async {
    return await _preferences.setInt(key, value);
  }

  /// Get an integer value
  int? getInt(String key) {
    return _preferences.getInt(key);
  }

  /// Store a double value
  Future<bool> setDouble(String key, double value) async {
    return await _preferences.setDouble(key, value);
  }

  /// Get a double value
  double? getDouble(String key) {
    return _preferences.getDouble(key);
  }

  /// Store a list of strings
  Future<bool> setStringList(String key, List<String> value) async {
    return await _preferences.setStringList(key, value);
  }

  /// Get a list of strings
  List<String>? getStringList(String key) {
    return _preferences.getStringList(key);
  }

  /// Remove a specific key
  Future<bool> remove(String key) async {
    return await _preferences.remove(key);
  }

  /// Clear all stored data
  Future<bool> clearAll() async {
    return await _preferences.clear();
  }

  /// Check if a key exists
  bool containsKey(String key) {
    return _preferences.containsKey(key);
  }

  /// Get all keys
  Set<String> getKeys() {
    return _preferences.getKeys();
  }
}
