import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:waqf/app/routing/unit_routes.dart';
import 'package:waqf/data/models/activity.dart';
import 'package:waqf/features/platform/home/presentation/screens/pwf_web_page_scaffold.dart';
import 'package:waqf/features/platform/home/presentation/widgets/pwf_hover_card.dart';
import 'package:waqf/features/platform/home/presentation/widgets/pwf_section_container.dart';
import 'package:waqf/presentation/providers/unit_activities_provider.dart';

class PwfActivitiesListWebScreen extends ConsumerWidget {
  const PwfActivitiesListWebScreen({super.key, required this.unitSlug});

  final String unitSlug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(activitiesForUnitProvider(unitSlug));

    return PwfWebPageScaffold(
      unitSlug: unitSlug,
      title: 'الأنشطة والفعاليات',
      showTitleSection: true,
      child: PwfSectionContainer(
        sectionKey: 'PwfActivitiesListWebScreen',
        child: async.when(
          data: (items) {
            if (items.isEmpty) {
              return const _PwfEmptyState(
                message: 'لا توجد فعاليات متاحة حالياً.',
              );
            }

            return _PwfCardsGrid<Activity>(
              items: items,
              titleBuilder: (a) => a.title,
              subtitleBuilder: (a) => a.description,
              onTap: (a) =>
                  context.go(UnitRoutes.activityDetail(unitSlug, a.id)),
            );
          },
          loading: () => const _PwfLoadingState(),
          error: (e, _) => _PwfErrorState(error: e),
        ),
      ),
    );
  }
}

class PwfActivityDetailWebScreen extends ConsumerWidget {
  const PwfActivityDetailWebScreen({
    super.key,
    required this.unitSlug,
    required this.id,
  });

  final String unitSlug;
  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(
      activityForUnitByIdProvider(UnitActivityIdParam(unitSlug, id)),
    );

    return PwfWebPageScaffold(
      unitSlug: unitSlug,
      title: 'تفاصيل الفعالية',
      showTitleSection: true,
      child: PwfSectionContainer(
        sectionKey: 'PwfActivityDetailWebScreen',
        child: async.when(
          data: (a) {
            if (a == null)
              return const _PwfEmptyState(message: 'الفعالية غير موجودة.');
            return _PwfDetailBody(
              title: a.title,
              meta: a.startDate ?? a.createdAt,
              content: a.description,
            );
          },
          loading: () => const _PwfLoadingState(),
          error: (e, _) => _PwfErrorState(error: e),
        ),
      ),
    );
  }
}

class _PwfCardsGrid<T> extends StatelessWidget {
  const _PwfCardsGrid({
    required this.items,
    required this.titleBuilder,
    required this.subtitleBuilder,
    required this.onTap,
  });

  final List<T> items;
  final String Function(T) titleBuilder;
  final String Function(T) subtitleBuilder;
  final void Function(T) onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final cols = w >= 1100 ? 3 : (w >= 720 ? 2 : 1);
        const spacing = 14.0;
        final cardW = (w - (spacing * (cols - 1))) / cols;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final item in items)
              SizedBox(
                width: cardW,
                child: PwfHoverCard(
                  onTap: () => onTap(item),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          titleBuilder(item),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F2C55),
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          subtitleBuilder(item),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.45,
                            color: Colors.black.withValues(alpha: 0.70),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: Text(
                            'عرض التفاصيل',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: const Color(
                                0xFFB22222,
                              ).withValues(alpha: 0.95),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _PwfDetailBody extends StatelessWidget {
  const _PwfDetailBody({
    required this.title,
    required this.meta,
    required this.content,
  });

  final String title;
  final DateTime meta;
  final String content;

  @override
  Widget build(BuildContext context) {
    final d = meta;
    final dateStr =
        '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            height: 1.25,
            color: Color(0xFF0F2C55),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          dateStr,
          style: TextStyle(
            fontSize: 12,
            color: Colors.black.withValues(alpha: 0.55),
          ),
        ),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                blurRadius: 18,
                offset: Offset(0, 10),
                color: Color(0x14000000),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
          child: Text(
            content,
            style: const TextStyle(
              fontSize: 15,
              height: 1.7,
              color: Color(0xFF1E293B),
            ),
          ),
        ),
      ],
    );
  }
}

class _PwfLoadingState extends StatelessWidget {
  const _PwfLoadingState();
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _PwfEmptyState extends StatelessWidget {
  const _PwfEmptyState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            color: Colors.black.withValues(alpha: 0.65),
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _PwfErrorState extends StatelessWidget {
  const _PwfErrorState({required this.error});
  final Object error;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: Center(
        child: Text(
          'حدث خطأ أثناء تحميل البيانات',
          style: TextStyle(
            color: Colors.black.withValues(alpha: 0.70),
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
