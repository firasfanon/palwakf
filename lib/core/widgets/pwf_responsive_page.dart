import 'package:flutter/material.dart';

import '../theme/palwakf_sis_breakpoints.dart';

class PwfResponsivePage extends StatelessWidget {
  const PwfResponsivePage({
    super.key,
    required this.sliver,
    this.maxWidth = 1480,
    this.backgroundColor,
  });

  final Widget sliver;
  final double maxWidth;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final device = PalWakfSisBreakpoints.of(context);
    final padding = switch (device) {
      PalWakfSisDeviceClass.mobile => 16.0,
      PalWakfSisDeviceClass.tablet => 24.0,
      PalWakfSisDeviceClass.laptop => 32.0,
      PalWakfSisDeviceClass.desktop => 40.0,
    };

    return ColoredBox(
      color: backgroundColor ?? const Color(0xFFF7F9FC),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.all(padding),
                sliver: sliver,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PwfResponsiveGrid extends StatelessWidget {
  const PwfResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.spacing = 16,
  });

  final List<Widget> children;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final device = PalWakfSisBreakpoints.of(context);
    final columns = switch (device) {
      PalWakfSisDeviceClass.mobile => mobileColumns,
      PalWakfSisDeviceClass.tablet => tabletColumns,
      PalWakfSisDeviceClass.laptop => desktopColumns,
      PalWakfSisDeviceClass.desktop => desktopColumns,
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalSpacing = spacing * (columns - 1);
        final itemWidth = (constraints.maxWidth - totalSpacing) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final child in children)
              SizedBox(width: itemWidth.clamp(0, constraints.maxWidth), child: child),
          ],
        );
      },
    );
  }
}
