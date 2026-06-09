import 'package:flutter/material.dart';

import 'pwf_news_section.dart';

/// Home section: news tabs.
///
/// For now we render the existing [PwfNewsSection] (single tab). This keeps
/// contracts stable while we iterate on a full tabbed UI.
class PwfNewsTabs extends StatelessWidget {
  const PwfNewsTabs({super.key, required this.unitSlug});

  final String unitSlug;

  @override
  Widget build(BuildContext context) {
    return PwfNewsSection(unitSlug: unitSlug);
  }
}
