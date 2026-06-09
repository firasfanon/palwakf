import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../data/models/media_gallery_item.dart';
import '../../../widgets/home/activities_section.dart';
import '../../../widgets/home/announcements_section.dart';
import '../../../widgets/home/breaking_news_slider.dart';
import '../../../widgets/home/hero_slider.dart';
import '../../../widgets/home/media_gallery_section.dart';
import '../../../widgets/home/minister_word_section.dart';
import '../../../widgets/home/news_section.dart';
import '../../../widgets/home/services_section.dart';
import '../../../widgets/home/stats_section.dart';
import '../../../widgets/web/web_app_bar.dart';
import '../../../widgets/web/web_container.dart';
import '../../../widgets/web/web_footer.dart';

/// Web-optimized Home/Unit Dashboard
///
/// Same sections as mobile dashboard:
/// Hero, Breaking, Stats, News, Announcements, Activities, Galleries.
class WebHomeScreen extends ConsumerWidget {
  final String unitSlug;
  final String? unitTitle;

  const WebHomeScreen({super.key, this.unitSlug = 'home', this.unitTitle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = (unitTitle ?? '').trim();

    return Scaffold(
      appBar: const WebAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            HeroSlider(unitSlug: unitSlug),
            BreakingNewsSlider(unitSlug: unitSlug),
            const SizedBox(height: 12),
            WebContainer(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (unitSlug != 'home' && title.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        title,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppConstants.islamicGreen,
                            ),
                      ),
                      const SizedBox(height: 8),
                    ],

                    const SizedBox(height: 8),
                    if (unitSlug == 'home')
                      const MinisterWordSection(maxLines: 4),
                    const StatsSection(),

                    NewsSection(unitSlug: unitSlug),
                    AnnouncementsSection(unitSlug: unitSlug),
                    MediaGallerySection(
                      title: 'معرض الصور',
                      unitSlug: unitSlug,
                      mediaType: MediaType.photo,
                      previewLimit: 10,
                    ),
                    MediaGallerySection(
                      title: 'معرض الفيديو',
                      unitSlug: unitSlug,
                      mediaType: MediaType.video,
                      previewLimit: 10,
                    ),
                    ActivitiesSection(unitSlug: unitSlug),

                    // Optional: keep services section for the public site
                    const SizedBox(height: 8),
                    const ServicesSection(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            const WebFooter(),
          ],
        ),
      ),
    );
  }
}
