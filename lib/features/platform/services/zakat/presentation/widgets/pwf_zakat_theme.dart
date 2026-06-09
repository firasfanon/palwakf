import 'package:flutter/material.dart';

import 'package:waqf/features/platform/home/presentation/theme/pwf_home_palette.dart';

/// Zakat visual tokens aligned with the public PWF-SIS home-page family.
///
/// The previous Zakat page kept its own smaller radii/shadows and darker local
/// sections, which made `/home/zakat` look like a separate mini-application.
/// These aliases keep the Zakat widgets compile-stable while binding them to
/// the platform palette, card radius, and surface rhythm.
class PwfZakatPalette {
  static const Color primary = PwfHomePalette.primary;
  static const Color primary2 = PwfHomePalette.primary;
  static const Color gold = PwfHomePalette.secondary;
  static const Color royalRed = PwfHomePalette.royalRed;

  static const Color bg = Colors.transparent;
  static const Color card = PwfHomePalette.surface;
  static const Color text = PwfHomePalette.textPrimary;
  static const Color gray = PwfHomePalette.textSecondary;
  static const Color border = PwfHomePalette.border;
  static const Color soft = Color(0xFFF7F8FA);
}

extension PwfColorWithValuesX on Color {
  /// Platform rule: avoid withOpacity.
  Color withValues({
    double? opacity,
    int? alpha,
    int? red,
    int? green,
    int? blue,
  }) {
    final int a =
        alpha ??
        (opacity == null
            ? this.alpha
            : (opacity.clamp(0.0, 1.0) * 255).round());
    return Color.fromARGB(
      a,
      red ?? this.red,
      green ?? this.green,
      blue ?? this.blue,
    );
  }
}

class PwfZakatDecorations {
  static const double radius = PwfHomeRadii.r20;

  static const BorderRadius br = PwfHomeRadii.br20;
  static const BorderRadius br16 = PwfHomeRadii.br16;

  static const List<BoxShadow> shadow = PwfHomeShadows.card;

  static BorderSide get softBorder =>
      BorderSide(color: PwfZakatPalette.border.withValues(alpha: 210));
}

class PwfZakatTextStyles {
  static TextStyle heroTitle(BuildContext context) => Theme.of(context)
      .textTheme
      .headlineMedium!
      .copyWith(fontWeight: FontWeight.w800, color: Colors.white);

  static TextStyle heroSubtitle(BuildContext context) => Theme.of(context)
      .textTheme
      .titleMedium!
      .copyWith(color: Colors.white.withAlpha(230), height: 1.6);

  static TextStyle sectionTitle(BuildContext context) => Theme.of(context)
      .textTheme
      .headlineSmall!
      .copyWith(fontWeight: FontWeight.w800, color: PwfZakatPalette.primary);
}
