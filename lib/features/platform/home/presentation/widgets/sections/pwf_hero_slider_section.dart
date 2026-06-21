import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import 'package:waqf/app/routing/app_routes.dart';
import 'package:waqf/features/platform/home/presentation/config/pwf_home_hero_landmarks.dart';
import 'package:waqf/data/repositories/homepage_repository.dart' show HeroSlide;
import 'package:waqf/presentation/widgets/home/hero_slider.dart'
    show heroSlidesForUnitProvider;
import 'package:waqf/features/platform/public_runtime/presentation/widgets/pwf_public_image_fallback.dart';
import 'package:waqf/features/platform/home/data/models/pwf_unit_public_sovereign_models.dart';
import 'package:waqf/features/platform/home/presentation/providers/pwf_unit_public_sovereign_providers.dart';

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

  bool _reduceMotion = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion =
        MediaQuery.maybeOf(context)?.accessibleNavigation ?? false;
    if (reduceMotion == _reduceMotion && (_timer != null || reduceMotion)) {
      return;
    }

    _reduceMotion = reduceMotion;
    _timer?.cancel();
    _timer = null;
    if (_reduceMotion) return;

    _timer = Timer.periodic(const Duration(seconds: 7), (_) {
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
    final normalized = widget.unitSlug.trim().toLowerCase();

    // Platform 15 Hero Identity Closure: the ministry homepage uses only the
    // approved local landmark catalog. This avoids remote demo image requests
    // and makes the exact national identity deterministic without changing
    // homepage data, media-center ownership, or any database contract.
    if (normalized == 'home') {
      final slides = _homeLandmarkSlides();
      return _HeroSliderBody(
        slides: slides,
        index: (_index % slides.length).toInt(),
        onDot: _goTo,
        onPrev: () => _prev(slides.length),
        onNext: () => _next(slides.length),
      );
    }

    final profileAsync = ref.watch(
      pwfUnitPublicProfileBySlugProvider(normalized.isEmpty ? 'home' : normalized),
    );
    final slidesAsync = ref.watch(heroSlidesForUnitProvider(widget.unitSlug));

    return profileAsync.when(
      loading: () => _buildWithProfile(context, slidesAsync, null, loading: true),
      error: (_, __) => _buildWithProfile(context, slidesAsync, null),
      data: (profile) => _buildWithProfile(context, slidesAsync, profile),
    );
  }

  Widget _buildWithProfile(
    BuildContext context,
    AsyncValue<List<HeroSlide>> slidesAsync,
    PwfUnitPublicProfile? profile, {
    bool loading = false,
  }) {
    final normalized = widget.unitSlug.trim().toLowerCase();
    final profileSlides = _profileSlides(profile, normalized);
    if (profileSlides.isNotEmpty) {
      return _HeroSliderBody(
        slides: profileSlides,
        index: (_index % profileSlides.length).toInt(),
        onDot: _goTo,
        onPrev: () => _prev(profileSlides.length),
        onNext: () => _next(profileSlides.length),
        loading: loading,
      );
    }

    // A directorate without a published profile must remain local and explicit.
    // It must never borrow the ministry hero, arbitrary stock images, or a
    // guessed landmark while profile governance is still incomplete.
    if (normalized.isNotEmpty && normalized != 'home') {
      final placeholder = <_HeroSlideVM>[
        _HeroSlideVM(
          title: (profile?.unitNameAr ?? '').trim().isNotEmpty
              ? profile!.unitNameAr
              : 'بيانات الوحدة غير منشورة',
          subtitle: 'تعرض هذه البوابة محتوى الوحدة فقط. لم تُعتمد بعد بيانات Hero الرسمية لهذه الوحدة.',
          imageUrl: '',
          ctaText: 'اتصل بالوحدة',
          ctaLink: '/$normalized/contact',
          ctaIcon: Icons.contact_page_outlined,
        ),
      ];
      return _HeroSliderBody(
        slides: placeholder,
        index: 0,
        onDot: _goTo,
        onPrev: () {},
        onNext: () {},
        loading: loading,
      );
    }

    final fallback = _homeLandmarkSlides();
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
          loading: loading,
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

  List<_HeroSlideVM> _profileSlides(
    PwfUnitPublicProfile? profile,
    String normalized,
  ) {
    if (profile == null || !profile.isPublished) return const <_HeroSlideVM>[];
    final title = (profile.heroTitleAr ?? '').trim();
    final imageUrl = (profile.heroImageUrl ?? '').trim();
    if (title.isEmpty || imageUrl.isEmpty) return const <_HeroSlideVM>[];
    return <_HeroSlideVM>[
      _HeroSlideVM(
        title: title,
        subtitle: (profile.heroSubtitleAr ?? '').trim().isEmpty
            ? 'البوابة العامة لـ ${profile.unitNameAr}'
            : profile.heroSubtitleAr!.trim(),
        imageUrl: imageUrl,
        ctaText: 'اتصل بالوحدة',
        ctaLink: '/${profile.publicSlug.isEmpty ? normalized : profile.publicSlug}/contact',
        ctaIcon: Icons.contact_page_outlined,
      ),
    ];
  }

  List<_HeroSlideVM> _homeLandmarkSlides() {
    return PwfHomeHeroLandmarks.slides
        .map(
          (slide) => _HeroSlideVM(
            title: slide.title,
            subtitle: slide.subtitle,
            imageUrl: slide.assetPath,
            ctaText: slide.ctaText,
            ctaLink: slide.ctaLink,
            ctaIcon: slide.ctaIcon,
            imageAlignment: slide.imageAlignment,
          ),
        )
        .toList(growable: false);
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

    final mediaSize = MediaQuery.sizeOf(context);
    final width = mediaSize.width;
    final viewportHeight = mediaSize.height;

    // Platform 12 — Adaptive Hero Fold Closure:
    // The hero must behave as the visual first-fold block whether the breaking
    // news strip is active or disabled. Use a viewport-aware target instead of
    // a fixed section height so hidden sections above/below the hero do not
    // leave a perceived short fold before the next homepage section.
    final baseHeroHeight = width >= 1400
        ? 660.0
        : width >= 1200
        ? 635.0
        : width >= 992
        ? 610.0
        : width >= 768
        ? 540.0
        : 450.0;
    final heroExtra = width >= 768 ? 86.0 : 42.0;
    final firstFoldTarget = width >= 992
        ? (viewportHeight * 0.80).clamp(690.0, 840.0).toDouble()
        : width >= 768
        ? (viewportHeight * 0.68).clamp(540.0, 680.0).toDouble()
        : (viewportHeight * 0.62).clamp(450.0, 620.0).toDouble();
    final heroHeight = math.max(baseHeroHeight + heroExtra, firstFoldTarget);

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
                alignment: slide.imageAlignment,
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
            child: _ArrowButton(icon: Icons.chevron_left, onTap: onPrev),
          ),
          Positioned(
            left: 30,
            top: (heroHeight / 2) - 25,
            child: _ArrowButton(icon: Icons.chevron_right, onTap: onNext),
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
  const _HeroBackground({
    super.key,
    required this.imageUrl,
    required this.alignment,
  });

  final String imageUrl;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: PwfPublicImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        // Lower focal point keeps the visual subject inside the taller hero.
        // UAT showed several DB-managed images still looked pulled upward when
        // sections above the hero were disabled; a lower focus reveals more of
        // the lower half while keeping a full-bleed cover without grey bands.
        alignment: alignment,
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
    this.imageAlignment = const Alignment(0, 0.36),
  });

  final String title;
  final String subtitle;
  final String imageUrl;
  final String ctaText;
  final String ctaLink;
  final IconData? ctaIcon;
  final AlignmentGeometry imageAlignment;
}
