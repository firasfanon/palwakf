import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/pwf_home_palette.dart';

/// Sovereign visual contract for PalWakf public homepage sections.
///
/// This file intentionally keeps visual decisions centralized so section
/// widgets do not drift into unrelated palettes, radii, spacing, or card
/// behavior. Sections may still own their content, but chrome, spacing,
/// cards, chips and empty states should be taken from this contract.
class PwfHomeVisualContract {
  static const double maxContentWidth = 1400;
  static const double sectionPaddingDesktop = 42;
  static const double sectionPaddingTablet = 34;
  static const double sectionPaddingMobile = 26;

  static const double subpagePaddingDesktop = 18;
  static const double subpagePaddingTablet = 16;
  static const double subpagePaddingMobile = 14;

  static const double gutterDesktop = 22;
  static const double gutterTablet = 18;
  static const double gutterMobile = 14;

  static const double cardRadius = 18;
  static const double cardPadding = 20;
  static const double compactCardPadding = 16;

  /// Royal red token kept inside the visual contract for sovereign alerts,
  /// errors, and official warning accents.
  static const Color alertAccent = PwfHomePalette.royalRed;

  static const BorderRadius cardBorderRadius = BorderRadius.all(
    Radius.circular(cardRadius),
  );

  static const BoxShadow cardShadow = BoxShadow(
    color: PwfHomePalette.shadow,
    blurRadius: 18,
    offset: Offset(0, 8),
  );

  static const BoxShadow elevatedCardShadow = BoxShadow(
    color: PwfHomePalette.shadow,
    blurRadius: 26,
    offset: Offset(0, 12),
  );

  const PwfHomeVisualContract._();

  static double sectionVerticalPadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 640) return sectionPaddingMobile;
    if (width < 980) return sectionPaddingTablet;
    return sectionPaddingDesktop;
  }

  static double publicSubpageVerticalPadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 640) return subpagePaddingMobile;
    if (width < 980) return subpagePaddingTablet;
    return subpagePaddingDesktop;
  }

  static double gutter(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 640) return gutterMobile;
    if (width < 980) return gutterTablet;
    return gutterDesktop;
  }

  static Color sectionBackground(String? sectionKey) {
    // Platform 12 - Surface Continuity Closure:
    // The public home page uses one continuous sovereign surface on a white sovereign canvas. Grey bands must
    // not appear between active sections after admins hide/reorder content.
    // Section widgets may still paint intentional internal cards/gradients,
    // but the outer flow must stay visually continuous.
    return PwfHomePalette.surface;
  }

  static LinearGradient sovereignGradient({double alpha = 1}) {
    return LinearGradient(
      begin: AlignmentDirectional.topStart,
      end: AlignmentDirectional.bottomEnd,
      colors: [
        PwfHomePalette.primary.withValues(alpha: alpha),
        const Color(0xFF123F7A).withValues(alpha: alpha),
      ],
    );
  }

  static TextStyle sectionTitleStyle(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return GoogleFonts.scheherazadeNew(
      fontSize: width < 640 ? 26 : 31,
      fontWeight: FontWeight.w800,
      color: PwfHomePalette.primary,
      height: 1.12,
    );
  }

  static TextStyle sectionSubtitleStyle(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return GoogleFonts.cairo(
      fontSize: width < 640 ? 13 : 14.25,
      color: const Color(0xFF475569),
      height: 1.58,
      fontWeight: FontWeight.w700,
    );
  }

  static TextStyle onDarkTitleStyle(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return GoogleFonts.scheherazadeNew(
      fontSize: width < 640 ? 24 : 30,
      fontWeight: FontWeight.w800,
      color: Colors.white,
      height: 1.12,
    );
  }

  static TextStyle onDarkBodyStyle(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return GoogleFonts.cairo(
      fontSize: width < 640 ? 13 : 14,
      color: Colors.white.withValues(alpha: 0.96),
      height: 1.65,
      fontWeight: FontWeight.w700,
    );
  }

  static TextStyle cardTitleStyle(BuildContext context) {
    return GoogleFonts.cairo(
      fontSize: 18,
      fontWeight: FontWeight.w800,
      color: PwfHomePalette.dark,
      height: 1.35,
    );
  }

  static TextStyle cardBodyStyle(BuildContext context) {
    return GoogleFonts.cairo(
      fontSize: 14,
      color: const Color(0xFF475569),
      height: 1.55,
      fontWeight: FontWeight.w600,
    );
  }
}

/// Standard card shell for homepage section items.
class PwfVisualCard extends StatelessWidget {
  const PwfVisualCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.backgroundColor = PwfHomePalette.surface,
    this.borderColor = PwfHomePalette.border,
    this.showAccentRail = false,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final Color borderColor;
  final bool showAccentRail;

  @override
  Widget build(BuildContext context) {
    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: padding ?? const EdgeInsets.all(PwfHomeVisualContract.cardPadding),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: PwfHomeVisualContract.cardBorderRadius,
        border: Border.all(color: borderColor),
        boxShadow: const [PwfHomeVisualContract.cardShadow],
      ),
      child: Stack(
        children: [
          if (showAccentRail)
            const PositionedDirectional(
              top: 0,
              bottom: 0,
              start: 0,
              child: _AccentRail(),
            ),
          child,
        ],
      ),
    );

    if (onTap == null) return card;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: onTap,
        borderRadius: PwfHomeVisualContract.cardBorderRadius,
        child: card,
      ),
    );
  }
}

class _AccentRail extends StatelessWidget {
  const _AccentRail();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4,
      decoration: const BoxDecoration(
        color: PwfHomePalette.secondary,
        borderRadius: BorderRadiusDirectional.horizontal(
          start: Radius.circular(PwfHomeVisualContract.cardRadius),
        ),
      ),
    );
  }
}

/// Standard icon tile used by homepage cards.
class PwfVisualIconTile extends StatelessWidget {
  const PwfVisualIconTile({
    super.key,
    required this.icon,
    this.color = PwfHomePalette.primary,
    this.backgroundColor,
    this.size = 54,
  });

  final IconData icon;
  final Color color;
  final Color? backgroundColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.14)),
      ),
      child: Icon(icon, color: color, size: size * 0.46),
    );
  }
}

/// Standard status/category chip.
class PwfVisualChip extends StatelessWidget {
  const PwfVisualChip({
    super.key,
    required this.label,
    this.icon,
    this.color = PwfHomePalette.primary,
  });

  final String label;
  final IconData? icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: color,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

/// Standard empty state for active sections without data.
class PwfVisualEmptyState extends StatelessWidget {
  const PwfVisualEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.action,
  });

  final String title;
  final String message;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return PwfVisualCard(
      borderColor: PwfHomePalette.border,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PwfVisualIconTile(icon: icon, size: 58, color: PwfHomePalette.primary),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: PwfHomeVisualContract.cardTitleStyle(context),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: PwfHomeVisualContract.cardBodyStyle(context),
          ),
          if (action != null) ...[const SizedBox(height: 18), action!],
        ],
      ),
    );
  }
}

/// Responsive card width helper used by several homepage sections.
class PwfVisualResponsiveGrid extends StatelessWidget {
  const PwfVisualResponsiveGrid({
    super.key,
    required this.children,
    this.desktopColumns = 3,
    this.tabletColumns = 2,
    this.minCardWidth = 280,
  });

  final List<Widget> children;
  final int desktopColumns;
  final int tabletColumns;
  final double minCardWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final columns = w >= 1120
            ? desktopColumns
            : (w >= 720 ? tabletColumns : 1);
        final gap = PwfHomeVisualContract.gutter(context);
        final itemWidth = columns == 1
            ? w
            : ((w - ((columns - 1) * gap)) / columns)
                  .clamp(minCardWidth, w)
                  .toDouble();
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final child in children) SizedBox(width: itemWidth, child: child),
          ],
        );
      },
    );
  }
}
