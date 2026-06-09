import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:waqf/data/models/footer_settings.dart';
import 'package:waqf/presentation/providers/footer_settings_provider.dart';
import '../../theme/pwf_home_palette.dart';
import '../pwf_section_container.dart';
import '../shared/pwf_section_title.dart';

class PwfQuickLinksGrid extends ConsumerWidget {
  const PwfQuickLinksGrid({super.key, this.unitSlug = 'home'});

  final String unitSlug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final normalizedSlug = unitSlug.trim().isEmpty
        ? 'home'
        : unitSlug.trim().toLowerCase();
    final settings = ref
        .watch(publicFooterSettingsProvider(normalizedSlug))
        .maybeWhen(data: (value) => value, orElse: () => null);
    final links = (settings?.quickLinks ?? const <FooterLink>[])
        .where(
          (e) =>
              e.enabled &&
              e.label.trim().isNotEmpty &&
              e.route.trim().isNotEmpty,
        )
        .take(6)
        .toList(growable: false);

    if (links.isEmpty) return const SizedBox.shrink();

    return PwfSectionContainer(
      sectionKey: 'PwfQuickLinksGrid',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PwfSectionTitle(
            title: normalizedSlug == 'home'
                ? 'روابط سريعة'
                : 'روابط سريعة للسياق الحالي',
            subtitle: normalizedSlug == 'home'
                ? 'مداخل مختصرة إلى أبرز صفحات الوزارة والمنصة.'
                : 'روابط مختصرة تُدار حسب slug وتُعرض ضمن نفس القالب الديناميكي.',
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final columns = width >= 1100
                  ? 3
                  : width >= 760
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
                  for (final link in links)
                    SizedBox(
                      width: itemWidth,
                      child: _QuickLinkCard(link: link),
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

class _QuickLinkCard extends StatelessWidget {
  const _QuickLinkCard({required this.link});

  final FooterLink link;

  @override
  Widget build(BuildContext context) {
    final route = link.route.trim();
    final external =
        route.startsWith('http://') || route.startsWith('https://');

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () async {
        if (external) {
          await launchUrlString(route);
          return;
        }
        final target = route.startsWith('/') ? route : '/$route';
        context.go(target);
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: PwfHomePalette.border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 14,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: PwfHomePalette.background,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                external ? Icons.public_outlined : Icons.link_outlined,
                color: PwfHomePalette.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                link.label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: PwfHomePalette.text,
                ),
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
}
