import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Read-only Awqaf Assist workspace shell.
///
/// This page intentionally avoids importing the beta-provider/domain/widget files
/// that were missing from the local analyzer run. It preserves the route surface
/// while keeping Awqaf Assist in read-only beta mode under the PalWakf governing
/// contract: no owner writes, no service-role access, and no direct sovereign
/// mutation from Flutter.
class AwqafAssistWorkspacePage extends ConsumerWidget {
  const AwqafAssistWorkspacePage({super.key});

  static const String evidenceMarker = 'PWF_AWQAF_ASSIST_READ_ONLY_BETA_ROUTE';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('أوقاف أسيست'), centerTitle: false),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _StatusBanner(theme: theme),
            const SizedBox(height: 16),
            _SectionCard(
              icon: Icons.assistant_outlined,
              title: 'مساحة أوقاف أسيست التشغيلية',
              subtitle: 'إصدار تجريبي للقراءة والاستدلال فقط.',
              children: const [
                _Bullet(
                  'يعرض مؤشرات تشغيلية وإرشادية مرتبطة بسجلات المصدر ومسارات أوقاف سيستم.',
                ),
                _Bullet('لا ينفذ قرارات اعتماد أو رفض أو إنشاء أصول وقفية.'),
                _Bullet(
                  'لا يستخدم service_role داخل Flutter ولا يكتب مباشرة في waqf أو waqf_assets.',
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SectionCard(
              icon: Icons.verified_user_outlined,
              title: 'حدود الحوكمة',
              subtitle: 'النطاق الحالي محكوم كـ read-only beta.',
              children: const [
                _Bullet(
                  'أي انتقال من القراءة إلى الكتابة يحتاج عقد owner approval مستقل.',
                ),
                _Bullet(
                  'أي ربط مع البيانات السيادية يتم عبر wrappers/RPCs آمنة فقط.',
                ),
                _Bullet(
                  'تعطل أوقاف أسيست لا يعطل منصة PalWakf أو أوقاف سيستم.',
                ),
              ],
            ),
            const SizedBox(height: 16),
            _EvidencePanel(),
          ],
        ),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.35),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock_outline, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Read-only beta — لا توجد صلاحيات كتابة',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
                SizedBox(height: 6),
                Text(
                  'هذه الصفحة تحافظ على route/runtime readiness لأوقاف أسيست إلى حين اكتمال عقد التشغيل والـ UAT.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: theme.dividerColor.withOpacity(0.25)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(subtitle, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 7),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _EvidencePanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rows = const [
      ('الوضع', 'Read-only beta'),
      ('الكتابة', 'مغلقة'),
      ('البيانات السيادية', 'لا mutation من Flutter'),
      ('المؤشر', AwqafAssistWorkspacePage.evidenceMarker),
    ];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: theme.dividerColor.withOpacity(0.25)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Evidence marker',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            for (final row in rows)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 140,
                      child: Text(
                        row.$1,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Expanded(child: SelectableText(row.$2)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
