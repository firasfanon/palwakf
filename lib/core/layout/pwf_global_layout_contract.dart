import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// PalWakf global layout contract.
///
/// This file is intentionally the single shared implementation surface for
/// cross-page layout hardening. Screens may still own their business widgets,
/// but all admin/public/system pages must use these bounded helpers when they
/// render rows, pills, chips, split panes, preview frames, and narrow panels.
///
/// Governing rules:
/// - One scroll owner per page/panel.
/// - Never place Expanded/Flexible inside an unbounded scroll/menu surface.
/// - Rows must either be width-bounded or degrade to Wrap/Column.
/// - Text inside rows/pills/cards must be max-lines + ellipsis constrained.
/// - Admin content must be finite-height inside the platform shell.
/// - No SQL/RPC/RBAC ownership changes are performed by this file.
class PwfGlobalLayoutContract {
  static const double adminShellBreakpoint = 980;
  static const double adminContentMaxWidth = 1480;
  static const double adminControlPanelWidth = 430;
  static const double adminGap = 16;
  static const double cardRadius = 16;
  static const double pillMaxWidth = 280;
  static const double compactBreakpoint = 720;
  static const double narrowRowBreakpoint = 360;
  static const Color border = Color(0xFFE2E8F0);
  static const Color pageBackground = Color(0xFFF8FAFC);
  static const Color primary = Color(0xFF0F4C81);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);

  const PwfGlobalLayoutContract._();
}

/// Root app boundary. Keeps text scaling deterministic and gives every page a
/// bounded material/RTL baseline without introducing an outer scroll view that
/// would create unbounded-height failures.
class PwfGlobalAppBoundary extends StatelessWidget {
  const PwfGlobalAppBoundary({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: const TextScaler.linear(1.0)),
        child: child,
      ),
    );
  }
}

/// Admin route boundary. The shell already provides finite height via Expanded;
/// this boundary guarantees the route body receives a finite box and clips only
/// paint overflow, not layout. Pages must still use local scroll owners.
class PwfAdminRouteBoundary extends StatelessWidget {
  const PwfAdminRouteBoundary({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width =
            constraints.hasBoundedWidth && constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final height =
            constraints.hasBoundedHeight && constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : MediaQuery.sizeOf(context).height;
        return ColoredBox(
          color: PwfGlobalLayoutContract.pageBackground,
          child: SizedBox(
            width: width,
            height: height,
            child: ClipRect(child: child),
          ),
        );
      },
    );
  }
}

/// Public route boundary. It does not create a global scroll owner; it only
/// provides finite-width/finite-height baseline and lets public pages own their
/// sections. This is used to align public pages with the same anti-overflow
/// contract as admin/system routes.
class PwfPublicRouteBoundary extends StatelessWidget {
  const PwfPublicRouteBoundary({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width =
            constraints.hasBoundedWidth && constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        return SizedBox(width: width, child: child);
      },
    );
  }
}

/// System route boundary. Each semi-independent system still owns its landing
/// and internal shell, but the platform provides finite outer constraints.
class PwfSystemRouteBoundary extends StatelessWidget {
  const PwfSystemRouteBoundary({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width =
            constraints.hasBoundedWidth && constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final height =
            constraints.hasBoundedHeight && constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : MediaQuery.sizeOf(context).height;
        return SizedBox(width: width, height: height, child: child);
      },
    );
  }
}

class PwfBoundedPage extends StatelessWidget {
  const PwfBoundedPage({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.maxWidth = PwfGlobalLayoutContract.adminContentMaxWidth,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final finiteHeight =
            constraints.hasBoundedHeight && constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : MediaQuery.sizeOf(context).height;
        return SizedBox(
          height: finiteHeight,
          child: SingleChildScrollView(
            padding: padding,
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}

class PwfResponsiveSplit extends StatelessWidget {
  const PwfResponsiveSplit({
    super.key,
    required this.control,
    required this.preview,
    this.controlWidth = PwfGlobalLayoutContract.adminControlPanelWidth,
    this.gap = PwfGlobalLayoutContract.adminGap,
    this.breakpoint = 1180,
    this.padding = const EdgeInsets.all(12),
  });

  final Widget control;
  final Widget preview;
  final double controlWidth;
  final double gap;
  final double breakpoint;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width =
            constraints.hasBoundedWidth && constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final height =
            constraints.hasBoundedHeight && constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : MediaQuery.sizeOf(context).height;
        final isWide = width >= breakpoint;
        if (!isWide) {
          return SizedBox(
            height: height,
            child: ListView(
              padding: padding,
              children: [
                control,
                SizedBox(height: gap),
                preview,
              ],
            ),
          );
        }
        final resolvedControlWidth = controlWidth
            .clamp(320.0, width * .42)
            .toDouble();
        final previewWidth = (width - resolvedControlWidth - gap - 24)
            .clamp(320.0, width)
            .toDouble();
        return SizedBox(
          height: height,
          child: SingleChildScrollView(
            padding: padding,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: resolvedControlWidth, child: control),
                SizedBox(width: gap),
                SizedBox(width: previewWidth, child: preview),
              ],
            ),
          ),
        );
      },
    );
  }
}

class PwfSurfaceCard extends StatelessWidget {
  const PwfSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(PwfGlobalLayoutContract.cardRadius),
        border: Border.all(color: PwfGlobalLayoutContract.border),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class PwfSafeText extends StatelessWidget {
  const PwfSafeText(
    this.text, {
    super.key,
    this.style,
    this.maxLines = 1,
    this.textAlign,
    this.softWrap = false,
  });

  final String text;
  final TextStyle? style;
  final int maxLines;
  final TextAlign? textAlign;
  final bool softWrap;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      softWrap: softWrap,
      textAlign: textAlign,
      style: style,
    );
  }
}

class PwfSafePill extends StatelessWidget {
  const PwfSafePill({
    super.key,
    required this.label,
    this.icon,
    this.maxWidth = PwfGlobalLayoutContract.pillMaxWidth,
    this.color = Colors.white,
    this.foreground = PwfGlobalLayoutContract.textSecondary,
    this.borderColor = PwfGlobalLayoutContract.border,
  });

  final String label;
  final IconData? icon;
  final double maxWidth;
  final Color color;
  final Color foreground;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth, minWidth: 0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: borderColor),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: foreground),
                const SizedBox(width: 6),
              ],
              Flexible(
                fit: FlexFit.loose,
                child: PwfSafeText(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: foreground,
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

class PwfSafeActionRow extends StatelessWidget {
  const PwfSafeActionRow({
    super.key,
    required this.children,
    this.spacing = 8,
    this.runSpacing = 8,
  });

  final List<Widget> children;
  final double spacing;
  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: children,
    );
  }
}

/// A bounded wrap row for labels, buttons, filters, and status chips. It is the
/// preferred replacement for long Row chains on all route surfaces.
class PwfSafeWrapRow extends StatelessWidget {
  const PwfSafeWrapRow({
    super.key,
    required this.children,
    this.spacing = 8,
    this.runSpacing = 8,
    this.alignment = WrapAlignment.start,
  });

  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final WrapAlignment alignment;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: alignment,
      spacing: spacing,
      runSpacing: runSpacing,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: children,
    );
  }
}

/// Safe reusable stat tile for public/admin dashboards. It deliberately avoids
/// Expanded/Flexible inside grid cells and uses finite minimum height so compact
/// viewports never squeeze the internal column into an impossible box.
class PwfSafeStatTile extends StatelessWidget {
  const PwfSafeStatTile({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.accent = PwfGlobalLayoutContract.primary,
    this.background = Colors.white,
    this.minHeight = 150,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color accent;
  final Color background;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight, minWidth: 148),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(
            PwfGlobalLayoutContract.cardRadius,
          ),
          border: Border.all(color: PwfGlobalLayoutContract.border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 28, color: accent),
              const SizedBox(height: 10),
              PwfSafeText(
                value,
                textAlign: TextAlign.center,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  color: accent,
                ),
              ),
              const SizedBox(height: 8),
              PwfSafeText(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: PwfGlobalLayoutContract.textSecondary,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PwfSafeDropdownItem extends StatelessWidget {
  const PwfSafeDropdownItem({
    super.key,
    required this.label,
    this.subtitle,
    this.icon,
    this.maxWidth = 360,
  });

  final String label;
  final String? subtitle;
  final IconData? icon;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: PwfGlobalLayoutContract.primary),
            const SizedBox(width: 8),
          ],
          Flexible(
            fit: FlexFit.loose,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PwfSafeText(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                if (subtitle != null && subtitle!.trim().isNotEmpty)
                  PwfSafeText(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: PwfGlobalLayoutContract.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PwfCompactAware extends StatelessWidget {
  const PwfCompactAware({
    super.key,
    required this.compactBuilder,
    required this.regularBuilder,
    this.breakpoint = PwfGlobalLayoutContract.narrowRowBreakpoint,
  });

  final WidgetBuilder compactBuilder;
  final WidgetBuilder regularBuilder;
  final double breakpoint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width =
            constraints.hasBoundedWidth && constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        return width < breakpoint
            ? compactBuilder(context)
            : regularBuilder(context);
      },
    );
  }
}

/// Debug-only marker for route UAT. This does not suppress layout exceptions;
/// it preserves fail-fast behavior while making the current batch discoverable
/// in source review and static grep.
class PwfGlobalLayoutCertificationMarker {
  static const batch = 'Platform Development 10L';
  static const decision =
      'full_route_inventory_all_pages_layout_contract_migration';
  static const productionApproved = false;
  static const noAuthUsersMigration = true;
  static const noFlutterElevatedSecret = true;
  static const noWaqfAssetsMutation = true;

  const PwfGlobalLayoutCertificationMarker._();

  static void debugMark(String route) {
    if (kDebugMode) {
      debugPrint('PWF_LAYOUT_10L route=$route decision=$decision');
    }
  }
}

class PwfFullRouteInventoryCertification10L {
  static const batch = 'Platform Development 10L';
  static const fullRouteInventoryPrepared = true;
  static const allPagesLayoutContractMigrationStarted = true;
  static const legacyFlexPatternEliminationStarted = true;
  static const routeConsoleUatRequired = true;
  static const productionApproved = false;

  const PwfFullRouteInventoryCertification10L._();
}

class PwfReportsScreenFlexMigration10L1 {
  static const batch = 'Platform Development 10L-1';
  static const reportsScreenFlexMigrated = true;
  static const noExpandedInsideUnboundedVerticalFlex = true;
  static const analyzerRetestRequired = true;
  static const browserConsoleRetestRequired = true;
  static const productionApproved = false;

  const PwfReportsScreenFlexMigration10L1._();
}
