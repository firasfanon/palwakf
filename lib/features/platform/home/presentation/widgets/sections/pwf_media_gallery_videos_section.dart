import 'package:flutter/material.dart';

import 'pwf_media_gallery_section.dart';

/// Home section: media gallery (videos).
class PwfMediaGalleryVideos extends StatelessWidget {
  const PwfMediaGalleryVideos({
    super.key,
    required this.unitSlug,
    this.sectionSettings,
  });

  final String unitSlug;
  final Map<String, dynamic>? sectionSettings;

  @override
  Widget build(BuildContext context) {
    return PwfMediaGallerySection(
      unitSlug: unitSlug,
      initialTab: 1,
      sectionSettings: sectionSettings,
    );
  }
}
