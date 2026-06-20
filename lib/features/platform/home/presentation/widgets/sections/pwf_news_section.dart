import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:waqf/app/routing/unit_routes.dart';
import 'package:waqf/presentation/providers/unit_dashboard_preview_providers.dart';
import 'package:waqf/presentation/providers/homepage_settings_provider.dart';
import 'package:waqf/presentation/providers/unit_context_provider.dart';
import 'package:waqf/data/models/news_article.dart';
import 'package:waqf/features/platform/public_runtime/presentation/widgets/pwf_public_image_fallback.dart';

import '../../../presentation/theme/pwf_home_palette.dart';
import '../pwf_section_container.dart';
import '../shared/pwf_section_title.dart';
import '../shared/pwf_hoverable.dart';
import '../../screens/pages/pwf_public_content_shared.dart';
import 'pwf_content_display_settings.dart';

class PwfNewsSection extends ConsumerWidget {
  const PwfNewsSection({
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
              aliases: const ['pwf_news_tabs', 'pwf_news'],
            ),
            orElse: () => null,
          );
    final display = PwfContentDisplaySettings.fromMap(
      resolvedSettings,
      defaultHomeLimit: 5,
    );
    final async = ref.watch(
      unitLatestNewsPreviewProvider(
        UnitPreviewParams(unitSlug: unitSlug, limit: display.homeLimit),
      ),
    );
    final complementaryAsync = ref.watch(
      complementaryLatestNewsPreviewProvider(
        UnitPreviewParams(unitSlug: unitSlug, limit: 3),
      ),
    );
    final isHomeScope = unitSlug.trim().toLowerCase() == 'home';
    final unit = ref.watch(orgUnitBySlugProvider(unitSlug)).valueOrNull;
    final scopeLabel = pwfResolveScopeLabel(unitSlug: unitSlug, unit: unit);

    return PwfSectionContainer(
      sectionKey: 'PwfNewsSection',
      child: Column(
          children: [
            PwfSectionTitle(
              title: isHomeScope ? 'أحدث الأخبار' : 'أخبار $scopeLabel',
              subtitle: isHomeScope
                  ? 'آخر أخبار الوزارة الرسمية مع نافذة مختصرة لأخبار المحافظات والوحدات.'
                  : 'أحدث الأخبار المنشورة لهذه الجهة دون خلط مع أخبار الوزارة المركزية.',
            ),
            const SizedBox(height: 22),
            async.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 28),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => _EmptyState(
                onTap: () => context.go(UnitRoutes.news(unitSlug)),
                showViewAll: display.showViewAll,
              ),
              data: (items) {
                if (items.isEmpty) {
                  return _EmptyState(
                    onTap: () => context.go(UnitRoutes.news(unitSlug)),
                    showViewAll: display.showViewAll,
                  );
                }

                final main = items.first;
                final sideCount = display.homeLimit > 1
                    ? display.homeLimit - 1
                    : 0;
                final side = items.skip(1).take(sideCount).toList();
                final complementaryPreview =
                    complementaryAsync.valueOrNull ?? const <NewsArticle>[];
                final secondaryMain = isHomeScope && complementaryPreview.isNotEmpty
                    ? complementaryPreview.first
                    : null;
                final complementaryRest = secondaryMain == null
                    ? complementaryPreview
                    : complementaryPreview.skip(1).toList(growable: false);

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
                                  if (secondaryMain != null) ...[
                                    const SizedBox(height: 18),
                                    _SecondaryMainNewsCard(
                                      unitSlug: unitSlug,
                                      article: secondaryMain,
                                    ),
                                  ],
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
                                    child: Column(
                                      children: [
                                        _MainNewsCard(
                                          unitSlug: unitSlug,
                                          article: main,
                                        ),
                                        if (secondaryMain != null) ...[
                                          const SizedBox(height: 20),
                                          _SecondaryMainNewsCard(
                                            unitSlug: unitSlug,
                                            article: secondaryMain,
                                          ),
                                        ],
                                      ],
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
                    const SizedBox(height: 24),
                    if (complementaryRest.isNotEmpty)
                      _ComplementaryNewsStrip(
                        unitSlug: unitSlug,
                        isHomeScope: isHomeScope,
                        items: complementaryRest,
                      ),
                    if (display.showViewAll) ...[
                      const SizedBox(height: 30),
                      _ViewAllButton(
                        text: 'عرض جميع الأخبار',
                        icon: Icons.article,
                        onTap: () => context.go(UnitRoutes.news(unitSlug)),
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onTap, required this.showViewAll});
  final VoidCallback onTap;
  final bool showViewAll;

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
        if (showViewAll) ...[
          const SizedBox(height: 18),
          _ViewAllButton(
            text: 'عرض جميع الأخبار',
            icon: Icons.article,
            onTap: onTap,
          ),
        ],
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
      onTap: () => context.go(UnitRoutes.newsDetail(unitSlug, article.publicDetailId)),
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
                    : PwfPublicImage(imageUrl: img, fit: BoxFit.cover),
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

class _SecondaryMainNewsCard extends StatelessWidget {
  const _SecondaryMainNewsCard({required this.unitSlug, required this.article});

  final String unitSlug;
  final NewsArticle article;

  @override
  Widget build(BuildContext context) {
    final published = article.publishedAt ?? article.createdAt;
    final img = article.imageUrl;

    return PwfHoverable(
      onTap: () => context.go(UnitRoutes.newsDetail(unitSlug, article.publicDetailId)),
      hoverTranslate: const Offset(0, -4),
      borderRadius: PwfHomeRadii.br16,
      child: ClipRRect(
        borderRadius: PwfHomeRadii.br16,
        child: Container(
          decoration: BoxDecoration(
            color: PwfHomePalette.cardBg,
            border: Border.all(
              color: PwfHomePalette.secondary.withValues(alpha: 0.18),
            ),
            borderRadius: PwfHomeRadii.br16,
          ),
          child: LayoutBuilder(
            builder: (context, c) {
              final wide = c.maxWidth >= 560;
              final media = ClipRRect(
                borderRadius: wide
                    ? const BorderRadiusDirectional.horizontal(
                        start: Radius.circular(16),
                      )
                    : const BorderRadius.vertical(top: Radius.circular(16)),
                child: SizedBox(
                  width: wide ? 190 : double.infinity,
                  height: wide ? 156 : 150,
                  child: img == null || img.isEmpty
                      ? const _NewsThumbnailFallback(
                          icon: Icons.account_tree_outlined,
                        )
                      : PwfPublicImage(imageUrl: img, fit: BoxFit.cover),
                ),
              );
              final content = Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: _SecondaryMainNewsContent(
                    article: article,
                    published: published,
                  ),
                ),
              );

              if (!wide) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    media,
                    Padding(
                      padding: const EdgeInsets.all(18),
                      child: _SecondaryMainNewsContent(
                        article: article,
                        published: published,
                      ),
                    ),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [media, content],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SecondaryMainNewsContent extends StatelessWidget {
  const _SecondaryMainNewsContent({
    required this.article,
    required this.published,
  });

  final NewsArticle article;
  final DateTime published;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: PwfHomePalette.secondary.withValues(alpha: 0.12),
            borderRadius: PwfHomeRadii.br30,
          ),
          child: Text(
            'خبر رئيسي من وحدة فرعية',
            style: GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: PwfHomePalette.secondary,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          article.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: PwfHomePalette.primary,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          article.excerpt,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.cairo(
            fontSize: 12.5,
            color: PwfHomePalette.gray,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 10),
        _MetaRow(date: published, views: article.viewCount),
      ],
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
    final img = article.imageUrl;

    return PwfHoverable(
      onTap: () => context.go(UnitRoutes.newsDetail(unitSlug, article.publicDetailId)),
      hoverTranslate: const Offset(-5, 0),
      borderRadius: PwfHomeRadii.br16,
      child: ClipRRect(
        borderRadius: PwfHomeRadii.br16,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: PwfHomePalette.cardBg,
            borderRadius: PwfHomeRadii.br16,
            border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _NewsThumbnail(imageUrl: img),
              const SizedBox(width: 14),
              Expanded(
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
                    const SizedBox(height: 7),
                    Text(
                      article.excerpt,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        fontSize: 12.5,
                        color: PwfHomePalette.gray,
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _MetaRow(date: published, views: article.viewCount),
                    const SizedBox(height: 4),
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

class _NewsThumbnail extends StatelessWidget {
  const _NewsThumbnail({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final value = (imageUrl ?? '').trim();
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: 96,
        height: 86,
        child: value.isEmpty
            ? const _NewsThumbnailFallback(icon: Icons.article_outlined)
            : PwfPublicImage(imageUrl: value, fit: BoxFit.cover),
      ),
    );
  }
}

class _NewsThumbnailFallback extends StatelessWidget {
  const _NewsThumbnailFallback({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            PwfHomePalette.primary.withValues(alpha: 0.14),
            PwfHomePalette.secondary.withValues(alpha: 0.10),
          ],
        ),
      ),
      child: Icon(icon, color: PwfHomePalette.primary.withValues(alpha: 0.75)),
    );
  }
}

class _MoreBtn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final compact = width < 86;

        return Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Flexible(
              child: Text(
                'قراءة المزيد',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: PwfHomePalette.secondary,
                ),
              ),
            ),
            if (!compact) ...[
              const SizedBox(width: 6),
              const Icon(
                Icons.arrow_back,
                size: 16,
                color: PwfHomePalette.secondary,
              ),
            ],
          ],
        );
      },
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.date, required this.views});
  final DateTime date;
  final int views;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boundedWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final narrow = boundedWidth < 180;
        final itemWidth = narrow
            ? boundedWidth.clamp(56.0, 180.0).toDouble()
            : boundedWidth.clamp(120.0, 220.0).toDouble();
        final items = [
          _MetaItem(
            icon: FontAwesomeIcons.calendarAlt,
            label: _formatArabicDate(date),
            maxWidth: itemWidth,
          ),
          _MetaItem(
            icon: FontAwesomeIcons.eye,
            label: '$views مشاهدات',
            maxWidth: itemWidth,
          ),
        ];

        if (narrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < items.length; i++) ...[
                items[i],
                if (i != items.length - 1) const SizedBox(height: 6),
              ],
            ],
          );
        }

        return Wrap(spacing: 14, runSpacing: 6, children: items);
      },
    );
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({
    required this.icon,
    required this.label,
    required this.maxWidth,
  });

  final FaIconData icon;
  final String label;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(icon, size: 14, color: PwfHomePalette.gray),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style: GoogleFonts.cairo(
                fontSize: 12.5,
                color: PwfHomePalette.gray,
              ),
            ),
          ),
        ],
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

class _ComplementaryNewsStrip extends StatelessWidget {
  const _ComplementaryNewsStrip({
    required this.unitSlug,
    required this.isHomeScope,
    required this.items,
  });

  final String unitSlug;
  final bool isHomeScope;
  final List<NewsArticle> items;

  @override
  Widget build(BuildContext context) {
    final title = isHomeScope
        ? 'من أخبار المحافظات والوحدات'
        : 'أخبار مرتبطة';
    final subtitle = isHomeScope
        ? 'نافذة إضافية تُبرز أخبار الجهات والوحدات خارج الصفحة الرئيسية.'
        : 'مساحة مختصرة للأخبار المرتبطة بهذه الجهة فقط دون fallback وزاري.';

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
                      UnitRoutes.newsDetail(unitSlug, item.publicDetailId),
                      extra: item,
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
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: SizedBox(
                              height: 104,
                              width: double.infinity,
                              child: (item.imageUrl ?? '').trim().isEmpty
                                  ? const _NewsThumbnailFallback(
                                      icon: Icons.account_tree_outlined,
                                    )
                                  : PwfPublicImage(
                                      imageUrl: item.imageUrl,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          const SizedBox(height: 12),
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
                            item.excerpt,
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
