import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:waqf/app/routing/unit_routes.dart';
import 'package:waqf/presentation/providers/friday_sermons_provider.dart';
import 'package:waqf/presentation/providers/homepage_settings_provider.dart';

import '../../theme/pwf_home_palette.dart';
import '../pwf_section_container.dart';
import '../shared/pwf_section_title.dart';
import 'pwf_content_display_settings.dart';

class PwfFridaySermonsSection extends ConsumerWidget {
  const PwfFridaySermonsSection({
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
              aliases: const ['pwf_friday_sermons'],
            ),
            orElse: () => null,
          );
    final display = PwfContentDisplaySettings.fromMap(
      resolvedSettings,
      defaultHomeLimit: 3,
    );
    final asyncItems = ref.watch(publicFridaySermonsProvider);

    return PwfSectionContainer(
      sectionKey: 'PwfFridaySermonsSection',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PwfSectionTitle(
            title: 'خطب الجمعة والنشرات الدينية',
            subtitle:
                'خطب الجمعة والنشرات الإرشادية والمحتوى الديني العام الصادر عن الوزارة',
          ),
          const SizedBox(height: 18),
          asyncItems.when(
            data: (items) {
              final list = items.take(display.homeLimit).toList();
              if (list.isEmpty) {
                return _buildFallback(context, display.showViewAll);
              }
              return Column(
                children: [
                  LayoutBuilder(
                    builder: (context, c) {
                      final w = c.maxWidth;
                      final isNarrow = w < 900;
                      return Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        children: [
                          for (final s in list)
                            SizedBox(
                              width: isNarrow ? w : (w - 20) / 2,
                              child: _SermonCard(sermon: s),
                            ),
                        ],
                      );
                    },
                  ),
                  if (display.showViewAll) ...[
                    const SizedBox(height: 24),
                    Center(
                      child: _PrimaryCtaButton(
                        label: 'الأرشيف الكامل للخطب والنشرات',
                        icon: Icons.archive,
                        onTap: () =>
                            context.go(UnitRoutes.fridaySermons(unitSlug)),
                      ),
                    ),
                  ],
                ],
              );
            },
            loading: () => const _SkeletonGrid(),
            error: (_, __) => _buildFallback(context, display.showViewAll),
          ),
        ],
      ),
    );
  }

  Widget _buildFallback(BuildContext context, bool showViewAll) {
    const demo = [
      _DemoSermon(
        title: 'خطبة الجمعة لهذا الأسبوع',
        body:
            'عنوان الخطبة: "دور المسجد في بناء المجتمع" - يمكن تحميل نص الخطبة كاملاً بصيغة PDF.',
        dateText: 'تاريخ: 19 مايو 2023',
      ),
      _DemoSermon(
        title: 'نشرة دينية إرشادية',
        body:
            'نشرة دينية حول "أهمية التكافل الاجتماعي" - مواد إرشادية للمواطنين.',
        dateText: 'تاريخ: 18 مايو 2023',
      ),
      _DemoSermon(
        title: 'خطبة الجمعة السابقة',
        body:
            'عنوان الخطبة: "فضل الصدقة وأثرها في المجتمع" - خطبة الجمعة بتاريخ 12 مايو 2023.',
        dateText: 'تاريخ: 12 مايو 2023',
      ),
    ];

    return Column(
      children: [
        LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;
            final isNarrow = w < 900;
            return Wrap(
              spacing: 20,
              runSpacing: 20,
              children: [
                for (final d in demo)
                  SizedBox(
                    width: isNarrow ? w : (w - 20) / 2,
                    child: _DemoSermonCard(demo: d),
                  ),
              ],
            );
          },
        ),
        if (showViewAll) ...[
          const SizedBox(height: 24),
          Center(
            child: _PrimaryCtaButton(
              label: 'الأرشيف الكامل للخطب والنشرات',
              icon: Icons.archive,
              onTap: () => context.go(UnitRoutes.fridaySermons(unitSlug)),
            ),
          ),
        ],
      ],
    );
  }
}

class _SermonCard extends StatefulWidget {
  const _SermonCard({required this.sermon});

  final dynamic sermon; // FridaySermon, kept dynamic to avoid extra imports.

  @override
  State<_SermonCard> createState() => _SermonCardState();
}

class _SermonCardState extends State<_SermonCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.sermon;
    final date = (s.sermonDate is DateTime)
        ? (s.sermonDate as DateTime)
        : DateTime.now();
    final dateText = 'تاريخ: ${DateFormat('d MMMM y', 'ar').format(date)}';
    final hasPdf = (s.pdfUrl as String?)?.isNotEmpty == true;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        transform: Matrix4.identity()..translate(0.0, _hover ? -10.0 : 0.0),
        decoration: BoxDecoration(
          color: PwfHomePalette.cardBg,
          borderRadius: PwfHomeRadii.br16,
          boxShadow: _hover ? PwfHomeShadows.cardHover : PwfHomeShadows.card,
          border: const Border(
            top: BorderSide(width: 4, color: PwfHomePalette.secondary),
          ),
        ),
        child: InkWell(
          borderRadius: PwfHomeRadii.br16,
          onTap: () async {
            if (hasPdf) {
              final pdf = (s.pdfUrl as String?)?.trim() ?? '';
              if (pdf.isNotEmpty) {
                await launchUrlString(pdf);
                return;
              }
            }
            if (context.mounted) context.go(UnitRoutes.fridaySermons('home'));
          },
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (s.titleAr as String?) ?? 'خطبة الجمعة',
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: PwfHomePalette.primary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  (s.summaryAr as String?) ??
                      'يمكن تحميل نص الخطبة كاملاً بصيغة PDF.',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dateText,
                      style: GoogleFonts.cairo(
                        fontSize: 12.5,
                        color: PwfHomePalette.gray,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'تحميل الخطبة',
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: PwfHomePalette.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        FaIcon(
                          hasPdf
                              ? FontAwesomeIcons.download
                              : FontAwesomeIcons.arrowLeft,
                          size: 14,
                          color: PwfHomePalette.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DemoSermon {
  const _DemoSermon({
    required this.title,
    required this.body,
    required this.dateText,
  });

  final String title;
  final String body;
  final String dateText;
}

class _DemoSermonCard extends StatefulWidget {
  const _DemoSermonCard({required this.demo});

  final _DemoSermon demo;

  @override
  State<_DemoSermonCard> createState() => _DemoSermonCardState();
}

class _DemoSermonCardState extends State<_DemoSermonCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final d = widget.demo;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        transform: Matrix4.identity()..translate(0.0, _hover ? -10.0 : 0.0),
        decoration: BoxDecoration(
          color: PwfHomePalette.cardBg,
          borderRadius: PwfHomeRadii.br16,
          boxShadow: _hover ? PwfHomeShadows.cardHover : PwfHomeShadows.card,
          border: const Border(
            top: BorderSide(width: 4, color: PwfHomePalette.secondary),
          ),
        ),
        child: InkWell(
          borderRadius: PwfHomeRadii.br16,
          onTap: () => context.go(UnitRoutes.fridaySermons('home')),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.fileLines,
                      size: 18,
                      color: PwfHomePalette.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        d.title,
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: PwfHomePalette.primary,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  d.body,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      d.dateText,
                      style: GoogleFonts.cairo(
                        fontSize: 12.5,
                        color: PwfHomePalette.gray,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'تحميل الخطبة',
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: PwfHomePalette.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const FaIcon(
                          FontAwesomeIcons.download,
                          size: 14,
                          color: PwfHomePalette.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PrimaryCtaButton extends StatefulWidget {
  const _PrimaryCtaButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_PrimaryCtaButton> createState() => _PrimaryCtaButtonState();
}

class _PrimaryCtaButtonState extends State<_PrimaryCtaButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(
          color: _hover ? PwfHomePalette.primary2 : PwfHomePalette.primary,
          borderRadius: PwfHomeRadii.br8,
          boxShadow: _hover ? PwfHomeShadows.cardHover : PwfHomeShadows.card,
        ),
        child: InkWell(
          borderRadius: PwfHomeRadii.br8,
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.icon, size: 14, color: Colors.white),
                const SizedBox(width: 10),
                Text(
                  widget.label,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SkeletonGrid extends StatelessWidget {
  const _SkeletonGrid();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final isNarrow = w < 900;
        Widget box() => Container(
          height: 150,
          decoration: BoxDecoration(
            color: const Color(0xFFE9ECEF),
            borderRadius: PwfHomeRadii.br16,
          ),
        );
        return Wrap(
          spacing: 20,
          runSpacing: 20,
          children: [
            SizedBox(width: isNarrow ? w : (w - 20) / 2, child: box()),
            SizedBox(width: isNarrow ? w : (w - 20) / 2, child: box()),
            SizedBox(width: isNarrow ? w : (w - 20) / 2, child: box()),
          ],
        );
      },
    );
  }
}
