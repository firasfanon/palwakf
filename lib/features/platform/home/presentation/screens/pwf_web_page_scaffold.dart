import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/pwf_ui_prefs_provider.dart';
import '../providers/pwf_accessibility_settings_provider.dart';
import '../widgets/header/pwf_header.dart';
import '../widgets/pwf_islamic_patterns_overlay.dart';
import '../widgets/pwf_scroll_to_top_button.dart';
import '../widgets/pwf_theme_controls_overlay.dart';
import '../widgets/sections/pwf_footer_section.dart';

/// Web-only page shell that preserves the new HTML identity.
///
/// - Sticky header (PwfHeader)
/// - Islamic patterns overlay
/// - Theme controls overlay
/// - Scroll-to-top button
/// - Footer
///
/// This keeps changes localized for this phase (Web identity pages) while
/// letting mobile remain on legacy screens until unified later.
class PwfWebPageScaffold extends ConsumerStatefulWidget {
  const PwfWebPageScaffold({
    super.key,
    required this.child,
    this.unitSlug = 'home',
    this.title,
    this.showTitleSection = false,
  });

  final Widget child;
  final String unitSlug;

  /// Optional title for a simple title section.
  final String? title;

  /// If true, renders a small title block (keeps the same HTML identity).
  final bool showTitleSection;

  @override
  ConsumerState<PwfWebPageScaffold> createState() => _PwfWebPageScaffoldState();
}

class _PwfWebPageScaffoldState extends ConsumerState<PwfWebPageScaffold> {
  final ScrollController _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(pwfUiPrefsProvider);
    final accessibility = ref.watch(pwfAccessibilitySettingsProvider);
    final isDark = prefs.themeKey == PwfThemeKey.dark;
    final scale = (accessibility.fontPx / 16.0).clamp(0.85, 1.45);

    Widget body = PrimaryScrollController(
      controller: _scroll,
      child: Stack(
        children: [
          const Positioned.fill(child: PwfIslamicPatternsOverlay()),
          Positioned.fill(
            child: CustomScrollView(
              controller: _scroll,
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _PwfStickyHeaderDelegate(
                    child: PwfHeader(unitSlug: widget.unitSlug),
                  ),
                ),
                SliverToBoxAdapter(child: widget.child),
                SliverToBoxAdapter(
                  child: PwfFooterSection(unitSlug: widget.unitSlug),
                ),
              ],
            ),
          ),

          // overlays (always above content)
          const PwfThemeControlsOverlay(),

          Positioned(
            // Keep the button above the footer area (especially on
            // under-construction where content is short).
            bottom: 110,
            right: 26,
            child: PwfScrollToTopButton(
              heroTag: 'pwf_scroll_top_${widget.unitSlug}',
              backgroundColor: const Color(0xFFB22222),
              foregroundColor: Colors.white,
              elevation: 10,
              onPressed: () {
                if (!_scroll.hasClients) return;
                _scroll.animateTo(
                  0,
                  duration: const Duration(milliseconds: 450),
                  curve: Curves.easeOutCubic,
                );
              },
            ),
          ),
        ],
      ),
    );

    if (accessibility.highContrast) {
      body = ColorFiltered(
        colorFilter: const ColorFilter.matrix(<double>[
          1.2,
          0,
          0,
          0,
          -12,
          0,
          1.2,
          0,
          0,
          -12,
          0,
          0,
          1.2,
          0,
          -12,
          0,
          0,
          0,
          1,
          0,
        ]),
        child: body,
      );
    }

    if (accessibility.readingMode) {
      body = Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1320),
          child: body,
        ),
      );
    }

    body = MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(scale)),
      child: body,
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark
            ? const Color(0xFF0B1220)
            : const Color(0xFFF6F7FB),
        body: _PwfThemeScope(themeKey: prefs.themeKey, child: body),
      ),
    );
  }
}

class _PwfStickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  _PwfStickyHeaderDelegate({required this.child});

  final Widget child;

  // The header is composed of: TopBar + MainHeader + MainNav.
  // It is taller than 140px; keeping it too small causes overflow
  // warnings (especially on internal pages using slivers).
  static const double _extent = 256;

  @override
  double get minExtent => _extent;

  @override
  double get maxExtent => _extent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(elevation: overlapsContent ? 2 : 0, child: child);
  }

  @override
  bool shouldRebuild(covariant _PwfStickyHeaderDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}

/// Applies a lightweight ThemeData swap so theme/night controls affect
/// all pages without using a global ColorFilter (which caused grey overlay).
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

    themed = themed.copyWith(
      tabBarTheme: themed.tabBarTheme.copyWith(
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withValues(alpha: 0.84),
        indicatorColor: Colors.white,
        dividerColor: Colors.transparent,
      ),
      chipTheme: themed.chipTheme.copyWith(
        backgroundColor: Colors.white,
        selectedColor: _kBlue,
        secondarySelectedColor: _kBlue,
        labelStyle: const TextStyle(
          color: Color(0xFF0F172A),
          fontWeight: FontWeight.w700,
        ),
        secondaryLabelStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
    );

    // Apply ThemeData first.
    Widget wrapped = Theme(data: themed, child: child);

    // Make dark mode visually affect all sections (even those with fixed
    // palette colors) without the grey wash that a global matrix filter caused.
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
