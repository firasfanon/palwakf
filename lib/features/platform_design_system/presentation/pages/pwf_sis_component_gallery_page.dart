import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/palwakf_sis/pwf_sis_metric_card.dart';
import '../../../../core/widgets/palwakf_sis/pwf_sis_notice.dart';
import '../../../../core/widgets/palwakf_sis/pwf_sis_responsive_wrap_grid.dart';
import '../../../../core/widgets/palwakf_sis/pwf_sis_runtime_state.dart';
import '../../../../core/widgets/palwakf_sis/pwf_sis_section_card.dart';
import '../../../../core/widgets/palwakf_sis/pwf_sis_status_badge.dart';
import '../../../../core/widgets/palwakf_sis/pwf_sis_system_hero.dart';
import 'pwf_sis_rollout_evidence_page.dart';
import 'pwf_sis_closure_review_page.dart';
import 'pwf_sis_visual_identity_bridge_page.dart';

class PwfSisComponentGalleryPage extends StatelessWidget {
  const PwfSisComponentGalleryPage({super.key});

  static const routePath = '/admin/platform/design-system';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PWF-SIS — نظام الواجهات السيادي')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          PwfSisSystemHero(
            kicker: 'Component Gallery',
            title: 'نظام واجهات PalWakf السيادي',
            description:
                'صفحة مرجعية تعرض مكونات PWF-SIS قبل تطبيقها على الأنظمة.',
            actions: [
              FilledButton(
                onPressed: () =>
                    context.go(PwfSisVisualIdentityBridgePage.routePath),
                child: const Text('جسر الهوية'),
              ),
              OutlinedButton(
                onPressed: () =>
                    context.go(PwfSisRolloutEvidencePage.routePath),
                child: const Text('خطة التعميم'),
              ),
              OutlinedButton(
                onPressed: () => context.go(PwfSisClosureReviewPage.routePath),
                child: const Text('فحص الإغلاق'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              PwfSisStatusBadge(label: 'runtime', tone: PwfSisStatusTone.info),
              PwfSisStatusBadge(label: 'review', tone: PwfSisStatusTone.review),
              PwfSisStatusBadge(
                label: 'blocked',
                tone: PwfSisStatusTone.danger,
              ),
              PwfSisStatusBadge(
                label: 'restricted',
                tone: PwfSisStatusTone.restricted,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const PwfSisResponsiveWrapGrid(
            minItemWidth: 230,
            children: [
              PwfSisMetricCard(
                label: 'أنظمة مسجلة',
                value: '12',
                badge: 'systems',
              ),
              PwfSisMetricCard(
                label: 'قيد المراجعة',
                value: '36',
                badge: 'review',
                tone: PwfSisStatusTone.review,
              ),
              PwfSisMetricCard(
                label: 'مانعة',
                value: '3',
                badge: 'blocked',
                tone: PwfSisStatusTone.danger,
              ),
              PwfSisMetricCard(
                label: 'جاهزية',
                value: '91%',
                badge: 'healthy',
                tone: PwfSisStatusTone.success,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const PwfSisSectionCard(
            title: 'Runtime States',
            subtitle: 'حالات التشغيل الموحدة',
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(width: 260, child: PwfSisRuntimeState.loading()),
                SizedBox(width: 260, child: PwfSisRuntimeState.empty()),
                SizedBox(width: 260, child: PwfSisRuntimeState.forbidden()),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const PwfSisNotice(
            title: 'PWF-SIS-04 Rollout Guard',
            message:
                'لا يسمح بنشر هوية بصرية تكسر التباين أو تعميم PWF-SIS على كل الأنظمة دفعة واحدة. يتم البدء بـ Awqaf Pilot ثم موجات مضبوطة.',
            tone: PwfSisStatusTone.review,
          ),
        ],
      ),
    );
  }
}
