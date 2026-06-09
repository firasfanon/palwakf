import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import 'package:waqf/app/routing/app_routes.dart';
import 'package:waqf/data/models/homepage_section.dart';
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
                      ctaText: s.ctaText ?? 'عرض المزيد',
                      ctaLink: s.ctaLink ?? AppRoutes.underConstruction,
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
    return const [
      _HeroSlideVM(
        title: 'المنصة الإلكترونية المتكاملة لوزارة الأوقاف',
        subtitle:
            'نوفر خدمات إلكترونية متكاملة تسهل الوصول إلى جميع خدمات الوزارة ومعلوماتها',
        imageUrl:
            'https://images.unsplash.com/photo-1587614382346-4ec70e388b28?ixlib=rb-4.0.3&auto=format&fit=crop&w=1470&q=80',
        ctaText: 'خدمات إلكترونية سريعة',
        ctaLink: '#services',
        ctaIcon: FontAwesomeIcons.bolt,
      ),
      _HeroSlideVM(
        title: 'تعزيز التعليم الديني والثقافة الإسلامية',
        subtitle:
            'نشرف على المعاهد الدينية ودور تحفيظ القرآن وندرب الأئمة والدعاة',
        imageUrl:
            'https://images.unsplash.com/photo-1519735777090-ec97162dc266?ixlib=rb-4.0.3&auto=format&fit=crop&w=1470&q=80',
        ctaText: 'روابط مهمة للأوقاف',
        ctaLink: '#links',
        ctaIcon: FontAwesomeIcons.bookOpen,
      ),
      _HeroSlideVM(
        title: 'حماية المقدسات الإسلامية والمسيحية في فلسطين',
        subtitle:
            'نعمل على صيانة وترميم المساجد والكنائس والمقدسات في كافة أنحاء الوطن',
        imageUrl:
            'https://images.unsplash.com/photo-1562774053-701939374585?ixlib=rb-4.0.3&auto=format&fit=crop&w=1470&q=80',
        ctaText: 'ساهم في حماية المقدسات',
        ctaLink: AppRoutes.underConstruction,
        ctaIcon: FontAwesomeIcons.handsHelping,
      ),
    ];
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

    return Container(
      height: 500,
      margin: const EdgeInsets.only(bottom: 40),
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
                key: ValueKey(slide.imageUrl),
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
            top: 225,
            child: _ArrowButton(
              icon: FontAwesomeIcons.chevronRight,
              onTap: onPrev,
            ),
          ),
          Positioned(
            left: 30,
            top: 225,
            child: _ArrowButton(
              icon: FontAwesomeIcons.chevronLeft,
              onTap: onNext,
            ),
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
    final ctaIcon = slide.ctaIcon ?? FontAwesomeIcons.bolt;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 700),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              slide.title,
              style: GoogleFonts.scheherazadeNew(
                fontSize: 44.8,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              slide.subtitle,
              style: GoogleFonts.cairo(
                fontSize: 20.8,
                color: Colors.white.withValues(alpha: 0.90),
              ),
            ),
            const SizedBox(height: 30),
            _HeroCtaButton(
              icon: ctaIcon,
              label: slide.ctaText,
              onTap: () {
                if (slide.ctaLink.startsWith('#')) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('الانتقال داخل الصفحة قيد الربط'),
                    ),
                  );
                  return;
                }
                context.go(slide.ctaLink);
              },
            ),
            if (loading) ...[
              const SizedBox(height: 12),
              Text(
                '...جارِ تحميل محتوى الهيرو من قاعدة البيانات',
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.75),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HeroCtaButton extends StatefulWidget {
  const _HeroCtaButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

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
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          decoration: BoxDecoration(
            color: _hover ? const Color(0xFFB08A40) : PwfHomePalette.secondary,
            borderRadius: PwfHomeRadii.br8,
            boxShadow: _hover ? PwfHomeShadows.cardHover : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(widget.icon, size: 14, color: Colors.white),
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
            child: FaIcon(widget.icon, size: 18, color: Colors.white),
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
