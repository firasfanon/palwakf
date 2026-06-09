import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:waqf/app/routing/app_routes.dart';
import 'package:waqf/app/routing/unit_routes.dart';
import 'package:waqf/core/constants/app_constants.dart';
import 'package:waqf/data/models/footer_settings.dart';
import 'package:waqf/presentation/providers/footer_settings_provider.dart';
import 'package:waqf/presentation/providers/unit_context_provider.dart';
import 'package:waqf/features/platform/assistant/assistant_core/data/services/chat_entry_service.dart';
import '../theme/pwf_home_palette.dart';
import '../screens/pages/pwf_public_content_shared.dart';
import 'pwf_web_container.dart';
import 'shared/pwf_section_title.dart';

class PwfImportantLinksSection extends ConsumerWidget {
  const PwfImportantLinksSection({super.key, this.unitSlug = 'home'});

  final String unitSlug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final normalizedSlug = unitSlug.trim().isEmpty
        ? 'home'
        : unitSlug.trim().toLowerCase();
    final scopedSettings = ref
        .watch(publicFooterSettingsProvider(normalizedSlug))
        .maybeWhen(data: (value) => value, orElse: () => null);
    final unit = ref.watch(orgUnitBySlugProvider(normalizedSlug)).valueOrNull;
    final scopeLabel = pwfResolveScopeLabel(
      unitSlug: normalizedSlug,
      unit: unit,
      contextualLabel: (scopedSettings?.ministryName ?? '').trim().isEmpty
          ? null
          : scopedSettings?.ministryName,
    );
    final links = _buildLinks(
      normalizedSlug,
      scopedSettings,
      scopeLabel: scopeLabel,
    );

    return PwfWebContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PwfSectionTitle(
            title: normalizedSlug == 'home'
                ? 'روابط مهمة'
                : 'روابط $scopeLabel',
            subtitle: normalizedSlug == 'home'
                ? 'روابط وخدمات عامة سريعة للوصول المباشر إلى أبرز صفحات المنصة.'
                : 'روابط وخدمات مرتبطة بالسياق الحالي وتُحمَّل بحسب الوحدة أو الجهة النشطة.',
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final columns = width >= 1200
                  ? 4
                  : width >= 800
                  ? 2
                  : 1;
              const spacing = 16.0;
              final itemWidth = columns == 1
                  ? width
                  : (width - ((columns - 1) * spacing)) / columns;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  for (final item in links)
                    SizedBox(
                      width: itemWidth,
                      child: _ImportantLinkCard(
                        item: item,
                        unitSlug: normalizedSlug,
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

List<_LinkItem> _buildLinks(
  String unitSlug,
  FooterSettings? settings, {
  required String scopeLabel,
}) {
  final isHome = unitSlug == 'home';
  final output = <_LinkItem>[
    _LinkItem(
      title: isHome ? 'الرئيسية' : scopeLabel,
      description: isHome
          ? 'العودة إلى الصفحة الرئيسية للوزارة.'
          : 'العودة إلى الصفحة الديناميكية الخاصة بـ $scopeLabel.',
      kind: _LinkKind.route,
      value: UnitRoutes.home(unitSlug),
      icon: Icons.home_outlined,
    ),
    _LinkItem(
      title: 'الأخبار',
      description: 'آخر الأخبار المرتبطة بالسياق الحالي.',
      kind: _LinkKind.route,
      value: UnitRoutes.news(unitSlug),
      icon: Icons.newspaper_outlined,
    ),
    _LinkItem(
      title: 'الأنشطة والفعاليات',
      description: 'الأنشطة والفعاليات التي تظهر ضمن هذا السياق.',
      kind: _LinkKind.route,
      value: UnitRoutes.activities(unitSlug),
      icon: Icons.event_note_outlined,
    ),
    _LinkItem(
      title: 'وحدة الشكاوى',
      description: 'إرسال شكوى أو مقترح ومتابعة القنوات المخصصة للتواصل.',
      kind: _LinkKind.route,
      value: AppRoutes.complaints,
      icon: Icons.support_agent_outlined,
    ),
    _LinkItem(
      title: 'اسألنا',
      description: 'الدخول إلى الشات العام للجمهور أو المساعد الداخلي للموظف.',
      kind: _LinkKind.chat,
      value: UnitRoutes.chat(unitSlug),
      icon: Icons.chat_bubble_outline,
    ),
  ];

  void addFooterLink(FooterLink link, String description, IconData icon) {
    final title = link.label.trim();
    final route = link.route.trim();
    if (!link.enabled || title.isEmpty || route.isEmpty) return;
    final exists = output.any((e) => e.title == title && e.value == route);
    if (exists) return;
    output.add(
      _LinkItem(
        title: title,
        description: description,
        kind: route.startsWith('http://') || route.startsWith('https://')
            ? _LinkKind.external
            : _LinkKind.route,
        value: route,
        icon: icon,
      ),
    );
  }

  if (settings != null) {
    for (final link in settings.quickLinks.take(3)) {
      addFooterLink(
        link,
        'رابط سريع مرتبط ببيانات $scopeLabel.',
        Icons.link_outlined,
      );
    }
    for (final link in settings.servicesLinks.take(3)) {
      addFooterLink(
        link,
        'خدمة أو مسار تشغيلي مرتبط بالسياق الحالي.',
        Icons.miscellaneous_services_outlined,
      );
    }

    if ((settings.facebookUrl ?? '').trim().isNotEmpty) {
      output.add(
        _LinkItem(
          title: 'فيسبوك',
          description: 'متابعة الصفحة الرسمية المرتبطة بهذا السياق.',
          kind: _LinkKind.external,
          value: settings.facebookUrl!,
          icon: Icons.facebook,
        ),
      );
    }

    if ((settings.youtubeUrl ?? '').trim().isNotEmpty) {
      output.add(
        _LinkItem(
          title: 'يوتيوب',
          description:
              'الوصول إلى القناة أو المحتوى المرئي المرتبط بهذا السياق.',
          kind: _LinkKind.external,
          value: settings.youtubeUrl!,
          icon: Icons.play_circle_outline_rounded,
        ),
      );
    }
  }

  if (isHome) {
    output.add(
      const _LinkItem(
        title: 'الموقع الرسمي',
        description: 'فتح الموقع الرسمي وروابط الوزارة العامة الخارجية.',
        kind: _LinkKind.external,
        value: AppConstants.website,
        icon: Icons.public_outlined,
      ),
    );
  }

  return output.take(8).toList();
}

class _ImportantLinkCard extends StatelessWidget {
  const _ImportantLinkCard({required this.item, required this.unitSlug});

  final _LinkItem item;
  final String unitSlug;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => _open(context, item),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: PwfHomePalette.border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: PwfHomePalette.background,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(item.icon, color: PwfHomePalette.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: PwfHomePalette.text,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      height: 1.5,
                      color: PwfHomePalette.gray,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: PwfHomePalette.secondary,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _open(BuildContext context, _LinkItem item) async {
    if (item.kind == _LinkKind.route) {
      context.go(item.value);
      return;
    }
    if (item.kind == _LinkKind.chat) {
      ChatEntryService.open(context, fallbackUnitSlug: unitSlug);
      return;
    }
    final ok = await launchUrlString(item.value);
    if (!context.mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تعذر فتح الرابط')));
    }
  }
}

enum _LinkKind { external, route, chat }

class _LinkItem {
  final String title;
  final String description;
  final _LinkKind kind;
  final String value;
  final IconData icon;

  const _LinkItem({
    required this.title,
    required this.description,
    required this.kind,
    required this.value,
    required this.icon,
  });
}
