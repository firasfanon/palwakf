import 'package:flutter/material.dart';

/// UI tokens adopted from the new HTML homepage (palwak_homepage.html).
///
/// Notes:
/// - Keep tokens isolated from `AppConstants` to avoid naming collisions.
/// - Values mirror the CSS variables defined in the HTML template.
class PwfHomeTokens {
  const PwfHomeTokens._();

  // CSS :root variables (palwak_homepage.html)
  static const Color primaryColor = Color(0xFF0D3C61);
  static const Color secondaryColor = Color(0xFFC19A50);
  static const Color accentColor = Color(0xFF2A6E3F);

  static const Color lightColor = Color(0xFFF8F9FA);
  static const Color darkColor = Color(0xFF1A1A1A);
  static const Color grayColor = Color(0xFF6C757D);

  static const Color backgroundColor = Color(0xFFF5F7FA);
  static const Color cardBackgroundColor = Color(0xFFFFFFFF);
  static const Color textColor = Color(0xFF1A1A1A);

  // Radius/shadows
  static const double radius = 8.0;
  static const double radiusL = 12.0;

  static const Duration transition = Duration(milliseconds: 300);

  static const BoxShadow shadow = BoxShadow(
    color: Color.fromRGBO(0, 0, 0, 0.08),
    blurRadius: 12,
    offset: Offset(0, 4),
  );

  static const BoxShadow shadowHover = BoxShadow(
    color: Color.fromRGBO(0, 0, 0, 0.12),
    blurRadius: 20,
    offset: Offset(0, 8),
  );

  static const List<BoxShadow> cardShadow = [shadow];
  static const List<BoxShadow> cardShadowHover = [shadowHover];

  static LinearGradient primaryGradient() => const LinearGradient(
    colors: [primaryColor, accentColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static TextStyle sectionTitleText(BuildContext context) =>
      Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w800,
        color: primaryColor,
      ) ??
      const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: primaryColor,
      );
}
