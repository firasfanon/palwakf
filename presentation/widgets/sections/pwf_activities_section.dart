import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:waqf/app/routing/unit_routes.dart';
import 'package:waqf/presentation/providers/unit_dashboard_preview_providers.dart';
import 'package:waqf/data/models/activity.dart';

import '../../../presentation/theme/pwf_home_palette.dart';
import '../pwf_section_container.dart';
import '../shared/pwf_section_title.dart';
import '../shared/pwf_hoverable.dart';

class PwfActivitiesSection extends ConsumerWidget {
  const PwfActivitiesSection({super.key, this.unitSlug = 'home'});

  final String unitSlug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(
      unitUpcomingActivitiesPreviewProvider(
        UnitPreviewParams(unitSlug: unitSlug, limit: 4),
      ),
    );

    return PwfSectionContainer(
      sectionKey: 'PwfActivitiesSection',
      child: Column(
        children: [
          const PwfSectionTitle(
            title: 'الأنشطة والفعاليات',
            subtitle: 'تعرف على الأنشطة والفعاليات القادمة التي تنظمها الوزارة',
          ),
          const SizedBox(height: 22),
          async.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => _Empty(
              onTap: () => context.go(UnitRoutes.activities(unitSlug)),
            ),
            data: (items) {
              if (items.isEmpty) {
                return _Empty(
                  onTap: () => context.go(UnitRoutes.activities(unitSlug)),
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
                              child: _ActivityCard(unitSlug: unitSlug, a: a),
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                  _ViewAll(
                    text: 'عرض جميع الأنشطة',
                    icon: FontAwesomeIcons.calendarAlt,
                    onTap: () => context.go(UnitRoutes.activities(unitSlug)),
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

class _Empty extends StatelessWidget {
  const _Empty({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'لا توجد أنشطة للعرض حالياً',
          style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: PwfHomePalette.gray,
          ),
        ),
        const SizedBox(height: 18),
        _ViewAll(
          text: 'عرض جميع الأنشطة',
          icon: FontAwesomeIcons.calendarAlt,
          onTap: onTap,
        ),
      ],
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.unitSlug, required this.a});

  final String unitSlug;
  final Activity a;

  @override
  Widget build(BuildContext context) {
    final img = a.imageUrl;

    return PwfHoverable(
      onTap: () => context.go(UnitRoutes.activities(unitSlug)),
      hoverTranslate: const Offset(0, -6),
      borderRadius: PwfHomeRadii.br16,
      child: ClipRRect(
        borderRadius: PwfHomeRadii.br16,
        child: Container(
          color: PwfHomePalette.cardBg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 180,
                child: img == null || img.isEmpty
                    ? Container(
                        color: PwfHomePalette.primary.withValues(alpha: 0.12),
                      )
                    : Image.network(img, fit: BoxFit.cover),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
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
                    Wrap(
                      spacing: 14,
                      runSpacing: 6,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              FontAwesomeIcons.calendarAlt,
                              size: 14,
                              color: PwfHomePalette.gray,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _formatArabicDate(a.startDate),
                              style: GoogleFonts.cairo(
                                fontSize: 12.5,
                                color: PwfHomePalette.gray,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              FontAwesomeIcons.mapMarkerAlt,
                              size: 14,
                              color: PwfHomePalette.gray,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              a.location,
                              style: GoogleFonts.cairo(
                                fontSize: 12.5,
                                color: PwfHomePalette.gray,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      a.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        color: PwfHomePalette.gray,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          'التسجيل في الفعالية',
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: PwfHomePalette.secondary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.arrow_back,
                          size: 16,
                          color: PwfHomePalette.secondary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
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
              FaIcon(widget.icon, size: 16, color: Colors.white),
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
