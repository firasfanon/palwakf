import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

/// Reusable category badge widget
/// Displays a category label with customizable styling
/// Follows DRY principle to eliminate repeated badge code across the app
class CategoryBadge extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final VoidCallback? onTap;

  const CategoryBadge({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
    this.fontWeight,
    this.padding,
    this.borderRadius,
    this.onTap,
  });

  /// Islamic green category badge (default style)
  factory CategoryBadge.islamicGreen({
    required String label,
    VoidCallback? onTap,
  }) {
    return CategoryBadge(
      label: label,
      backgroundColor: AppConstants.islamicGreen.withValues(alpha: 0.1),
      textColor: AppConstants.islamicGreen,
      fontSize: 12,
      fontWeight: FontWeight.bold,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      borderRadius: 4,
      onTap: onTap,
    );
  }

  /// Primary color badge (Islamic green)
  factory CategoryBadge.primary({
    required String label,
    VoidCallback? onTap,
  }) {
    return CategoryBadge(
      label: label,
      backgroundColor: AppConstants.islamicGreen.withValues(alpha: 0.1),
      textColor: AppConstants.islamicGreen,
      fontSize: 12,
      fontWeight: FontWeight.bold,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      borderRadius: 4,
      onTap: onTap,
    );
  }

  /// Error/warning badge
  factory CategoryBadge.error({
    required String label,
    VoidCallback? onTap,
  }) {
    return CategoryBadge(
      label: label,
      backgroundColor: AppConstants.error.withValues(alpha: 0.1),
      textColor: AppConstants.error,
      fontSize: 12,
      fontWeight: FontWeight.bold,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      borderRadius: 4,
      onTap: onTap,
    );
  }

  /// Success badge
  factory CategoryBadge.success({
    required String label,
    VoidCallback? onTap,
  }) {
    return CategoryBadge(
      label: label,
      backgroundColor: AppConstants.success.withValues(alpha: 0.1),
      textColor: AppConstants.success,
      fontSize: 12,
      fontWeight: FontWeight.bold,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      borderRadius: 4,
      onTap: onTap,
    );
  }

  /// Warning badge
  factory CategoryBadge.warning({
    required String label,
    VoidCallback? onTap,
  }) {
    return CategoryBadge(
      label: label,
      backgroundColor: AppConstants.warning.withValues(alpha: 0.1),
      textColor: AppConstants.warning,
      fontSize: 12,
      fontWeight: FontWeight.bold,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      borderRadius: 4,
      onTap: onTap,
    );
  }

  /// Info badge
  factory CategoryBadge.info({
    required String label,
    VoidCallback? onTap,
  }) {
    return CategoryBadge(
      label: label,
      backgroundColor: AppConstants.info.withValues(alpha: 0.1),
      textColor: AppConstants.info,
      fontSize: 12,
      fontWeight: FontWeight.bold,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      borderRadius: 4,
      onTap: onTap,
    );
  }

  /// Outlined badge (border only, no background)
  factory CategoryBadge.outlined({
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return CategoryBadge(
      label: label,
      backgroundColor: Colors.transparent,
      textColor: color,
      fontSize: 12,
      fontWeight: FontWeight.bold,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      borderRadius: 4,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppConstants.islamicGreen.withValues(alpha: 0.1);
    final hasBorder = backgroundColor == Colors.transparent;

    final badge = Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius ?? 4),
        border: hasBorder
            ? Border.all(color: textColor ?? AppConstants.islamicGreen, width: 1.5)
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor ?? AppConstants.islamicGreen,
          fontSize: fontSize ?? 12,
          fontWeight: fontWeight ?? FontWeight.bold,
        ),
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius ?? 4),
        child: badge,
      );
    }

    return badge;
  }
}
