import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import 'package:waqf/app/routing/app_routes.dart';
import 'package:waqf/presentation/widgets/home/hero_slider.dart'
    show heroSlidesForUnitProvider;
import 'package:waqf/features/platform/public_runtime/presentation/widgets/pwf_public_image_fallback.dart';

import '../../theme/pwf_home_palette.dart';
import '../pwf_web_container.dart';

/// HTML-exact Hero Slider (height: 500px, dot nav, arrows, fade transition).
class PwfHeroSliderSection extends ConsumerStatefulWidget {
  const PwfHeroSliderSection({super.key, this.unitSlug = 'home'});

  final String unitSlug;

  @override
  ConsumerState<PwfHeroSliderSection> createState() =>
      _PwfHeroSliderSectionState();
}

class _PwfHeroSliderSectionState extends ConsumerState<PwfHeroSliderSection> {
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (!mounted) return;
      setState(() => _index++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _goTo(int i) {
    setState(() => _index = i);
  }

  void _prev(int count) {
    setState(() => _index = (_index - 1 + count) % count);
  }

  void _next(int count) {
    setState(() => _index = (_index + 1) % count);
  }

  @override
  Widget build(BuildContext context) {
    final slidesAsync = ref.watch(heroSlidesForUnitProvider(widget.unitSlug));
    final List<_HeroSlideVM> fallback = _defaultSlides(context);

    return slidesAsync.when(
      data: (dbSlides) {
        final slides = dbSlides.isEmpty
            ? fallback
            : dbSlides
                  .map(
                    (s) => _HeroSlideVM(
                      title: s.title,
                      subtitle: s.subtitle.isNotEmpty
                          ? s.subtitle
                          : s.description,
                      imageUrl: s.imageUrl,
                      ctaText: s.ctaText.isNotEmpty ? s.ctaText : 'عرض المزيد',
                      ctaLink: _resolveHeroLink(s.ctaLink),
                    ),
                  )
                  .toList();
        return _HeroSliderBody(
          slides: slides,
          index: (_index % slides.length).toInt(),
          onDot: _goTo,
          onPrev: () => _prev(slides.length),
          onNext: () => _next(slides.length),
        );
      },
      error: (_, __) => _HeroSliderBody(
        slides: fallback,
        index: (_index % fallback.length).toInt(),
        onDot: _goTo,
        onPrev: () => _prev(fallback.length),
        onNext: () => _next(fallback.length),
      ),
      loading: () => _HeroSliderBody(
        slides: fallback,
        index: (_index % fallback.length).toInt(),
        onDot: _goTo,
        onPrev: () => _prev(fallback.length),
        onNext: () => _next(fallback.length),
        loading: true,
      ),
    );
  }

  List<_HeroSlideVM> _defaultSlides(BuildContext context) {
    return [
      _HeroSlideVM(
        title: 'المنصة الإلكترونية المتكاملة لوزارة الأوقاف',
        subtitle:
            'نوفر خدمات إلكترونية متكاملة تسهل الوصول إلى جميع خدمات الوزارة ومعلوماتها',
        imageUrl:
            'https://images.unsplash.com/photo-1587614382346-4ec70e388b28?ixlib=rb-4.0.3&auto=format&fit=crop&w=1470&q=80',
        ctaText: 'خدمات إلكترونية سريعة',
        ctaLink: AppRoutes.services,
        ctaIcon: Icons.bolt,
      ),
      _HeroSlideVM(
        title: 'تعزيز التعليم الديني والثقافة الإسلامية',
        subtitle:
            'نشرف على المعاهد الدينية ودور تحفيظ القرآن وندرب الأئمة والدعاة',
        imageUrl:
            'https://images.unsplash.com/photo-1519735777090-ec97162dc266?ixlib=rb-4.0.3&auto=format&fit=crop&w=1470&q=80',
        ctaText: 'روابط مهمة للأوقاف',
        ctaLink: AppRoutes.eservices,
        ctaIcon: Icons.menu_book,
      ),
      _HeroSlideVM(
        title: 'حماية المقدسات الإسلامية والمسيحية في فلسطين',
        subtitle:
            'نعمل على صيانة وترميم المساجد والكنائس والمقدسات في كافة أنحاء الوطن',
        imageUrl:
            'https://images.unsplash.com/photo-1562774053-701939374585?ixlib=rb-4.0.3&auto=format&fit=crop&w=1470&q=80',
        ctaText: 'ساهم في حماية المقدسات',
        ctaLink: AppRoutes.contact,
        ctaIcon: Icons.volunteer_activism,
      ),
    ];
  }
}

String _resolveHeroLink(String? raw) {
  final value = (raw ?? '').trim();
  if (value.isEmpty) return AppRoutes.services;
  switch (value) {
    case '#services':
      return AppRoutes.services;
    case '#links':
      return AppRoutes.eservices;
    case 'e-services':
    case '/e-services':
      return AppRoutes.eservices;
    default:
      return value.startsWith('/') ? value : '/$value';
  }
}

class _HeroSliderBody extends StatelessWidget {
  const _HeroSliderBody({
    required this.slides,
    required this.index,
    required this.onDot,
    required this.onPrev,
    required this.onNext,
    this.loading = false,
  });

  final List<_HeroSlideVM> slides;
  final int index;
  final void Function(int) onDot;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final slide = slides[index];

    final width = MediaQuery.sizeOf(context).width;
    final heroHeight = width >= 1400
        ? 620.0
        : width >= 1200
        ? 590.0
        : width >= 992
        ? 560.0
        : width >= 768
        ? 500.0
        : 420.0;

    return SizedBox(
      height: heroHeight,
      child: Stack(
        children: [
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 900),
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              // AnimatedSwitcher defaults to sizing itself to its child.
              // We need the background to always fill the whole hero area.
              layoutBuilder: (currentChild, previousChildren) {
                return Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    ...previousChildren,
                    if (currentChild != null) currentChild,
                  ],
                );
              },
              child: _HeroBackground(
                // DB-managed hero slides can intentionally reuse the same
                // image URL. AnimatedSwitcher keeps outgoing children during
                // the fade; therefore imageUrl-only keys can collide and throw
                // "Duplicate keys found" when two adjacent slides share a
                // background. Include the active index and title while keeping
                // the key deterministic for stable transitions.
                key: ValueKey(
                  'hero-bg-$index-${slide.title}-${slide.imageUrl}',
                ),
                imageUrl: slide.imageUrl,
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [Color(0xB3000000), Color(0x4D000000)],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerRight,
              child: PwfWebContainer(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 0),
                  child: _HeroText(slide: slide, loading: loading),
                ),
              ),
            ),
          ),

          // Arrows
          Positioned(
            right: 30,
            top: (heroHeight / 2) - 25,
            child: _ArrowButton(icon: Icons.chevron_right, onTap: onPrev),
          ),
          Positioned(
            left: 30,
            top: (heroHeight / 2) - 25,
            child: _ArrowButton(icon: Icons.chevron_left, onTap: onNext),
          ),

          // Dots (bottom centered)
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < slides.length; i++)
                  _Dot(active: i == index, onTap: () => onDot(i)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroBackground extends StatelessWidget {
  const _HeroBackground({super.key, required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: PwfPublicImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        fallbackColor: Colors.black.withValues(alpha: 0.2),
      ),
    );
  }
}

class _HeroText extends StatelessWidget {
  const _HeroText({required this.slide, required this.loading});

  final _HeroSlideVM slide;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final ctaIcon = slide.ctaIcon ?? Icons.bolt;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 700),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : MediaQuery.sizeOf(context).width;
          final isVeryNarrow = availableWidth < 380;
          final isCompact = availableWidth < 520;

          final horizontalPadding = isVeryNarrow
              ? 18.0
              : isCompact
              ? 28.0
              : 60.0;
          final titleFontSize = isVeryNarrow
              ? 28.0
              : isCompact
              ? 34.0
              : 44.8;
          final subtitleFontSize = isVeryNarrow
              ? 14.5
              : isCompact
              ? 16.5
              : 20.8;
          final titleMaxLines = isVeryNarrow ? 3 : 4;
          final subtitleMaxLines = isVeryNarrow ? 3 : 4;
          final titleGap = isVeryNarrow ? 12.0 : 20.0;
          final ctaGap = isVeryNarrow ? 18.0 : 30.0;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slide.title,
                  maxLines: titleMaxLines,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.scheherazadeNew(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.15,
                  ),
                ),
                SizedBox(height: titleGap),
                Text(
                  slide.subtitle,
                  maxLines: subtitleMaxLines,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    fontSize: subtitleFontSize,
                    color: Colors.white.withValues(alpha: 0.90),
                    height: 1.45,
                  ),
                ),
                SizedBox(height: ctaGap),
                _HeroCtaButton(
                  icon: ctaIcon,
                  label: slide.ctaText,
                  compact: isVeryNarrow,
                  onTap: () {
                    context.go(_resolveHeroLink(slide.ctaLink));
                  },
                ),
                if (loading) ...[
                  const SizedBox(height: 12),
                  Text(
                    '...جارِ تحميل محتوى الهيرو من قاعدة البيانات',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HeroCtaButton extends StatefulWidget {
  const _HeroCtaButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.compact = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool compact;

  @override
  State<_HeroCtaButton> createState() => _HeroCtaButtonState();
}

class _HeroCtaButtonState extends State<_HeroCtaButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: widget.compact ? 16 : 22,
            vertical: widget.compact ? 10 : 12,
          ),
          decoration: BoxDecoration(
            color: _hover ? const Color(0xFFB08A40) : PwfHomePalette.secondary,
            borderRadius: PwfHomeRadii.br8,
            boxShadow: _hover ? PwfHomeShadows.cardHover : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 14, color: Colors.white),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    fontSize: widget.compact ? 13 : 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArrowButton extends StatefulWidget {
  const _ArrowButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_ArrowButton> createState() => _ArrowButtonState();
}

class _ArrowButtonState extends State<_ArrowButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: (_hover
                ? Colors.black.withValues(alpha: 0.80)
                : Colors.black.withValues(alpha: 0.50)),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(widget.icon, size: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  const _Dot({required this.active, required this.onTap});

  final bool active;
  final VoidCallback onTap;

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final Color color = widget.active
        ? PwfHomePalette.secondary
        : (_hover
              ? Colors.white.withValues(alpha: 0.75)
              : Colors.white.withValues(alpha: 0.50));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7.5),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 12,
            height: 12,
            transform: widget.active ? (Matrix4.identity()..scale(1.2)) : null,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }
}

class _HeroSlideVM {
  const _HeroSlideVM({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.ctaText,
    required this.ctaLink,
    this.ctaIcon,
  });

  final String title;
  final String subtitle;
  final String imageUrl;
  final String ctaText;
  final String ctaLink;
  final IconData? ctaIcon;
}
