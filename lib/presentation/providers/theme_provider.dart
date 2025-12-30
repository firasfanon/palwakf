import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/storage_service.dart';

// Theme mode provider
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
      (ref) => ThemeModeNotifier(),
);

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.light) {
    _loadThemeMode();
  }

  // Load theme mode from storage
  Future<void> _loadThemeMode() async {
    try {
      final themeString = StorageService.instance.getThemeMode();
      state = _themeModeFromString(themeString);
    } catch (e) {
      state = ThemeMode.light;
    }
  }

  // Set theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await StorageService.instance.setThemeMode(mode.name);
  }

  // Toggle theme
  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await setThemeMode(newMode);
  }

  // Convert string to ThemeMode
  ThemeMode _themeModeFromString(String value) {
    switch (value) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.light;
    }
  }
}

// Is dark mode provider
final isDarkModeProvider = Provider<bool>((ref) {
  final themeMode = ref.watch(themeModeProvider);
  return themeMode == ThemeMode.dark;
});

// Font size provider
final fontSizeProvider = StateNotifierProvider<FontSizeNotifier, double>(
      (ref) => FontSizeNotifier(),
);

class FontSizeNotifier extends StateNotifier<double> {
  static const double defaultSize = 14.0;
  static const double minSize = 12.0;
  static const double maxSize = 20.0;

  FontSizeNotifier() : super(defaultSize) {
    _loadFontSize();
  }

  Future<void> _loadFontSize() async {
    try {
      final prefs = StorageService.instance.getUserPreferences();
      state = prefs['font_size'] ?? defaultSize;
    } catch (e) {
      state = defaultSize;
    }
  }

  Future<void> setFontSize(double size) async {
    if (size < minSize || size > maxSize) return;

    state = size;

    final prefs = StorageService.instance.getUserPreferences();
    prefs['font_size'] = size;
    await StorageService.instance.setUserPreferences(prefs);
  }

  Future<void> increaseFontSize() async {
    if (state < maxSize) {
      await setFontSize(state + 1);
    }
  }

  Future<void> decreaseFontSize() async {
    if (state > minSize) {
      await setFontSize(state - 1);
    }
  }

  Future<void> resetFontSize() async {
    await setFontSize(defaultSize);
  }
}