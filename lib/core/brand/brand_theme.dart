import 'package:flutter/material.dart';
import 'brand_spec.dart';

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
    );
  }
}
