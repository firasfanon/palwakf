import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:waqf/app/routing/unit_routes.dart';
import 'package:waqf/presentation/providers/unit_dashboard_preview_providers.dart';
import 'package:waqf/presentation/providers/homepage_settings_provider.dart';
import 'package:waqf/data/models/announcement.dart';

import '../../../presentation/theme/pwf_home_palette.dart';
import '../pwf_section_container.dart';
import '../shared/pwf_section_title.dart';
import '../shared/pwf_hoverable.dart';
import 'pwf_content_display_settings.dart';

class PwfAnnouncementsSection extends ConsumerWidget {
  const PwfAnnouncementsSection({
    super.key,
    this.unitSlug = 'home',
    this.sectionSettings,
  });

  final String unitSlug;
  final Map<String, dynamic>? sectionSettings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sectionsAsync = ref.watch(homepageSectionsForUnitProvider(unitSlug));
    final resolvedSettings =
        (sectionSettings != null && sectionSettings!.isNotEmpty)
        ? sectionSettings
        : sectionsAsync.maybeWhen(
            data: (sections) => PwfContentDisplaySettings.pickSectionSettings(
              sections,
              aliases: const ['pwf_announcements', 'announcements'],
            ),
            orElse: () => null,
          );
    final display = PwfContentDisplaySettings.fromMap(
      resolvedSettings,
      defaultHomeLimit: 4,
    );
    final async = ref.watch(
      unitLatestAnnouncementsPreviewProvider(
        UnitPreviewParams(unitSlug: unitSlug, limit: display.homeLimit),
      ),
    );
    final complementaryAsync = ref.watch(
      complementaryAnnouncementsPreviewProvider(
        UnitPreviewParams(unitSlug: unitSlug, limit: 3),
      ),
    );
    final isHomeScope = unitSlug.trim().toLowerCase() == 'home';

    return PwfSectionContainer(
      sectionKey: 'PwfAnnouncementsSection',
      child: Column(
        children: [
          PwfSectionTitle(
            title: 'الإعلانات والتنويهات',
            subtitle: isHomeScope
                ? 'إعلانات الوزارة الرسمية مع نافذة إضافية للتنويهات الصادرة عن الوحدات والمحافظات.'
                : 'إعلانات الجهة الحالية مع مساحة مختصرة للتنويهات الوزارية الرسمية.',
          ),
          const SizedBox(height: 22),
          async.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => _Empty(
              onTap: () => context.go(UnitRoutes.announcements(unitSlug)),
              showViewAll: display.showViewAll,
            ),
            data: (items) {
              if (items.isEmpty) {
                return _Empty(
                  onTap: () => context.go(UnitRoutes.announcements(unitSlug)),
                  showViewAll: display.showViewAll,
                );
              }

              return Column(
                children: [
                  LayoutBuilder(
                    builder: (context, c) {
                      final w = c.maxWidth;
                      final cols = w >= 1000 ? 4 : (w >= 740 ? 2 : 1);
                      final itemW = (w - (cols - 1) * 25) / cols;

                      return Wrap(
                        spacing: 25,
                        runSpacing: 25,
                        children: [
                          for (final a in items)
                            SizedBox(
                              width: itemW,
                              child: _AnnouncementCard(
                                unitSlug: unitSlug,
                                a: a,
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  complementaryAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (complementary) {
                      if (complementary.isEmpty) return const SizedBox.shrink();
                      return _ComplementaryAnnouncementsStrip(
                        unitSlug: unitSlug,
                        isHomeScope: isHomeScope,
                        items: complementary,
                      );
                    },
                  ),
                  if (display.showViewAll) ...[
                    const SizedBox(height: 30),
                    _ViewAll(
                      text: 'عرض جميع الإعلانات',
                      icon: Icons.campaign,
                      onTap: () =>
                          context.go(UnitRoutes.announcements(unitSlug)),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.onTap, required this.showViewAll});
  final VoidCallback onTap;
  final bool showViewAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'لا توجد إعلانات للعرض حالياً',
          style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: PwfHomePalette.gray,
          ),
        ),
        if (showViewAll) ...[
          const SizedBox(height: 18),
          _ViewAll(
            text: 'عرض جميع الإعلانات',
            icon: Icons.campaign,
            onTap: onTap,
          ),
        ],
      ],
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  const _AnnouncementCard({required this.unitSlug, required this.a});

  final String unitSlug;
  final Announcement a;

  @override
  Widget build(BuildContext context) {
    final isImportant =
        a.priority.name.toLowerCase() == 'high' ||
        a.priority.name.toLowerCase() == 'urgent';

    return PwfHoverable(
      onTap: () => context.go(UnitRoutes.announcementDetail(unitSlug, a.id)),
      hoverTranslate: const Offset(0, -6),
      borderRadius: PwfHomeRadii.br16,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: PwfHomePalette.cardBg,
          borderRadius: PwfHomeRadii.br16,
          border: isImportant
              ? Border.all(
                  color: const Color(0xFFB22222).withValues(alpha: 0.65),
                  width: 1.4,
                )
              : Border.all(color: Colors.black.withValues(alpha: 0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              a.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: PwfHomePalette.primary,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              a.content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: PwfHomePalette.gray,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.calendarAlt,
                      size: 14,
                      color: PwfHomePalette.gray,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'نشر في: ${_formatArabicDate(a.createdAt)}',
                      style: GoogleFonts.cairo(
                        fontSize: 12.5,
                        color: PwfHomePalette.gray,
                      ),
                    ),
                  ],
                ),
                if (isImportant)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB22222).withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'مهم',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFB22222),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _formatArabicDate(DateTime dt) {
  const months = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];
  final m = months[(dt.month - 1).clamp(0, 11)];
  return '${dt.day} $m ${dt.year}';
}

class _ComplementaryAnnouncementsStrip extends StatelessWidget {
  const _ComplementaryAnnouncementsStrip({
    required this.unitSlug,
    required this.isHomeScope,
    required this.items,
  });

  final String unitSlug;
  final bool isHomeScope;
  final List<Announcement> items;

  @override
  Widget build(BuildContext context) {
    final title = isHomeScope
        ? 'تنويهات من الوحدات والمحافظات'
        : 'تنويهات من الوزارة';
    final subtitle = isHomeScope
        ? 'مقتطفات سريعة من التنويهات النشطة خارج الصفحة الرئيسية.'
        : 'إبقاء التنويهات الوزارية المهمة متاحة داخل صفحة الوحدة أو النظام.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: PwfHomeRadii.br16,
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: PwfHomePalette.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: GoogleFonts.cairo(
              fontSize: 13,
              color: PwfHomePalette.gray,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              for (final item in items)
                SizedBox(
                  width: 280,
                  child: PwfHoverable(
                    onTap: () => context.go(
                      UnitRoutes.announcementDetail(unitSlug, item.id),
                    ),
                    hoverTranslate: const Offset(0, -4),
                    borderRadius: PwfHomeRadii.br16,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: PwfHomePalette.cardBg,
                        borderRadius: PwfHomeRadii.br16,
                        border: Border.all(
                          color: Colors.black.withValues(alpha: 0.05),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: PwfHomePalette.primary,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.content,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.cairo(
                              fontSize: 12.5,
                              color: PwfHomePalette.gray,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ViewAll extends StatefulWidget {
  const _ViewAll({required this.text, required this.icon, required this.onTap});
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_ViewAll> createState() => _ViewAllState();
}

class _ViewAllState extends State<_ViewAll> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          transform: Matrix4.translationValues(0, _hover ? -3 : 0, 0),
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
          decoration: BoxDecoration(
            color: PwfHomePalette.primary,
            borderRadius: PwfHomeRadii.br30,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _hover ? 0.18 : 0.12),
                blurRadius: _hover ? 18 : 14,
                offset: Offset(0, _hover ? 10 : 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 16, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                widget.text,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
