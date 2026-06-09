import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../pwf_home_new_contract.dart' show PwfLocalStorageKeys;

enum PwfThemeKey { islamic, light, dark }

@immutable
class PwfUiPrefsState {
  const PwfUiPrefsState({
    this.themeKey = PwfThemeKey.islamic,
    this.textScale = 1.0,
    this.highContrast = false,
    this.readMode = false,
    this.isReady = false,
  });

  final PwfThemeKey themeKey;
  final double textScale;
  final bool highContrast;
  final bool readMode;

  /// True when persisted values have been loaded at least once.
  final bool isReady;

  PwfUiPrefsState copyWith({
    PwfThemeKey? themeKey,
    double? textScale,
    bool? highContrast,
    bool? readMode,
    bool? isReady,
  }) {
    return PwfUiPrefsState(
      themeKey: themeKey ?? this.themeKey,
      textScale: textScale ?? this.textScale,
      highContrast: highContrast ?? this.highContrast,
      readMode: readMode ?? this.readMode,
      isReady: isReady ?? this.isReady,
    );
  }
}

class PwfUiPrefsController extends StateNotifier<PwfUiPrefsState> {
  PwfUiPrefsController() : super(const PwfUiPrefsState()) {
    _init();
  }

  SharedPreferences? _prefs;

  static const _kTheme = PwfLocalStorageKeys.theme;
  static const _kFont = PwfLocalStorageKeys.fontSize;
  static const _kContrast = PwfLocalStorageKeys.highContrast;
  static const _kRead = PwfLocalStorageKeys.readMode;

  Future<void> _init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final themeRaw = _prefs!.getString(_kTheme) ?? 'islamic';
      final fontRaw = _prefs!.getDouble(_kFont) ?? 1.0;
      final contrastRaw = _prefs!.getBool(_kContrast) ?? false;
      final readRaw = _prefs!.getBool(_kRead) ?? false;

      state = state.copyWith(
        themeKey: _parseTheme(themeRaw),
        textScale: _clampScale(fontRaw),
        highContrast: contrastRaw,
        readMode: readRaw,
        isReady: true,
      );
    } catch (_) {
      // Fail-open: keep defaults so UI never crashes.
      state = state.copyWith(isReady: true);
    }
  }

  PwfThemeKey _parseTheme(String v) {
    switch (v) {
      case 'light':
        return PwfThemeKey.light;
      case 'dark':
        return PwfThemeKey.dark;
      default:
        return PwfThemeKey.islamic;
    }
  }

  double _clampScale(double v) {
    if (v < 0.85) return 0.85;
    if (v > 1.25) return 1.25;
    return v;
  }

  Future<void> setTheme(PwfThemeKey key) async {
    state = state.copyWith(themeKey: key);
    await _prefs?.setString(_kTheme, key.name);
  }

  Future<void> increaseFont() async {
    final next = _clampScale(state.textScale + 0.05);
    state = state.copyWith(textScale: next);
    await _prefs?.setDouble(_kFont, next);
  }

  Future<void> toggleHighContrast() async {
    final next = !state.highContrast;
    state = state.copyWith(highContrast: next);
    await _prefs?.setBool(_kContrast, next);
  }

  Future<void> toggleReadMode() async {
    final next = !state.readMode;
    state = state.copyWith(readMode: next);
    await _prefs?.setBool(_kRead, next);
  }
}

final pwfUiPrefsProvider =
    StateNotifierProvider<PwfUiPrefsController, PwfUiPrefsState>((ref) {
      return PwfUiPrefsController();
    });
