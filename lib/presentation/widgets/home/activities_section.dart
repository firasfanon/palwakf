import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routing/unit_routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/models/activity.dart';
import '../../providers/unit_dashboard_preview_providers.dart';

class ActivitiesSection extends ConsumerWidget {
  final String unitSlug;
  final int previewLimit;

  const ActivitiesSection({
    super.key,
    this.unitSlug = 'home',
    this.previewLimit = 3,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(
      unitUpcomingActivitiesPreviewProvider(
        UnitPreviewParams(unitSlug: unitSlug, limit: previewLimit),
      ),
    );

    return Container(
      margin: const EdgeInsets.all(AppConstants.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الأنشطة القادمة',
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => context.go(UnitRoutes.activities(unitSlug)),
                child: const Text('عرض الكل'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          async.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (e, _) => _emptyState(message: 'تعذّر تحميل الأنشطة الآن'),
            data: (items) {
              if (items.isEmpty)
                return _emptyState(message: 'لا توجد أنشطة قادمة حالياً');
              return Column(
                children: items
                    .map(
                      (a) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ActivityCard(activity: a, unitSlug: unitSlug),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _emptyState({required String message}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      child: Row(
        children: [
          Icon(Icons.event_busy, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final Activity activity;
  final String unitSlug;
  const _ActivityCard({required this.activity, required this.unitSlug});

  @override
  Widget build(BuildContext context) {
    final start = activity.startDate;

    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      child: InkWell(
        onTap: () => context.go(UnitRoutes.activities(unitSlug)),
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingM),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _badgeColor(activity.category).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _categoryIcon(activity.category),
                  color: _badgeColor(activity.category),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.title,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      activity.location,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.islamicGreen.withValues(
                              alpha: 0.12,
                            ),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            activity.category.displayName,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.islamicGreen,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          AppDateUtils.formatArabicDateTime(start),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _categoryIcon(ActivityCategory c) {
    switch (c) {
      case ActivityCategory.religious:
        return Icons.mosque;
      case ActivityCategory.educational:
        return Icons.school;
      case ActivityCategory.cultural:
        return Icons.theater_comedy;
      case ActivityCategory.social:
        return Icons.groups;
      case ActivityCategory.family:
        return Icons.family_restroom;
      case ActivityCategory.training:
        return Icons.model_training;
      case ActivityCategory.community:
        return Icons.volunteer_activism;
    }
  }

  Color _badgeColor(ActivityCategory c) {
    switch (c) {
      case ActivityCategory.religious:
        return AppColors.islamicGreen;
      case ActivityCategory.educational:
        return AppColors.info;
      case ActivityCategory.cultural:
        return AppColors.goldenYellow;
      case ActivityCategory.social:
        return AppColors.sageGreen;
      case ActivityCategory.family:
        return AppColors.warning;
      case ActivityCategory.training:
        return AppColors.info;
      case ActivityCategory.community:
        return AppColors.success;
    }
  }
}
