import 'package:flutter/material.dart';

/// Shared theme keys for PalWakf modules.
enum PwfThemeKey { islamicLight, islamicDark }

/// Token bundle used by shared widgets. Modules may map these to their own design system.
class PwfThemeTokensData {
  const PwfThemeTokensData({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.surface,
    required this.onSurface,
    required this.cardSurface,
    required this.cardShadow,
    required this.border,
  });

  final Color primary;
  final Color secondary;
  final Color accent;
  final Color surface;
  final Color onSurface;
  final Color cardSurface;
  final List<BoxShadow> cardShadow;
  final Color border;

  Color get text => onSurface;
  Color get mutedText => onSurface.withValues(alpha: 0.70);

  Color get topBarSurface => surface;
  Color get navSurface => surface;
  Color get surfaceHover => surface.withValues(alpha: 0.92);
  Color get accentHover => accent.withValues(alpha: 0.85);
  Color get onAccent => Colors.white;
}

class PwfThemeTokens {
  static PwfThemeTokensData forKey(PwfThemeKey key) {
    switch (key) {
      case PwfThemeKey.islamicLight:
        return PwfThemeTokensData(
          primary: const Color(0xFF0D3B66),
          secondary: const Color(0xFFD4AF37),
          accent: const Color(0xFFB22222),
          surface: Colors.white,
          onSurface: const Color(0xFF0F172A),
          cardSurface: Colors.white,
          cardShadow: const [
            BoxShadow(
              blurRadius: 18,
              offset: Offset(0, 8),
              color: Color(0x1A000000),
            ),
          ],
          border: const Color(0x1A0F172A),
        );
      case PwfThemeKey.islamicDark:
        return PwfThemeTokensData(
          primary: const Color(0xFF1E3A8A),
          secondary: const Color(0xFFD4AF37),
          accent: const Color(0xFFB22222),
          surface: const Color(0xFF0B1220),
          onSurface: const Color(0xFFE5E7EB),
          cardSurface: const Color(0xFF0F172A),
          cardShadow: const [
            BoxShadow(
              blurRadius: 18,
              offset: Offset(0, 8),
              color: Color(0x33000000),
            ),
          ],
          border: const Color(0x33E5E7EB),
        );
    }
  }
}
