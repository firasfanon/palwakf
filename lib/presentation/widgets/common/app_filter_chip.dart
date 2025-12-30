// lib/presentation/widgets/common/app_filter_chip.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

/// Reusable FilterChip with consistent styling across the app
/// 
/// Features:
/// - Consistent color scheme (green when selected, white when not)
/// - Works on both light and gradient backgrounds
/// - Follows app design system
/// 
/// Usage:
/// ```dart
/// AppFilterChip(
///   label: 'الكل',
///   isSelected: _selectedCategory == null,
///   onSelected: () => setState(() => _selectedCategory = null),
/// )
/// ```
class AppFilterChip extends StatelessWidget {
  /// The text to display on the chip
  final String label;
  
  /// Whether this chip is currently selected
  final bool isSelected;
  
  /// Callback when the chip is tapped
  final VoidCallback onSelected;
  
  /// Whether the chip is on a gradient/dark background
  /// - true: Uses white/green scheme for visibility on dark backgrounds
  /// - false: Uses green/white scheme for visibility on light backgrounds
  final bool onDarkBackground;

  const AppFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onSelected,
    this.onDarkBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    if (onDarkBackground) {
      // For gradient/dark backgrounds (like hero sections)
      return FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onSelected(),
        // When NOT selected: semi-transparent black background so white text is visible
        // When selected: solid white background with green text
        backgroundColor: AppConstants.islamicGreen,
        selectedColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? AppConstants.islamicGreen : Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
        ),
        side: BorderSide(
          color: isSelected ? Colors.white : Colors.white.withValues(alpha:0.1),
          width: isSelected ? 2 : 1.5,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        checkmarkColor: AppConstants.islamicGreen,
      );
    } else {
      // For light backgrounds (like content sections)
      return FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onSelected(),
        // When selected: green background with white text
        // When not selected: white background with green text
        backgroundColor: Colors.white,
        selectedColor: AppConstants.islamicGreen,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppConstants.islamicGreen,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
        ),
        side: BorderSide(
          color: isSelected 
              ? AppConstants.islamicGreen 
              : AppConstants.islamicGreen.withValues(alpha:0.3),
          width: isSelected ? 2 : 1,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        checkmarkColor: Colors.white,
      );
    }
  }
}

/// Extension to help with FilterChip consistency
/// 
/// This provides helper methods for common filter chip patterns
extension FilterChipHelper on BuildContext {
  /// Creates a list of AppFilterChips from a map of options
  /// 
  /// Example:
  /// ```dart
  /// final chips = context.buildFilterChips<NewsCategory?>(
  ///   options: {
  ///     null: 'الكل',
  ///     NewsCategory.general: 'عام',
  ///     NewsCategory.mosques: 'المساجد',
  ///   },
  ///   selectedValue: _selectedCategory,
  ///   onSelected: (category) => setState(() => _selectedCategory = category),
  ///   onDarkBackground: true,
  /// );
  /// ```
  List<Widget> buildFilterChips<T>({
    required Map<T, String> options,
    required T selectedValue,
    required ValueChanged<T> onSelected,
    bool onDarkBackground = false,
  }) {
    return options.entries.map((entry) {
      return AppFilterChip(
        label: entry.value,
        isSelected: selectedValue == entry.key,
        onSelected: () => onSelected(entry.key),
        onDarkBackground: onDarkBackground,
      );
    }).toList();
  }
}
