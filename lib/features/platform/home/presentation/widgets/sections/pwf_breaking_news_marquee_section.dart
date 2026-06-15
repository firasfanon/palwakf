import 'package:flutter/material.dart';

import 'package:waqf/presentation/widgets/home/breaking_news_slider.dart';

/// Home section: breaking news marquee.
///
/// The breaking-news bar is a sovereign alert strip. It intentionally follows
/// the hero width rather than the generic section card width so urgent alerts
/// feel connected to the first fold and do not look like a detached card.
class PwfBreakingNewsMarquee extends StatelessWidget {
  const PwfBreakingNewsMarquee({
    super.key,
    required this.unitSlug,
    this.sectionSettings,
  });

  final String unitSlug;
  final Map<String, dynamic>? sectionSettings;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'PwfBreakingNewsMarquee',
      child: SizedBox(
        width: double.infinity,
        child: BreakingNewsSlider(
          unitSlug: unitSlug,
          forceEnabled: true,
          showEmptyState: true,
        ),
      ),
    );
  }
}
