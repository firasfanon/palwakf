import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/news_article.dart';

class CategoryFilter extends StatelessWidget {
  final NewsCategory? selectedCategory;
  final Function(NewsCategory?) onCategorySelected;

  const CategoryFilter({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingM,
        ),
        itemCount: NewsCategory.values.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildFilterChip(
              label: 'الكل',
              isSelected: selectedCategory == null,
              onTap: () => onCategorySelected(null),
            );
          }

          final category = NewsCategory.values[index - 1];
          return _buildFilterChip(
            label: category.displayName,
            isSelected: selectedCategory == category,
            onTap: () => onCategorySelected(category),
            icon: AppConstants.newsCategoryIcons[category.name],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16),
              const SizedBox(width: 4),
            ],
            Text(label),
          ],
        ),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: Colors.white,
        selectedColor: AppColors.islamicGreen.withValues(alpha:0.2),
        checkmarkColor: AppColors.islamicGreen,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.islamicGreen : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        side: BorderSide(
          color: isSelected ? AppColors.islamicGreen : AppColors.borderLight,
        ),
      ),
    );
  }
}