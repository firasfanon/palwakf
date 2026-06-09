import 'package:flutter/material.dart';

import 'pwf_media_gallery_section.dart';

/// Home section: media gallery (images).
class PwfMediaGalleryImages extends StatelessWidget {
  const PwfMediaGalleryImages({super.key, required this.unitSlug});

  final String unitSlug;

  @override
  Widget build(BuildContext context) {
    return PwfMediaGallerySection(unitSlug: unitSlug, initialTab: 0);
  }
}
