import 'package:flutter/material.dart';
import 'brand_spec.dart';
import '../theme/palwakf_sis_colors.dart';

class BrandTheme {
  static ThemeData buildTheme(BrandSpec brand) {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: brand.primary,
          brightness: brand.brightness,
        ).copyWith(
          primary: brand.primary,
          secondary: brand.secondary,
          tertiary: brand.accent,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brand.brightness,
      colorScheme: scheme,
      primaryColor: brand.primary,
      scaffoldBackgroundColor: const Color(0xFFF7F9FC),
      fontFamily: 'NotoSansArabic',
      fontFamilyFallback: const ['Arabic', 'Roboto', 'English', 'sans-serif'],
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontFamily: 'Amiri', fontSize: 32, fontWeight: FontWeight.w700, height: 1.2, letterSpacing: -0.5),
        displayMedium: TextStyle(fontFamily: 'Amiri', fontSize: 28, fontWeight: FontWeight.w600, height: 1.25, letterSpacing: -0.25),
        displaySmall: TextStyle(fontFamily: 'Amiri', fontSize: 24, fontWeight: FontWeight.w600, height: 1.3),
        headlineLarge: TextStyle(fontFamily: 'Amiri', fontSize: 22, fontWeight: FontWeight.w600, height: 1.35),
        headlineMedium: TextStyle(fontFamily: 'Amiri', fontSize: 20, fontWeight: FontWeight.w600, height: 1.4),
        headlineSmall: TextStyle(fontFamily: 'Amiri', fontSize: 18, fontWeight: FontWeight.w600, height: 1.4),
        titleLarge: TextStyle(fontFamily: 'NotoSansArabic', fontSize: 18, fontWeight: FontWeight.w700, height: 1.45),
        titleMedium: TextStyle(fontFamily: 'NotoSansArabic', fontSize: 16, fontWeight: FontWeight.w600, height: 1.45),
        titleSmall: TextStyle(fontFamily: 'NotoSansArabic', fontSize: 14, fontWeight: FontWeight.w600, height: 1.45),
        bodyLarge: TextStyle(fontFamily: 'NotoSansArabic', fontSize: 15, fontWeight: FontWeight.w400, height: 1.6),
        bodyMedium: TextStyle(fontFamily: 'NotoSansArabic', fontSize: 14, fontWeight: FontWeight.w400, height: 1.6),
        bodySmall: TextStyle(fontFamily: 'NotoSansArabic', fontSize: 12, fontWeight: FontWeight.w400, height: 1.6),
        labelLarge: TextStyle(fontFamily: 'NotoSansArabic', fontSize: 14, fontWeight: FontWeight.w600, height: 1.45),
        labelMedium: TextStyle(fontFamily: 'NotoSansArabic', fontSize: 12, fontWeight: FontWeight.w400, height: 1.6),
        labelSmall: TextStyle(fontFamily: 'NotoSansArabic', fontSize: 12, fontWeight: FontWeight.w400, height: 1.6),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: brand.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: Colors.white,
        unselectedLabelColor: Color(0xE6FFFFFF),
        indicatorColor: Colors.white,
        dividerColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brand.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: brand.primary,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF0F172A),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF0F172A),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: brand.primary.withValues(alpha: 0.08),
        selectedColor: brand.primary,
        secondarySelectedColor: brand.primary,
        labelStyle: const TextStyle(
          color: Color(0xFF0F172A),
          fontWeight: FontWeight.w700,
        ),
        secondaryLabelStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        side: BorderSide(color: brand.primary.withValues(alpha: 0.18)),
        brightness: Brightness.light,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return Colors.white;
            return const Color(0xFF0F172A);
          }),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return brand.primary;
            return Colors.white;
          }),
          side: WidgetStatePropertyAll(
            BorderSide(color: brand.primary.withValues(alpha: 0.18)),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE5E7EB), width: 0.5),
        ),
        color: Colors.white,
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: brand.primary, width: 1.5),
        ),
        hintStyle: const TextStyle(
          fontFamily: 'NotoSansArabic',
          fontSize: 14,
          color: Color(0xFF9CA3AF),
        ),
      ),
      extensions: const [PalWakfSisColors.light],
    );
  }
}
