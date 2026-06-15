import 'package:flutter/material.dart';

import 'pwf_web_container.dart';
import 'shared/pwf_home_visual_contract.dart';

/// Unified section wrapper to match the HTML `.container` + section spacing.
///
/// Platform 12 visual contract:
/// - One sovereign max-width and horizontal rhythm for all public home sections.
/// - One section background policy instead of per-widget scattered surfaces.
/// - Responsive vertical density so DevTools/constrained widths do not trigger
///   visual crowding or section drift.
class PwfSectionContainer extends StatelessWidget {
  const PwfSectionContainer({
    super.key,
    required this.child,
    this.sectionKey,
    this.verticalPadding,
    this.maxWidth = PwfHomeVisualContract.maxContentWidth,
    this.backgroundColor,
  });

  final Widget child;
  final String? sectionKey;

  /// Optional override per section (rare).
  final double? verticalPadding;

  /// Unified max width used by internal/public pages and section rendering.
  final double maxWidth;

  /// Optional visual override. Most sections should use the central contract.
  final Color? backgroundColor;

  double _hPadding(double w) {
    if (w >= 1280) return 20; // HTML container padding
    if (w >= 768) return 20;
    return 16;
  }

  bool _isPublicSubpageSection(String? key) {
    if (key == null) return false;
    return key.contains('WebScreen') ||
        key.contains('FrontendHubPage') ||
        key.contains('PwfPublic') ||
        key.contains('PwfStatic') ||
        key.contains('PwfContent') ||
        key.contains('PwfInternalIntro');
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final vPad = verticalPadding ??
        (_isPublicSubpageSection(sectionKey)
            ? PwfHomeVisualContract.publicSubpageVerticalPadding(context)
            : PwfHomeVisualContract.sectionVerticalPadding(context));
    final bg = backgroundColor ??
        PwfHomeVisualContract.sectionBackground(sectionKey);

    return Semantics(
      container: true,
      label: sectionKey,
      child: ColoredBox(
        color: bg,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: vPad),
          child: PwfWebContainer(
            maxWidth: maxWidth,
            padding: EdgeInsets.symmetric(horizontal: _hPadding(w)),
            child: child,
          ),
        ),
      ),
    );
  }
}
