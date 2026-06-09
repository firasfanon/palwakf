import 'package:flutter/material.dart';

import '../pwf_important_links_section.dart';

/// Home section: quick links grid.
///
/// Currently backed by the existing [PwfImportantLinksSection] UI.
class PwfQuickLinksGrid extends StatelessWidget {
  const PwfQuickLinksGrid({super.key, this.unitSlug = 'home'});

  final String unitSlug;

  @override
  Widget build(BuildContext context) {
    // NOTE: unitSlug is reserved for future per-unit quick links.
    return const PwfImportantLinksSection();
  }
}
