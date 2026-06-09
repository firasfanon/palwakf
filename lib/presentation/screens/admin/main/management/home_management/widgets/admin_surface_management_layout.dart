import 'package:flutter/material.dart';

/// Unified visual shell for public-surface management workspaces.
///
/// The contract is intentionally Flutter-only: it standardizes the admin
/// workspace layout without changing SQL, RBAC, routes, or runtime ownership.
class PwfAdminSurfaceLayoutTokens {
  static const double gap = 16;
  static const double radius = 16;
  static const double controlPanelWidth = 430;
  static const double wideBreakpoint = 1180;
  static const double previewHeight = 860;
  static const EdgeInsets pagePadding = EdgeInsets.all(12);
  static const EdgeInsets cardPadding = EdgeInsets.all(16);
  static const Color previewBackground = Color(0xFFF8FAFC);
  static const Color bodyText = Color(0xFF475569);

  const PwfAdminSurfaceLayoutTokens._();
}

class PwfAdminSurfaceSplit extends StatelessWidget {
  const PwfAdminSurfaceSplit({
    super.key,
    required this.controlPanel,
    required this.previewPanel,
    this.controlWidth = PwfAdminSurfaceLayoutTokens.controlPanelWidth,
    this.gap = PwfAdminSurfaceLayoutTokens.gap,
  });

  final Widget controlPanel;
  final Widget previewPanel;
  final double controlWidth;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width =
            constraints.hasBoundedWidth && constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final isWide = width >= PwfAdminSurfaceLayoutTokens.wideBreakpoint;

        if (!isWide) {
          return ListView(
            padding: PwfAdminSurfaceLayoutTokens.pagePadding,
            children: [
              controlPanel,
              SizedBox(height: gap),
              previewPanel,
            ],
          );
        }

        return SingleChildScrollView(
          padding: PwfAdminSurfaceLayoutTokens.pagePadding,
          child: SizedBox(
            width: width,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: controlWidth, child: controlPanel),
                SizedBox(width: gap),
                Expanded(child: previewPanel),
              ],
            ),
          ),
        );
      },
    );
  }
}

class PwfAdminSurfaceCard extends StatelessWidget {
  const PwfAdminSurfaceCard({
    super.key,
    required this.child,
    this.padding = PwfAdminSurfaceLayoutTokens.cardPadding,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(PwfAdminSurfaceLayoutTokens.radius),
        border: Border.all(color: Colors.black12),
      ),
      padding: padding,
      child: child,
    );
  }
}

class PwfAdminSurfaceHeader extends StatelessWidget {
  const PwfAdminSurfaceHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.badge,
    this.icon,
  });

  final String title;
  final String subtitle;
  final String? badge;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF0B3A70).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFF0B3A70)),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  height: 1.55,
                  color: PwfAdminSurfaceLayoutTokens.bodyText,
                ),
              ),
            ],
          ),
        ),
        if (badge != null) ...[
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF0B3A70).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              badge!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Color(0xFF0B3A70),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class PwfAdminSurfacePreviewFrame extends StatelessWidget {
  const PwfAdminSurfacePreviewFrame({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.badge,
    this.isLoading = false,
    this.height = PwfAdminSurfaceLayoutTokens.previewHeight,
    this.dirty = false,
  });

  final String title;
  final String subtitle;
  final String? badge;
  final Widget child;
  final bool isLoading;
  final bool dirty;
  final double height;

  @override
  Widget build(BuildContext context) {
    return PwfAdminSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: PwfAdminSurfaceHeader(
                  title: title,
                  subtitle: subtitle,
                  badge: badge,
                  icon: Icons.visibility_rounded,
                ),
              ),
              if (dirty) ...[const SizedBox(width: 10), const _DirtyPill()],
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: height,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  color: PwfAdminSurfaceLayoutTokens.previewBackground,
                ),
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: child,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DirtyPill extends StatelessWidget {
  const _DirtyPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 10, color: Colors.orange),
          SizedBox(width: 6),
          Text(
            'غير محفوظ',
            style: TextStyle(
              color: Colors.orange,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
