import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/storage_service.dart';

// Supported languages
enum AppLanguage {
  arabic,
  english;

  String get code {
    switch (this) {
      case AppLanguage.arabic:
        return 'ar';
      case AppLanguage.english:
        return 'en';
    }
  }

  String get displayName {
    switch (this) {
      case AppLanguage.arabic:
        return 'العربية';
      case AppLanguage.english:
        return 'English';
    }
  }

  Locale get locale {
    return Locale(code);
  }
}

// Language provider
final languageProvider = StateNotifierProvider<LanguageNotifier, AppLanguage>(
      (ref) => LanguageNotifier(),
);

class LanguageNotifier extends StateNotifier<AppLanguage> {
  LanguageNotifier() : super(AppLanguage.arabic) {
    _loadLanguage();
  }

  // Load language from storage
  Future<void> _loadLanguage() async {
    try {
      final languageCode = StorageService.instance.getLanguage();
      state = _languageFromCode(languageCode);
    } catch (e) {
      state = AppLanguage.arabic;
    }
  }

  // Set language
  Future<void> setLanguage(AppLanguage language) async {
    state = language;
    await StorageService.instance.setLanguage(language.code);
  }

  // Toggle language
  Future<void> toggleLanguage() async {
    final newLanguage = state == AppLanguage.arabic
        ? AppLanguage.english
        : AppLanguage.arabic;
    await setLanguage(newLanguage);
  }

  // Convert code to AppLanguage
  AppLanguage _languageFromCode(String code) {
    switch (code) {
      case 'en':
        return AppLanguage.english;
      case 'ar':
      default:
        return AppLanguage.arabic;
    }
  }
}

// Current locale provider
final currentLocaleProvider = Provider<Locale>((ref) {
  final language = ref.watch(languageProvider);
  return language.locale;
});

// Is Arabic provider
final isArabicProvider = Provider<bool>((ref) {
  final language = ref.watch(languageProvider);
  return language == AppLanguage.arabic;
});

// Text direction provider
final textDirectionProvider = Provider<TextDirection>((ref) {
  final isArabic = ref.watch(isArabicProvider);
  return isArabic ? TextDirection.rtl : TextDirection.ltr;
});