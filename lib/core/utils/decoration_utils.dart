import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Utility class for common box decorations
/// Eliminates duplicated decoration code across the application
/// Follows DRY principle
class DecorationUtils {
  /// Standard card decoration with shadow
  static BoxDecoration cardDecoration({
    Color? color,
    double? radius,
    List<BoxShadow>? shadows,
    Border? border,
  }) {
    return BoxDecoration(
      color: color ?? Colors.white,
      borderRadius: BorderRadius.circular(radius ?? AppConstants.radiusM),
      boxShadow: shadows ??
          [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
      border: border,
    );
  }

  /// Elevated card with higher shadow
  static BoxDecoration elevatedCard({
    Color? color,
    double? radius,
  }) {
    return BoxDecoration(
      color: color ?? Colors.white,
      borderRadius: BorderRadius.circular(radius ?? AppConstants.radiusM),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.15),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Flat card without shadow
  static BoxDecoration flatCard({
    Color? color,
    double? radius,
    Border? border,
  }) {
    return BoxDecoration(
      color: color ?? Colors.white,
      borderRadius: BorderRadius.circular(radius ?? AppConstants.radiusM),
      border: border ??
          Border.all(
            color: Colors.grey.withValues(alpha: 0.2),
            width: 1,
          ),
    );
  }

  /// Islamic green container
  static BoxDecoration islamicGreenContainer({
    double opacity = 0.1,
    double? radius,
  }) {
    return BoxDecoration(
      color: AppConstants.islamicGreen.withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(radius ?? 4),
    );
  }

  /// Primary color container (Islamic green)
  static BoxDecoration primaryContainer({
    double opacity = 0.1,
    double? radius,
  }) {
    return BoxDecoration(
      color: AppConstants.islamicGreen.withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(radius ?? 4),
    );
  }

  /// Gradient container (Islamic gradient)
  static BoxDecoration islamicGradientContainer({
    double? radius,
    BorderRadius? borderRadius,
  }) {
    return BoxDecoration(
      gradient: AppConstants.islamicGradient,
      borderRadius: borderRadius ?? BorderRadius.circular(radius ?? AppConstants.radiusM),
    );
  }

  /// Custom gradient container
  static BoxDecoration gradientContainer({
    required List<Color> colors,
    double? radius,
    BorderRadius? borderRadius,
    AlignmentGeometry? begin,
    AlignmentGeometry? end,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: colors,
        begin: begin ?? Alignment.topLeft,
        end: end ?? Alignment.bottomRight,
      ),
      borderRadius: borderRadius ?? BorderRadius.circular(radius ?? AppConstants.radiusM),
    );
  }

  /// Bordered container
  static BoxDecoration borderedContainer({
    Color? borderColor,
    double borderWidth = 1,
    Color? backgroundColor,
    double? radius,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? Colors.transparent,
      borderRadius: BorderRadius.circular(radius ?? AppConstants.radiusM),
      border: Border.all(
        color: borderColor ?? AppConstants.islamicGreen,
        width: borderWidth,
      ),
    );
  }

  /// Dashed border container
  static BoxDecoration dashedBorderContainer({
    Color? borderColor,
    Color? backgroundColor,
    double? radius,
  }) {
    // Note: For actual dashed borders, use a custom painter or package like dotted_border
    return BoxDecoration(
      color: backgroundColor ?? Colors.transparent,
      borderRadius: BorderRadius.circular(radius ?? AppConstants.radiusM),
      border: Border.all(
        color: borderColor ?? Colors.grey,
        width: 1,
      ),
    );
  }

  /// Header container decoration
  static BoxDecoration headerContainer({
    Color? color,
    BorderRadius? borderRadius,
  }) {
    return BoxDecoration(
      gradient: color == null ? AppConstants.islamicGradient : null,
      color: color,
      borderRadius: borderRadius ??
          const BorderRadius.only(
            topLeft: Radius.circular(AppConstants.radiusM),
            topRight: Radius.circular(AppConstants.radiusM),
          ),
    );
  }

  /// Footer container decoration
  static BoxDecoration footerContainer({
    Color? color,
    BorderRadius? borderRadius,
  }) {
    return BoxDecoration(
      color: color ?? Colors.grey.withValues(alpha: 0.1),
      borderRadius: borderRadius ??
          const BorderRadius.only(
            bottomLeft: Radius.circular(AppConstants.radiusM),
            bottomRight: Radius.circular(AppConstants.radiusM),
          ),
    );
  }

  /// Overlay decoration for images
  static BoxDecoration imageOverlay({
    double opacity = 0.3,
    Gradient? gradient,
    double? radius,
  }) {
    return BoxDecoration(
      gradient: gradient ??
          LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: opacity),
            ],
          ),
      borderRadius: radius != null ? BorderRadius.circular(radius) : null,
    );
  }

  /// Status indicator decoration
  static BoxDecoration statusIndicator({
    required Color color,
    double size = 12,
    bool outlined = false,
  }) {
    return BoxDecoration(
      color: outlined ? Colors.transparent : color,
      shape: BoxShape.circle,
      border: outlined
          ? Border.all(
              color: color,
              width: 2,
            )
          : null,
    );
  }

  /// Shimmer loading decoration
  static BoxDecoration shimmerDecoration({
    Color? baseColor,
    Color? highlightColor,
  }) {
    return BoxDecoration(
      color: baseColor ?? Colors.grey.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(AppConstants.radiusS),
    );
  }

  /// Input field decoration
  static InputDecoration inputDecoration({
    String? labelText,
    String? hintText,
    IconData? prefixIcon,
    Widget? suffixIcon,
    String? errorText,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      errorText: errorText,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        borderSide: const BorderSide(color: AppConstants.islamicGreen, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        borderSide: const BorderSide(color: AppConstants.error),
      ),
      filled: true,
      fillColor: Colors.grey.withValues(alpha: 0.05),
    );
  }

  /// Search field decoration
  static InputDecoration searchFieldDecoration({
    String? hintText,
    VoidCallback? onClear,
  }) {
    return InputDecoration(
      hintText: hintText ?? 'بحث...',
      prefixIcon: const Icon(Icons.search, color: Colors.grey),
      suffixIcon: onClear != null
          ? IconButton(
              icon: const Icon(Icons.clear, color: Colors.grey),
              onPressed: onClear,
            )
          : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: Colors.grey.withValues(alpha: 0.1),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingM,
        vertical: AppConstants.paddingS,
      ),
    );
  }

  /// Divider decoration
  static Divider divider({
    double? thickness,
    Color? color,
    double? indent,
    double? endIndent,
  }) {
    return Divider(
      thickness: thickness ?? 1,
      color: color ?? Colors.grey.withValues(alpha: 0.2),
      indent: indent,
      endIndent: endIndent,
    );
  }

  /// Vertical divider decoration
  static VerticalDivider verticalDivider({
    double? thickness,
    Color? color,
    double? indent,
    double? endIndent,
  }) {
    return VerticalDivider(
      thickness: thickness ?? 1,
      color: color ?? Colors.grey.withValues(alpha: 0.2),
      indent: indent,
      endIndent: endIndent,
    );
  }

  /// Chip decoration
  static BoxDecoration chipDecoration({
    Color? backgroundColor,
    Color? borderColor,
    double? radius,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? AppConstants.islamicGreen.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(radius ?? AppConstants.radiusXL),
      border: borderColor != null
          ? Border.all(color: borderColor, width: 1)
          : null,
    );
  }

  /// Button decoration
  static BoxDecoration buttonDecoration({
    Color? color,
    double? radius,
    List<BoxShadow>? shadows,
  }) {
    return BoxDecoration(
      color: color ?? AppConstants.islamicGreen,
      borderRadius: BorderRadius.circular(radius ?? AppConstants.radiusM),
      boxShadow: shadows ??
          [
            BoxShadow(
              color: (color ?? AppConstants.islamicGreen).withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
    );
  }

  /// Outlined button decoration
  static BoxDecoration outlinedButtonDecoration({
    Color? borderColor,
    double? radius,
    double borderWidth = 2,
  }) {
    return BoxDecoration(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(radius ?? AppConstants.radiusM),
      border: Border.all(
        color: borderColor ?? AppConstants.islamicGreen,
        width: borderWidth,
      ),
    );
  }
}
