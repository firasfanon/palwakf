import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routing/app_routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/homepage_settings_provider.dart';

/// قسم "كلمة الوزير" (DB-driven).
///
/// - يعرض بيانات MinisterSectionSettings من جدول homepage_sections.
/// - يظهر فقط عندما تكون البيانات متاحة (Fail-open: لا يعرض شيئًا عند عدم توفرها).
class MinisterWordSection extends ConsumerWidget {
  final int maxLines;
  const MinisterWordSection({super.key, this.maxLines = 3});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(ministerSectionProvider);

    return async.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (settings) {
        if (settings == null) return const SizedBox.shrink();

        final name = settings.name.trim();
        final position = settings.position.trim();
        final message = settings.message.trim();
        final link = settings.messageLink.trim();
        final imageUrl = settings.imageUrl.trim();

        if (name.isEmpty && message.isEmpty) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.all(AppConstants.paddingM),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(
              color: AppColors.borderLight.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppConstants.paddingM),
                decoration: const BoxDecoration(
                  gradient: AppConstants.islamicGradient,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppConstants.radiusL),
                    topRight: Radius.circular(AppConstants.radiusL),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person, color: Colors.white, size: 22),
                    const SizedBox(width: 10),
                    Text(
                      'كلمة معالي الوزير',
                      style: AppTextStyles.titleLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppConstants.paddingM),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.islamicGreen,
                          width: 3,
                        ),
                      ),
                      child: ClipOval(
                        child: imageUrl.isEmpty
                            ? Container(
                                color: AppColors.surfaceVariant,
                                child: const Icon(
                                  Icons.person,
                                  size: 38,
                                  color: Colors.grey,
                                ),
                              )
                            : Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: AppColors.surfaceVariant,
                                  child: const Icon(
                                    Icons.person,
                                    size: 38,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (name.isNotEmpty)
                            Text(
                              name,
                              style: AppTextStyles.titleMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.islamicGreen,
                              ),
                            ),
                          if (position.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              position,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                          if (message.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Text(
                              message,
                              style: AppTextStyles.bodySmall,
                              maxLines: maxLines,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: AppConstants.paddingM,
                  right: AppConstants.paddingM,
                  bottom: AppConstants.paddingM,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {
                      final target = link.isNotEmpty
                          ? link
                          : AppRoutes.minister;
                      context.go(target);
                    },
                    child: const Text('اقرأ المزيد'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
