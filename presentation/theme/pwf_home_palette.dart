import 'package:flutter/material.dart';

/// PalWakf Home visual identity palette (blue/gold + royal red).
///
/// Some Home widgets still reference legacy names (gold/dark/border), so we
/// keep them here as stable aliases to avoid breaking sections.
class PwfHomePalette {
  static const primary = Color(0xFF0B3A6A);
  static const secondary = Color(0xFFD4AF37);

  /// Backward-compatible alias used by some widgets.
  static const primary2 = secondary;

  /// Alias for legacy references.
  static const gold = secondary;

  static const royalRed = Color(0xFFB22222);

  /// Dark navy for titles/icons.
  static const dark = Color(0xFF0A2640);

  /// Neutral border color for cards/dividers.
  static const border = Color(0xFFE5E7EB);

  static const background = Color(0xFFF7F8FA);
  static const surface = Colors.white;

  /// Common card background alias used by multiple widgets.
  static const cardBg = surface;

  static const textPrimary = Color(0xFF0B0F14);
  static const textSecondary = Color(0xFF4B5563);

  /// Legacy neutral name used in multiple sections.
  static const gray = textSecondary;

  /// Legacy semantic token for destructive/alert actions.
  static const danger = royalRed;

  static const shadow = Color(0x14000000);
}

/// Shared border radii used across Home New widgets.
///
/// Keep the `r*` doubles as compile-time constants so they can be used in
/// const expressions (e.g., `Radius.circular(PwfHomeRadii.r8)`).
class PwfHomeRadii {
  static const double r8 = 8.0;
  static const double r10 = 10.0;
  static const double r16 = 16.0;
  static const double r20 = 20.0;
  static const double r30 = 30.0;

  static const BorderRadius br8 = BorderRadius.all(Radius.circular(r8));
  static const BorderRadius br10 = BorderRadius.all(Radius.circular(r10));
  static const BorderRadius br16 = BorderRadius.all(Radius.circular(r16));
  static const BorderRadius br20 = BorderRadius.all(Radius.circular(r20));
  static const BorderRadius br30 = BorderRadius.all(Radius.circular(r30));

  const PwfHomeRadii._();
}

/// Shared shadows used across Home New widgets.
class PwfHomeShadows {
  static const List<BoxShadow> card = <BoxShadow>[
    BoxShadow(
      color: PwfHomePalette.shadow,
      blurRadius: 16,
      offset: Offset(0, 6),
    ),
  ];

  static const List<BoxShadow> cardHover = <BoxShadow>[
    BoxShadow(
      color: PwfHomePalette.shadow,
      blurRadius: 22,
      offset: Offset(0, 10),
    ),
  ];

  const PwfHomeShadows._();
}
