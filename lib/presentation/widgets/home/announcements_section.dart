import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routing/unit_routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/models/announcement.dart';
import '../../providers/unit_dashboard_preview_providers.dart';

class AnnouncementsSection extends ConsumerWidget {
  final String unitSlug;
  final int previewLimit;

  const AnnouncementsSection({
    super.key,
    this.unitSlug = 'home',
    this.previewLimit = 2,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(
      unitLatestAnnouncementsPreviewProvider(
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
                'إعلانات هامة',
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => context.go(UnitRoutes.announcements(unitSlug)),
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
            error: (e, _) => _emptyState(message: 'تعذّر تحميل الإعلانات الآن'),
            data: (items) {
              if (items.isEmpty)
                return _emptyState(message: 'لا توجد إعلانات حالياً');
              return Column(
                children: items
                    .map(
                      (a) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _AnnouncementCard(unitSlug: unitSlug, item: a),
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
          Icon(Icons.campaign_outlined, color: AppColors.textSecondary),
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

class _AnnouncementCard extends StatelessWidget {
  final String unitSlug;
  final Announcement item;
  const _AnnouncementCard({required this.unitSlug, required this.item});

  static const Color _royalRed = Color(0xFFB22222);

  @override
  Widget build(BuildContext context) {
    final priorityColor = _priorityColor(item.priority);
    final until = item.validUntil;

    return InkWell(
      borderRadius: BorderRadius.circular(AppConstants.radiusL),
      onTap: () => context.go(UnitRoutes.announcementDetail(unitSlug, item.publicDetailId)),
      child: Card(
        elevation: 1.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          side: BorderSide(color: priorityColor.withValues(alpha: 0.25)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: priorityColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      item.priority.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (until != null)
                    Text(
                      'حتى ${AppDateUtils.formatShortArabicDate(until)}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                item.title,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                item.content,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _priorityColor(Priority p) {
    switch (p) {
      case Priority.critical:
        return _royalRed;
      case Priority.urgent:
        return AppColors.error;
      case Priority.high:
        return AppColors.warning;
      case Priority.medium:
        return AppColors.info;
      case Priority.normal:
        return const Color(0xFF0B3A70);
      case Priority.low:
        return AppColors.sageGreen;
    }
  }
}
