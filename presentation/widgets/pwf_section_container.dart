import 'package:flutter/material.dart';

import 'pwf_web_container.dart';

/// Unified section wrapper to match the HTML `.container` + section spacing.
class PwfSectionContainer extends StatelessWidget {
  const PwfSectionContainer({
    super.key,
    required this.child,
    this.sectionKey,
    this.verticalPadding,
  });

  final Widget child;
  final String? sectionKey;

  /// Optional override per section (rare).
  final double? verticalPadding;

  double _hPadding(double w) {
    if (w >= 1280) return 20; // HTML container padding
    if (w >= 768) return 20;
    return 16;
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final vPad = verticalPadding ?? 55; // matches the HTML rhythm

    return Semantics(
      container: true,
      label: sectionKey,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: vPad),
        child: PwfWebContainer(
          maxWidth: 1400,
          padding: EdgeInsets.symmetric(horizontal: _hPadding(w)),
          child: child,
        ),
      ),
    );
  }
}
