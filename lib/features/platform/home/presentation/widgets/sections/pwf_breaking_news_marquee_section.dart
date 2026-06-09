import 'package:flutter/material.dart';

import 'package:waqf/presentation/widgets/home/breaking_news_slider.dart';

/// Home section: breaking news marquee.
///
/// This is a thin wrapper around the shared [BreakingNewsSlider] widget so it
/// can be mounted via the dynamic homepage sections renderer.
class PwfBreakingNewsMarquee extends StatelessWidget {
  const PwfBreakingNewsMarquee({super.key, required this.unitSlug});

  final String unitSlug;

  @override
  Widget build(BuildContext context) {
    return BreakingNewsSlider(unitSlug: unitSlug);
  }
}
