// lib/core/services/storage_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  static StorageService get instance => _instance;

  StorageService._internal();

  SharedPreferences? _prefs;

  /// Initialize storage service
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ============================================
  // STRING OPERATIONS
  // ============================================

  /// Get string value
  String? getString(String key) {
    return _prefs?.getString(key);
  }

  /// Set string value
  Future<bool> setString(String key, String value) async {
    return await _prefs?.setString(key, value) ?? false;
  }

  // ============================================
  // BOOLEAN OPERATIONS
  // ============================================

  /// Get boolean value
  bool getBool(String key) {
    return _prefs?.getBool(key) ?? false;
  }

  /// Set boolean value
  Future<bool> setBool(String key, bool value) async {
    return await _prefs?.setBool(key, value) ?? false;
  }

  // ============================================
  // INTEGER OPERATIONS
  // ============================================

  /// Get integer value
  int? getInt(String key) {
    return _prefs?.getInt(key);
  }

  /// Set integer value
  Future<bool> setInt(String key, int value) async {
    return await _prefs?.setInt(key, value) ?? false;
  }

  // ============================================
  // DOUBLE OPERATIONS
  // ============================================

  /// Get double value
  double? getDouble(String key) {
    return _prefs?.getDouble(key);
  }

  /// Set double value
  Future<bool> setDouble(String key, double value) async {
    return await _prefs?.setDouble(key, value) ?? false;
  }

  // ============================================
  // LIST OPERATIONS
  // ============================================

  /// Get string list
  List<String>? getStringList(String key) {
    return _prefs?.getStringList(key);
  }

  /// Set string list
  Future<bool> setStringList(String key, List<String> value) async {
    return await _prefs?.setStringList(key, value) ?? false;
  }

  // ============================================
  // REMOVE & CLEAR
  // ============================================

  /// Remove specific key
  Future<bool> remove(String key) async {
    return await _prefs?.remove(key) ?? false;
  }

  /// Clear all data
  Future<bool> clear() async {
    return await _prefs?.clear() ?? false;
  }

  /// Check if key exists
  bool containsKey(String key) {
    return _prefs?.containsKey(key) ?? false;
  }

  // ============================================
  // APP SPECIFIC METHODS
  // ============================================

  /// Get theme mode
  String getThemeMode() {
    return getString('theme_mode') ?? 'light';
  }

  /// Set theme mode
  Future<bool> setThemeMode(String mode) async {
    return await setString('theme_mode', mode);
  }

  /// Get language
  String getLanguage() {
    return getString('language') ?? 'ar';
  }

  /// Set language
  Future<bool> setLanguage(String language) async {
    return await setString('language', language);
  }

  /// Get user preferences
  Map<String, dynamic> getUserPreferences() {
    // Return a map of user preferences
    return {
      'font_size': getDouble('font_size') ?? 14.0,
      'notifications_enabled': getBool('notifications_enabled'),
      'sound_enabled': getBool('sound_enabled'),
    };
  }

  /// Set user preferences
  Future<bool> setUserPreferences(Map<String, dynamic> preferences) async {
    bool success = true;

    if (preferences.containsKey('font_size')) {
      success &= await setDouble('font_size', preferences['font_size'] as double);
    }
    if (preferences.containsKey('notifications_enabled')) {
      success &= await setBool('notifications_enabled', preferences['notifications_enabled'] as bool);
    }
    if (preferences.containsKey('sound_enabled')) {
      success &= await setBool('sound_enabled', preferences['sound_enabled'] as bool);
    }

    return success;
  }

  /// Clear auth data
  Future<void> clearAuthData() async {
    await remove('access_token');
    await remove('refresh_token');
    await remove('remember_me');
    await remove('user_id');
  }
}