
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:waqf/app/routing/app_routes.dart';

import '../widgets/media_center_mobile_visual_contract.dart';

class MediaCenterMobileOperationalHomePage extends StatelessWidget {
  const MediaCenterMobileOperationalHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MediaCenterMobileShell(
      title: 'إعلام الوزارة',
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          MediaCenterOfficialHero(
            title: 'من الهاتف إلى الموقع الرسمي',
            subtitle:
                'ابدأ النشر من المنصة الرسمية أولًا، ثم شارك الرابط الرسمي على فيسبوك ووسائل التواصل.',
            icon: Icons.phone_android,
            chips: const [
              MediaCenterContractChip(
                label: 'Official First',
                icon: Icons.verified,
                emphasis: true,
              ),
              MediaCenterContractChip(
                label: 'Mobile',
                icon: Icons.phone_android,
              ),
              MediaCenterContractChip(
                label: 'Audit',
                icon: Icons.history,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: _PrimaryActionCard(
              title: 'نشر رسمي سريع',
              subtitle:
                  'أنشئ خبرًا أو إعلانًا أو نشاطًا من الهاتف، واحفظه كمسودة أو أرسله للمراجعة أو انشره مباشرة حسب صلاحيتك.',
              icon: Icons.edit_note,
              actionLabel: 'فتح واجهة النشر',
              onPressed: () => context.push(AppRoutes.mediaCenterMobilePublish),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: _PrimaryActionCard(
              title: 'مسودات الهاتف',
              subtitle:
                  'احفظ الخبر محليًا عندما تكون في الميدان أو عندما يكون الاتصال ضعيفًا، ثم أرسله لاحقًا للمنصة الرسمية.',
              icon: Icons.offline_pin_outlined,
              actionLabel: 'فتح المسودات',
              onPressed: () => context.push(AppRoutes.mediaCenterMobileDrafts),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: _PrimaryActionCard(
              title: 'استعراض المركز الإعلامي',
              subtitle:
                  'راجع الأخبار والإعلانات والأنشطة كما تظهر عبر API edge دون الاعتماد على public base tables.',
              icon: Icons.newspaper,
              actionLabel: 'فتح المركز الإعلامي',
              onPressed: () => context.push(AppRoutes.mediaCenterMobileApp),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: _WorkflowCard(),
          ),
        ],
      ),
    );
  }
}

class _PrimaryActionCard extends StatelessWidget {
  const _PrimaryActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.actionLabel,
    required this.onPressed,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: MediaCenterMobileVisualContract.platformGold
                        .withOpacity(0.18),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Icon(
                      icon,
                      color: MediaCenterMobileVisualContract.platformBlue,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: MediaCenterMobileVisualContract.text,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              style: const TextStyle(
                color: MediaCenterMobileVisualContract.muted,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              style: MediaCenterMobileVisualContract.primaryButtonStyle(),
              onPressed: onPressed,
              icon: const Icon(Icons.arrow_back),
              label: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkflowCard extends StatelessWidget {
  const _WorkflowCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFFFFBEB),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            Text(
              'مسار العمل المعتمد',
              style: TextStyle(
                color: MediaCenterMobileVisualContract.text,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 10),
            _WorkflowRow(
              icon: Icons.person_outline,
              title: 'الموظف العادي',
              text: 'ينشئ المحتوى من الهاتف ويرسله للمراجعة.',
            ),
            _WorkflowRow(
              icon: Icons.verified_user_outlined,
              title: 'الناشر المعتمد',
              text: 'ينشر مباشرة عند الحاجة مع تسجيل audit كامل.',
            ),
            _WorkflowRow(
              icon: Icons.public,
              title: 'الجمهور',
              text: 'يفتح الرابط الرسمي على الموقع، وليس منشور فيسبوك كمصدر أصلي.',
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkflowRow extends StatelessWidget {
  const _WorkflowRow({
    required this.icon,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: MediaCenterMobileVisualContract.platformBlue),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  TextSpan(text: text),
                ],
              ),
              style: const TextStyle(
                color: MediaCenterMobileVisualContract.muted,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
