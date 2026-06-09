import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:waqf/app/routing/unit_routes.dart';
import 'package:waqf/app/routing/app_routes.dart';
import 'package:waqf/presentation/providers/unit_dashboard_preview_providers.dart';
import 'package:waqf/data/models/news_article.dart';

import '../../../presentation/theme/pwf_home_palette.dart';
import '../pwf_section_container.dart';
import '../shared/pwf_section_title.dart';
import '../shared/pwf_hoverable.dart';

class PwfNewsSection extends ConsumerWidget {
  const PwfNewsSection({super.key, this.unitSlug = 'home'});

  final String unitSlug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(
      unitLatestNewsPreviewProvider(
        UnitPreviewParams(unitSlug: unitSlug, limit: 5),
      ),
    );

    return Container(
      width: double.infinity,
      color: PwfHomePalette.primary.withValues(alpha: 0.05),
      child: PwfSectionContainer(
        sectionKey: 'PwfNewsSection',
        child: Column(
          children: [
            const PwfSectionTitle(
              title: 'أحدث الأخبار',
              subtitle: 'تابع آخر المستجدات والأنشطة في الوزارة',
            ),
            const SizedBox(height: 22),
            async.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 28),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => _EmptyState(
                onTap: () => context.go(AppRoutes.underConstruction),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return _EmptyState(
                    onTap: () => context.go(UnitRoutes.news(unitSlug)),
                  );
                }

                final main = items.first;
                final side = items.skip(1).take(4).toList();

                return Column(
                  children: [
                    LayoutBuilder(
                      builder: (context, c) {
                        final w = c.maxWidth;
                        final isNarrow = w < 880;

                        return isNarrow
                            ? Column(
                                children: [
                                  _MainNewsCard(
                                    unitSlug: unitSlug,
                                    article: main,
                                  ),
                                  const SizedBox(height: 20),
                                  for (final a in side) ...[
                                    _SideNewsCard(
                                      unitSlug: unitSlug,
                                      article: a,
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                ],
                              )
                            : Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: _MainNewsCard(
                                      unitSlug: unitSlug,
                                      article: main,
                                    ),
                                  ),
                                  const SizedBox(width: 30),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        for (final a in side) ...[
                                          _SideNewsCard(
                                            unitSlug: unitSlug,
                                            article: a,
                                          ),
                                          const SizedBox(height: 20),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              );
                      },
                    ),
                    const SizedBox(height: 30),
                    // HTML uses inline-styled link button.
                    _ViewAllButton(
                      text: 'عرض جميع الأخبار',
                      icon: FontAwesomeIcons.newspaper,
                      onTap: () => context.go(UnitRoutes.news(unitSlug)),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Text(
          'لا توجد أخبار للعرض حالياً',
          style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: PwfHomePalette.gray,
          ),
        ),
        const SizedBox(height: 18),
        _ViewAllButton(
          text: 'عرض جميع الأخبار',
          icon: FontAwesomeIcons.newspaper,
          onTap: onTap,
        ),
      ],
    );
  }
}

class _MainNewsCard extends StatelessWidget {
  const _MainNewsCard({required this.unitSlug, required this.article});
  final String unitSlug;
  final NewsArticle article;

  @override
  Widget build(BuildContext context) {
    final img = article.imageUrl;
    final published = article.publishedAt ?? article.createdAt;

    return PwfHoverable(
      onTap: () => context.go(UnitRoutes.newsDetail(unitSlug, article.id)),
      hoverTranslate: const Offset(0, -5),
      borderRadius: PwfHomeRadii.br16,
      child: ClipRRect(
        borderRadius: PwfHomeRadii.br16,
        child: Container(
          color: PwfHomePalette.cardBg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 300,
                child: img == null || img.isEmpty
                    ? Container(
                        color: PwfHomePalette.primary.withValues(alpha: 0.12),
                      )
                    : Image.network(img, fit: BoxFit.cover),
              ),
              Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MetaRow(date: published, views: article.viewCount),
                    const SizedBox(height: 12),
                    Text(
                      article.title,
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: PwfHomePalette.primary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      article.excerpt,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        color: PwfHomePalette.gray,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _MoreBtn(),
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

class _SideNewsCard extends StatelessWidget {
  const _SideNewsCard({required this.unitSlug, required this.article});
  final String unitSlug;
  final NewsArticle article;

  @override
  Widget build(BuildContext context) {
    final published = article.publishedAt ?? article.createdAt;

    return PwfHoverable(
      onTap: () => context.go(UnitRoutes.newsDetail(unitSlug, article.id)),
      hoverTranslate: const Offset(-5, 0), // matches HTML translateX(-5px)
      borderRadius: PwfHomeRadii.br16,
      child: ClipRRect(
        borderRadius: PwfHomeRadii.br16,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: PwfHomePalette.cardBg,
            borderRadius: PwfHomeRadii.br16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                article.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: PwfHomePalette.primary,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                article.excerpt,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cairo(
                  fontSize: 12.5,
                  color: PwfHomePalette.gray,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 10),
              _MetaRow(date: published, views: article.viewCount),
              const SizedBox(height: 6),
              _MoreBtn(),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoreBtn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'قراءة المزيد',
          style: GoogleFonts.cairo(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: PwfHomePalette.secondary,
          ),
        ),
        const SizedBox(width: 6),
        const Icon(Icons.arrow_back, size: 16, color: PwfHomePalette.secondary),
      ],
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.date, required this.views});
  final DateTime date;
  final int views;

  @override
  Widget build(BuildContext context) {
    return Wrap(
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
              _formatArabicDate(date),
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
              FontAwesomeIcons.eye,
              size: 14,
              color: PwfHomePalette.gray,
            ),
            const SizedBox(width: 6),
            Text(
              '$views مشاهدات',
              style: GoogleFonts.cairo(
                fontSize: 12.5,
                color: PwfHomePalette.gray,
              ),
            ),
          ],
        ),
      ],
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

class _ViewAllButton extends StatefulWidget {
  const _ViewAllButton({
    required this.text,
    required this.icon,
    required this.onTap,
  });

  final String text;
  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_ViewAllButton> createState() => _ViewAllButtonState();
}

class _ViewAllButtonState extends State<_ViewAllButton> {
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
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
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
