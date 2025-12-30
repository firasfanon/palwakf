import 'package:flutter/material.dart';
import 'brand_spec.dart';

class BrandTheme {
  static ThemeData buildTheme(BrandSpec brand) {
    final scheme = ColorScheme.fromSeed(
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
      appBarTheme: AppBarTheme(
        backgroundColor: brand.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brand.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: brand.primary.withValues(alpha: 20),
        selectedColor: brand.primary.withValues(alpha: 40),
        labelStyle: TextStyle(color: brand.primary),
      ),
    );
  }
}
