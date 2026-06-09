import 'package:flutter/material.dart';

import '../../../../core/widgets/palwakf_sis/pwf_sis_notice.dart';
import '../../../../core/widgets/palwakf_sis/pwf_sis_section_card.dart';
import '../../../../core/widgets/palwakf_sis/pwf_sis_status_badge.dart';
import '../../application/pwf_visual_identity_contrast_gate.dart';

class PwfSisVisualIdentityBridgePage extends StatelessWidget {
  const PwfSisVisualIdentityBridgePage({super.key});

  static const routePath =
      '/admin/platform/design-system/visual-identity-bridge';

  @override
  Widget build(BuildContext context) {
    final gate = const PwfVisualIdentityContrastGate().evaluate(
      foreground: Theme.of(context).colorScheme.onPrimary,
      background: Theme.of(context).colorScheme.primary,
    );
    const acceptedPreview = _OverridePreviewSpec(
      title: 'Preview آمن',
      foreground: Color(0xFFFBF8EF),
      background: Color(0xFF1E4E89),
      version: 'sis-preview-2026-05-18-a',
    );
    const rejectedPreview = _OverridePreviewSpec(
      title: 'Override مرفوض',
      foreground: Color(0xFFFFFFFF),
      background: Color(0xFFD6A637),
      version: 'sis-preview-low-contrast',
    );

    return Scaffold(
      appBar: AppBar(title: const Text('PWF-SIS — جسر إدارة الهوية')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          PwfSisSectionCard(
            title: 'Visual Identity Admin Bridge',
            subtitle:
                'ربط PWF-SIS بآلية الهوية البصرية المنشورة دون استبدال صفحة الإدارة الحالية.',
            child: Column(
              children: [
                ListTile(
                  leading: Icon(gate.passed ? Icons.check_circle : Icons.error),
                  title: const Text('Contrast Gate للثيم الحالي'),
                  subtitle: Text(gate.message),
                  trailing: PwfSisStatusBadge(
                    label: gate.passed ? 'passed' : 'blocked',
                    tone: gate.passed
                        ? PwfSisStatusTone.success
                        : PwfSisStatusTone.danger,
                  ),
                ),
                const Divider(),
                const ListTile(
                  leading: Icon(Icons.account_tree_outlined),
                  title: Text('Inheritance Model'),
                  subtitle: Text(
                    'Platform → Unit → System → Page Context → Runtime Theme',
                  ),
                ),
                const ListTile(
                  leading: Icon(Icons.restore_outlined),
                  title: Text('Rollback Required'),
                  subtitle: Text(
                    'كل override منشور يجب أن يدعم versioning وrollback.',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 760;
              const first = _OverridePreviewCard(spec: acceptedPreview);
              const second = _OverridePreviewCard(spec: rejectedPreview);
              return compact
                  ? const Column(
                      children: [first, SizedBox(height: 12), second],
                    )
                  : const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: first),
                        SizedBox(width: 12),
                        Expanded(child: second),
                      ],
                    );
            },
          ),
          const SizedBox(height: 16),
          const PwfSisSectionCard(
            title: 'Override/Rollback UAT',
            subtitle: 'خطوات إلزامية قبل نشر أي هوية بصرية مخصصة.',
            child: _RollbackUatSteps(),
          ),
          const SizedBox(height: 16),
          const PwfSisNotice(
            title: 'حاجز الإنتاج',
            message:
                'هذه الصفحة تثبت preview وcontrast وrollback فقط. لا publish حقيقي في PWF-SIS-04، ولا اعتماد إنتاجي قبل أدلة المتصفح والأدوار.',
            tone: PwfSisStatusTone.review,
          ),
        ],
      ),
    );
  }
}

class _OverridePreviewSpec {
  const _OverridePreviewSpec({
    required this.title,
    required this.foreground,
    required this.background,
    required this.version,
  });

  final String title;
  final Color foreground;
  final Color background;
  final String version;
}

class _OverridePreviewCard extends StatelessWidget {
  const _OverridePreviewCard({required this.spec});

  final _OverridePreviewSpec spec;

  @override
  Widget build(BuildContext context) {
    final gate = const PwfVisualIdentityContrastGate().evaluate(
      foreground: spec.foreground,
      background: spec.background,
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    spec.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                PwfSisStatusBadge(
                  label: gate.passed ? 'publishable' : 'rejected',
                  tone: gate.passed
                      ? PwfSisStatusTone.success
                      : PwfSisStatusTone.danger,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: spec.background,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'نموذج بطاقة هوية بصرية — ${spec.version}',
                style: TextStyle(
                  color: spec.foreground,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(gate.message),
            const SizedBox(height: 6),
            Text(
              'Version: ${spec.version}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _RollbackUatSteps extends StatelessWidget {
  const _RollbackUatSteps();

  @override
  Widget build(BuildContext context) {
    const steps = [
      ('1', 'Preview', 'معاينة override دون publish.'),
      ('2', 'Contrast Gate', 'رفض أي تباين أقل من الحد.'),
      ('3', 'Version Lock', 'تسجيل version قبل النشر.'),
      ('4', 'Rollback', 'إرجاع آخر نسخة منشورة دون كسر الثيم.'),
    ];
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final step in steps)
          SizedBox(
            width: 240,
            child: ListTile(
              leading: CircleAvatar(child: Text(step.$1)),
              title: Text(step.$2),
              subtitle: Text(step.$3),
            ),
          ),
      ],
    );
  }
}
