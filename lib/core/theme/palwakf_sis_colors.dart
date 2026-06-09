import 'package:flutter/material.dart';

@immutable
class PalWakfSisColors extends ThemeExtension<PalWakfSisColors> {
  const PalWakfSisColors({
    required this.sovereignBlue,
    required this.sovereignBlueDark,
    required this.waqfGold,
    required this.royalRed,
    required this.successGreen,
    required this.restrictedPurple,
    required this.surfacePaper,
    required this.surfaceCard,
    required this.textOnLight,
    required this.textOnDark,
    required this.textOnGold,
    required this.textMuted,
  });

  final Color sovereignBlue;
  final Color sovereignBlueDark;
  final Color waqfGold;
  final Color royalRed;
  final Color successGreen;
  final Color restrictedPurple;
  final Color surfacePaper;
  final Color surfaceCard;
  final Color textOnLight;
  final Color textOnDark;
  final Color textOnGold;
  final Color textMuted;

  static const light = PalWakfSisColors(
    sovereignBlue: Color(0xFF1E4E89),
    sovereignBlueDark: Color(0xFF102C52),
    waqfGold: Color(0xFFD6A637),
    royalRed: Color(0xFFB22222),
    successGreen: Color(0xFF2D7D55),
    restrictedPurple: Color(0xFF6851A3),
    surfacePaper: Color(0xFFFAF8F1),
    surfaceCard: Colors.white,
    textOnLight: Color(0xFF172033),
    textOnDark: Color(0xFFFBF8EF),
    textOnGold: Color(0xFF172033),
    textMuted: Color(0xFF667085),
  );

  static const dark = PalWakfSisColors(
    sovereignBlue: Color(0xFF6EA0E8),
    sovereignBlueDark: Color(0xFF0D1E36),
    waqfGold: Color(0xFFE8C05A),
    royalRed: Color(0xFFD65353),
    successGreen: Color(0xFF65B987),
    restrictedPurple: Color(0xFF9A83D8),
    surfacePaper: Color(0xFF111827),
    surfaceCard: Color(0xFF1B2433),
    textOnLight: Color(0xFFF4F1EA),
    textOnDark: Color(0xFFFBF8EF),
    textOnGold: Color(0xFF111827),
    textMuted: Color(0xFFB8C0CC),
  );

  @override
  PalWakfSisColors copyWith({
    Color? sovereignBlue,
    Color? sovereignBlueDark,
    Color? waqfGold,
    Color? royalRed,
    Color? successGreen,
    Color? restrictedPurple,
    Color? surfacePaper,
    Color? surfaceCard,
    Color? textOnLight,
    Color? textOnDark,
    Color? textOnGold,
    Color? textMuted,
  }) {
    return PalWakfSisColors(
      sovereignBlue: sovereignBlue ?? this.sovereignBlue,
      sovereignBlueDark: sovereignBlueDark ?? this.sovereignBlueDark,
      waqfGold: waqfGold ?? this.waqfGold,
      royalRed: royalRed ?? this.royalRed,
      successGreen: successGreen ?? this.successGreen,
      restrictedPurple: restrictedPurple ?? this.restrictedPurple,
      surfacePaper: surfacePaper ?? this.surfacePaper,
      surfaceCard: surfaceCard ?? this.surfaceCard,
      textOnLight: textOnLight ?? this.textOnLight,
      textOnDark: textOnDark ?? this.textOnDark,
      textOnGold: textOnGold ?? this.textOnGold,
      textMuted: textMuted ?? this.textMuted,
    );
  }

  @override
  PalWakfSisColors lerp(ThemeExtension<PalWakfSisColors>? other, double t) {
    if (other is! PalWakfSisColors) return this;
    return PalWakfSisColors(
      sovereignBlue: Color.lerp(sovereignBlue, other.sovereignBlue, t)!,
      sovereignBlueDark: Color.lerp(
        sovereignBlueDark,
        other.sovereignBlueDark,
        t,
      )!,
      waqfGold: Color.lerp(waqfGold, other.waqfGold, t)!,
      royalRed: Color.lerp(royalRed, other.royalRed, t)!,
      successGreen: Color.lerp(successGreen, other.successGreen, t)!,
      restrictedPurple: Color.lerp(
        restrictedPurple,
        other.restrictedPurple,
        t,
      )!,
      surfacePaper: Color.lerp(surfacePaper, other.surfacePaper, t)!,
      surfaceCard: Color.lerp(surfaceCard, other.surfaceCard, t)!,
      textOnLight: Color.lerp(textOnLight, other.textOnLight, t)!,
      textOnDark: Color.lerp(textOnDark, other.textOnDark, t)!,
      textOnGold: Color.lerp(textOnGold, other.textOnGold, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
    );
  }
}
