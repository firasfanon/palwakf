import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/pwf_islamic_patterns_overlay.dart';
import '../widgets/pwf_theme_controls_overlay.dart';
import '../widgets/pwf_scroll_to_top_button.dart';
import '../widgets/header/pwf_header.dart';
import '../providers/pwf_ui_prefs_provider.dart';
import '../theme/pwf_home_palette.dart';

import '../widgets/sections/pwf_home_sections_renderer.dart';
import '../widgets/sections/pwf_login_modal.dart';
import '../widgets/sections/pwf_footer_section.dart';
import 'package:waqf/presentation/providers/homepage_settings_provider.dart';
import 'package:waqf/features/platform/home/presentation/widgets/shared/pwf_public_safe_error.dart';

class PwfHomeWebScreen extends ConsumerStatefulWidget {
  const PwfHomeWebScreen({super.key, this.unitSlug = 'home'});

  final String unitSlug;

  @override
  ConsumerState<PwfHomeWebScreen> createState() => _PwfHomeWebScreenState();
}

class _PwfHomeWebScreenState extends ConsumerState<PwfHomeWebScreen> {
  final ScrollController _scroll = ScrollController();
  bool _showScrollToTop = false;

  // Web-first-paint stabilization: force a safe rebuild once when sections
  // become available, matching the effect of manually re-navigating to /home.
  int _rebuildTick = 0;
  String? _lastStabilizedSig;
  bool _stabilizePending = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_updateScrollToTopVisibility);
  }

  @override
  void dispose() {
    _scroll.removeListener(_updateScrollToTopVisibility);
    _scroll.dispose();
    super.dispose();
  }

  void _updateScrollToTopVisibility() {
    if (!_scroll.hasClients) return;
    final threshold = (_scroll.position.viewportDimension * 0.5).clamp(240.0, 520.0);
    final shouldShow = _scroll.offset > threshold;
    if (shouldShow == _showScrollToTop) return;
    setState(() => _showScrollToTop = shouldShow);
  }

  void _scrollToTop() {
    _scroll.animateTo(
      0,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  String _sigFor(List<dynamic> sections) {
    // Avoid importing model here; use dynamic fields defensively.
    return sections
        .map(
          (s) =>
              '${(s as dynamic).sectionName}:${(s as dynamic).isActive}:${(s as dynamic).displayOrder}',
        )
        .join('|');
  }

  void _scheduleStabilize(String sig) {
    if (_lastStabilizedSig == sig) return;
    if (_stabilizePending) return;
    _stabilizePending = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _rebuildTick++;
        _lastStabilizedSig = sig;
      });

      // A second short tick helps when web fonts/images finalize sizing.
      Future.delayed(const Duration(milliseconds: 60), () {
        if (!mounted) return;
        setState(() {
          _rebuildTick++;
          _stabilizePending = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(pwfUiPrefsProvider);

    final mq = MediaQuery.of(context);
    final scaledMq = mq.copyWith(
      textScaler: TextScaler.linear(prefs.textScale),
    );

    Widget page = MediaQuery(
      data: scaledMq,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: prefs.readMode
              ? const Color(0xFFF6F0DF)
              : (prefs.themeKey == PwfThemeKey.dark
                    ? const Color(0xFF0B1220)
                    : PwfHomePalette.surface),
          body: Stack(
            children: [
              Positioned.fill(
                child: PwfIslamicPatternsOverlay(enabled: !prefs.readMode),
              ),
              Positioned.fill(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Sticky header
                    PwfHeader(unitSlug: widget.unitSlug),

                    // Scrollable body
                    Expanded(
                      child: SingleChildScrollView(
                        key: ValueKey('pwf_home_scroll_$_rebuildTick'),
                        controller: _scroll,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ...ref
                                .watch(
                                  homepageSectionsForUnitProvider(
                                    widget.unitSlug,
                                  ),
                                )
                                .when(
                                  data: (sections) {
                                    final sig = _sigFor(sections);
                                    _scheduleStabilize(sig);

                                    final bool showFooter = sections.any((s) {
                                      final name =
                                          ((s as dynamic).sectionName ?? '')
                                              .toString()
                                              .trim()
                                              .toLowerCase();
                                      return (name == 'pwf_footer' ||
                                              name == 'footer') &&
                                          (s as dynamic).isActive == true;
                                    });

                                    return <Widget>[
                                      PwfHomeSectionsRenderer(
                                        unitSlug: widget.unitSlug,
                                        sections: sections,
                                        renderPinnedHeaderSections: false,
                                        renderPinnedFooterSections: false,
                                      ),
                                      const PwfLoginModal(),
                                      if (showFooter)
                                        PwfFooterSection(
                                          unitSlug: widget.unitSlug,
                                        ),
                                    ];
                                  },
                                  loading: () => const <Widget>[
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 40,
                                      ),
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                  ],
                                  error: (err, st) => <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: SizedBox(
                                        height: 260,
                                        child: PwfPublicSafeErrorPanel(
                                          title: 'تعذر تحميل أقسام الصفحة',
                                          error: err,
                                          onRetry: () => ref.invalidate(
                                            homepageSectionsForUnitProvider(
                                              widget.unitSlug,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const PwfLoginModal(),
                                    // Fail-open footer on error so layout stays stable.
                                    PwfFooterSection(unitSlug: widget.unitSlug),
                                  ],
                                ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const PwfThemeControlsOverlay(),
              Positioned(
                bottom: 110,
                right: 26,
                child: AnimatedScale(
                  scale: _showScrollToTop ? 1 : 0.82,
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  child: AnimatedOpacity(
                    opacity: _showScrollToTop ? 1 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: IgnorePointer(
                      ignoring: !_showScrollToTop,
                      child: PwfScrollToTopButton(
                        heroTag: 'pwf_scroll_top_${widget.unitSlug}',
                        backgroundColor: const Color(0xFFB22222),
                        foregroundColor: Colors.white,
                        elevation: 10,
                        onPressed: _scrollToTop,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Apply theme filter across all sections.
    page = _PwfThemeScope(themeKey: prefs.themeKey, child: page);

    if (prefs.highContrast) {
      page = ColorFiltered(
        colorFilter: const ColorFilter.matrix(<double>[
          1.15,
          0,
          0,
          0,
          -15,
          0,
          1.15,
          0,
          0,
          -15,
          0,
          0,
          1.15,
          0,
          -15,
          0,
          0,
          0,
          1,
          0,
        ]),
        child: page,
      );
    }

    if (prefs.readMode) {
      page = Stack(
        fit: StackFit.expand,
        children: [
          page,
          IgnorePointer(child: ColoredBox(color: const Color(0x14A67C52))),
        ],
      );
    }

    return page;
  }
}

class _PwfThemeScope extends StatelessWidget {
  const _PwfThemeScope({required this.themeKey, required this.child});

  final PwfThemeKey themeKey;
  final Widget child;

  static const _kBlue = Color(0xFF0D4B7A);
  static const _kGold = Color(0xFFD4AF37);
  static const _kRoyalRed = Color(0xFFB22222);

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context);

    ThemeData themed;
    switch (themeKey) {
      case PwfThemeKey.light:
        themed = base.copyWith(
          brightness: Brightness.light,
          colorScheme: base.colorScheme.copyWith(
            brightness: Brightness.light,
            primary: _kBlue,
            secondary: _kGold,
            error: _kRoyalRed,
          ),
        );
        break;

      case PwfThemeKey.dark:
        final darkBase = ThemeData.dark();
        themed = darkBase.copyWith(
          colorScheme: darkBase.colorScheme.copyWith(
            primary: _kBlue,
            secondary: _kGold,
            error: _kRoyalRed,
          ),
        );
        break;

      case PwfThemeKey.islamic:
        themed = base.copyWith(
          brightness: Brightness.light,
          colorScheme: base.colorScheme.copyWith(
            brightness: Brightness.light,
            primary: _kBlue,
            secondary: _kGold,
            error: _kRoyalRed,
          ),
        );
        break;
    }

    Widget wrapped = Theme(data: themed, child: child);

    if (themeKey == PwfThemeKey.dark) {
      wrapped = ColorFiltered(
        colorFilter: const ColorFilter.mode(
          Color(0x66000000),
          BlendMode.darken,
        ),
        child: wrapped,
      );
    }

    return wrapped;
  }
}
