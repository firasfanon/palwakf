import 'package:flutter/material.dart';

import '../providers/pwf_ui_prefs_provider.dart';

@immutable
class PwfThemeTokensData {
  /// Core palette
  final Color primary;
  final Color secondary;
  final Color onPrimary;
  final Color surface;
  final Color onSurface;
  final Color muted;

  /// Shell surfaces
  final Color topBarBg;
  final Color navBg;
  final List<Color> headerGradient;
  final List<Color> prayerGradient;
  final Color footerBg;

  /// Cards
  final Color cardBg;
  final Color cardBorder;
  final List<BoxShadow> cardShadow;

  /// Inputs
  final Color inputBg;
  final Color inputBorder;

  /// Primary button
  final Color primaryButtonBg;
  final Color primaryButtonFg;
  final Color primaryButtonBgHover;
  final Color primaryButtonBgPressed;

  /// Outlined button
  final Color outlinedBorder;
  final Color outlinedFg;
  final Color outlinedHoverBg;

  /// Chips / tags
  final Color chipBg;
  final Color chipFg;
  final Color chipBorder;
  final Color chipHoverBg;

  const PwfThemeTokensData({
    required this.primary,
    required this.secondary,
    required this.onPrimary,
    required this.surface,
    required this.onSurface,
    required this.muted,
    required this.topBarBg,
    required this.navBg,
    required this.headerGradient,
    required this.prayerGradient,
    required this.footerBg,
    required this.cardBg,
    required this.cardBorder,
    required this.cardShadow,
    required this.inputBg,
    required this.inputBorder,
    required this.primaryButtonBg,
    required this.primaryButtonFg,
    required this.primaryButtonBgHover,
    required this.primaryButtonBgPressed,
    required this.outlinedBorder,
    required this.outlinedFg,
    required this.outlinedHoverBg,
    required this.chipBg,
    required this.chipFg,
    required this.chipBorder,
    required this.chipHoverBg,
  });

  // Backward-friendly aliases used across widgets.
  Color get topBarSurface => topBarBg;
  Color get navSurface => navBg;

  // Common semantic tokens (used by shared UI)
  Color get accent => primaryButtonBg;
  Color get accentHover => primaryButtonBgHover;
  Color get onAccent => primaryButtonFg;

  Color get text => onSurface;
  Color get mutedText => muted;
  Color get border => cardBorder;

  // Surface hover used for subtle hover states
  Color get surfaceHover =>
      Color.alphaBlend(onSurface.withValues(alpha: 0.06), surface);
}

class PwfThemeTokens {
  static const _royalRed = Color(0xFFB22222);

  static PwfThemeTokensData forKey(PwfThemeKey key) {
    switch (key) {
      case PwfThemeKey.dark:
        return const PwfThemeTokensData(
          primary: Color(0xFF2D6EEA),
          secondary: Color(0xFFD4AF37),
          onPrimary: Colors.white,
          surface: Color(0xFF0E1726),
          onSurface: Color(0xFFF2F5FF),
          muted: Color(0xFFB7C2D9),
          topBarBg: Color(0xFF0E1726),
          navBg: Color(0xFF101B2F),
          headerGradient: [Color(0xFF0F1D33), Color(0xFF152A4A)],
          prayerGradient: [Color(0xFF0F1D33), Color(0xFF152A4A)],
          footerBg: Color(0xFF0B1220),
          cardBg: Color(0xFF121A2C),
          cardBorder: Color(0xFF24314D),
          cardShadow: [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 18,
              offset: Offset(0, 10),
            ),
          ],
          inputBg: Color(0xFF121A2C),
          inputBorder: Color(0xFF24314D),
          primaryButtonBg: _royalRed,
          primaryButtonFg: Colors.white,
          primaryButtonBgHover: Color(0xFFC12A2A),
          primaryButtonBgPressed: Color(0xFF9D1B1B),
          outlinedBorder: Color(0xFF415173),
          outlinedFg: Color(0xFFF2F5FF),
          outlinedHoverBg: Color(0x1AFFFFFF),
          chipBg: Color(0xFF1A2740),
          chipFg: Color(0xFFF2F5FF),
          chipBorder: Color(0xFF24314D),
          chipHoverBg: Color(0xFF223255),
        );

      case PwfThemeKey.light:
        return const PwfThemeTokensData(
          primary: Color(0xFF0B4AA2),
          secondary: Color(0xFFD4AF37),
          onPrimary: Colors.white,
          surface: Colors.white,
          onSurface: Color(0xFF0E1B2B),
          muted: Color(0xFF54606E),
          topBarBg: Color(0xFFF6F9FF),
          navBg: Colors.white,
          headerGradient: [Color(0xFF0B4AA2), Color(0xFF0A3577)],
          prayerGradient: [Color(0xFF0B4AA2), Color(0xFF0A3577)],
          footerBg: Color(0xFF0A2B57),
          cardBg: Colors.white,
          cardBorder: Color(0xFFE3EAF6),
          cardShadow: [
            BoxShadow(
              color: Color(0x1F000000),
              blurRadius: 18,
              offset: Offset(0, 10),
            ),
          ],
          inputBg: Color(0xFFF7FAFF),
          inputBorder: Color(0xFFDEE2E6),
          primaryButtonBg: _royalRed,
          primaryButtonFg: Colors.white,
          primaryButtonBgHover: Color(0xFFC12A2A),
          primaryButtonBgPressed: Color(0xFF9D1B1B),
          outlinedBorder: Color(0xFFCBD6EA),
          outlinedFg: Color(0xFF0E1B2B),
          outlinedHoverBg: Color(0x0A000000),
          chipBg: Color(0xFFF1F6FF),
          chipFg: Color(0xFF0E1B2B),
          chipBorder: Color(0xFFE3EAF6),
          chipHoverBg: Color(0xFFE9F1FF),
        );

      case PwfThemeKey.islamic:
      default:
        // Islamic = الأزرق + الذهبي، مع أحمر ملكي كـ accent
        return const PwfThemeTokensData(
          primary: Color(0xFF0B3770),
          secondary: Color(0xFFD4AF37),
          onPrimary: Colors.white,
          surface: Color(0xFF0A2B57),
          onSurface: Colors.white,
          muted: Color(0xFFD7E2F4),
          topBarBg: Color(0xFF0A2B57),
          navBg: Color(0xFF0B3770),
          headerGradient: [Color(0xFF0B3770), Color(0xFF062246)],
          prayerGradient: [Color(0xFF0B3770), Color(0xFF062246)],
          footerBg: Color(0xFF061B36),
          cardBg: Color(0xFFFFFFFF),
          cardBorder: Color(0xFFE0E8F5),
          cardShadow: [
            BoxShadow(
              color: Color(0x1F000000),
              blurRadius: 18,
              offset: Offset(0, 10),
            ),
          ],
          inputBg: Color(0xFFF7FAFF),
          inputBorder: Color(0xFFDEE2E6),
          primaryButtonBg: _royalRed,
          primaryButtonFg: Colors.white,
          primaryButtonBgHover: Color(0xFFC12A2A),
          primaryButtonBgPressed: Color(0xFF9D1B1B),
          outlinedBorder: Color(0xFFCBD6EA),
          outlinedFg: Color(0xFF0E1B2B),
          outlinedHoverBg: Color(0x0A000000),
          chipBg: Color(0xFFF1F6FF),
          chipFg: Color(0xFF0E1B2B),
          chipBorder: Color(0xFFE3EAF6),
          chipHoverBg: Color(0xFFE9F1FF),
        );
    }
  }
}
