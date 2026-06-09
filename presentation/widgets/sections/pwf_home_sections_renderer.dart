import 'package:waqf/features/platform/home/presentation/sections/pwf_home_sections_catalog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../../data/models/homepage_section.dart';

// Default section builders (runtime): kept here so the home screen can render
// immediately even if the caller doesn't inject a builders map.
import '../header/pwf_main_nav.dart';
import '../header/pwf_top_bar.dart';

import '../pwf_important_links_section.dart';

import 'pwf_activities_section.dart';
import 'pwf_announcements_section.dart';
import 'pwf_breaking_news_marquee_section.dart';
import 'pwf_eservices_portal_section.dart';
import 'pwf_feature_highlights_section.dart';
import 'pwf_footer_section.dart';
import 'pwf_friday_sermons_section.dart';
import 'pwf_hero_slider_section.dart';
import 'pwf_media_gallery_images_section.dart';
import 'pwf_media_gallery_section.dart';
import 'pwf_media_gallery_videos_section.dart';
import 'pwf_minister_word_section.dart';
import 'pwf_mini_map_teaser_section.dart';
import 'pwf_news_section.dart';
import 'pwf_news_tabs_section.dart';
import 'pwf_prayer_times_section.dart';
import 'pwf_quick_links_grid_section.dart';
import 'pwf_quick_services_section.dart';
import 'pwf_stats_section.dart';

/// Dynamically renders homepage sections based on rows in `public.homepage_sections`.
///
/// قواعد إلزامية:
/// - DB هو المرجع الوحيد (is_active + display_order).
/// - لا يتم إضافة أي أقسام افتراضية أو placeholders تلقائيًا.
/// - pinned (top bar / main nav / footer) يمكن منعها من الرسم داخل renderer.
class PwfHomeSectionsRenderer extends StatelessWidget {
  const PwfHomeSectionsRenderer({
    super.key,
    required this.unitSlug,
    this.sections,
    this.builders,
    this.renderPinnedHeaderSections = true,
    this.renderPinnedFooterSections = true,
  });

  final String unitSlug;

  /// If false, the renderer will NOT render pinned header sections
  /// (e.g. `pwf_top_bar`, `pwf_main_nav`). These are expected to be rendered
  /// by PwfHeader.
  final bool renderPinnedHeaderSections;

  /// If false, the renderer will NOT render pinned footer sections
  /// (e.g. `pwf_footer`). These are expected to be rendered by the parent.
  final bool renderPinnedFooterSections;

  /// Sections meta from DB (or draft override from admin).
  final List<HomepageSection>? sections;

  /// Optional mapping from `section_name` -> builder.
  final Map<String, Widget Function(BuildContext context, String unitSlug)>?
  builders;

  /// Built-in defaults used when [builders] is not provided.
  static final Map<
    String,
    Widget Function(BuildContext context, String unitSlug)
  >
  kDefaultBuilders = {
    // pinned (normally rendered outside)
    'pwf_top_bar': (context, unitSlug) => const PwfTopBar(),
    'pwf_main_nav': (context, unitSlug) => const PwfMainNav(),

    // content
    'pwf_hero_slider': (context, unitSlug) =>
        PwfHeroSliderSection(unitSlug: unitSlug),
    'pwf_breaking_news_marquee': (context, unitSlug) =>
        PwfBreakingNewsMarquee(unitSlug: unitSlug),
    'pwf_quick_links_grid': (context, unitSlug) =>
        PwfQuickLinksGrid(unitSlug: unitSlug),
    'pwf_quick_services': (context, unitSlug) =>
        PwfQuickServicesSection(unitSlug: unitSlug),
    'pwf_eservices_portal': (context, unitSlug) =>
        PwfEServicesPortalSection(unitSlug: unitSlug),
    'pwf_stats_grid': (context, unitSlug) =>
        PwfStatsSection(unitSlug: unitSlug),
    'pwf_announcements': (context, unitSlug) =>
        PwfAnnouncementsSection(unitSlug: unitSlug),
    'pwf_minister_word': (context, unitSlug) =>
        PwfMinisterWordSection(unitSlug: unitSlug),
    'pwf_prayer_times': (context, unitSlug) =>
        PwfPrayerTimesSection(unitSlug: unitSlug),
    // Note: PwfImportantLinksSection in the platform has a constructor that
    // accepts only `key` (no unitSlug). Keep the builder compatible.
    'pwf_important_links': (context, unitSlug) =>
        const PwfImportantLinksSection(),
    'pwf_news_tabs': (context, unitSlug) => PwfNewsTabs(unitSlug: unitSlug),
    'pwf_news': (context, unitSlug) => PwfNewsSection(unitSlug: unitSlug),

    // gallery (choose one strategy in DB)
    'pwf_media_gallery': (context, unitSlug) =>
        PwfMediaGallerySection(unitSlug: unitSlug),
    'pwf_media_gallery_images': (context, unitSlug) =>
        PwfMediaGalleryImages(unitSlug: unitSlug),
    'pwf_media_gallery_videos': (context, unitSlug) =>
        PwfMediaGalleryVideos(unitSlug: unitSlug),

    'pwf_activities': (context, unitSlug) =>
        PwfActivitiesSection(unitSlug: unitSlug),
    'pwf_friday_sermons': (context, unitSlug) =>
        PwfFridaySermonsSection(unitSlug: unitSlug),

    'pwf_feature_highlights': (context, unitSlug) =>
        PwfFeatureHighlights(unitSlug: unitSlug),
    'pwf_mini_map_teaser': (context, unitSlug) =>
        PwfMiniMapTeaser(unitSlug: unitSlug),

    'pwf_footer': (context, unitSlug) => PwfFooterSection(unitSlug: unitSlug),
  };

  @override
  Widget build(BuildContext context) {
    final ordered = _normalize(sections);
    if (ordered.isEmpty) return const SizedBox.shrink();

    final seen = <String>{};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final s in ordered)
          if (s.isActive) ..._renderOne(context, s, seen),
      ],
    );
  }

  List<Widget> _renderOne(
    BuildContext context,
    HomepageSection s,
    Set<String> seen,
  ) {
    final raw = s.sectionName;
    final key = _canonicalKey(raw);

    if (!_shouldRenderSection(key)) return const <Widget>[];

    // Deduplicate: if multiple rows exist (e.g., multiple unit_id results
    // returned by an "all sections" provider), render each key once.
    if (!seen.add(key)) return const <Widget>[];

    final child = _buildSection(context, key);

    // KeyedSubtree helps stabilize element identity across rebuilds.
    return <Widget>[
      KeyedSubtree(
        key: ValueKey('home_sec_${unitSlug}_$key'),
        child: RepaintBoundary(child: child),
      ),
    ];
  }

  bool _shouldRenderSection(String key) {
    final isHeaderPinned = key == 'pwf_top_bar' || key == 'pwf_main_nav';
    final isFooterPinned = key == 'pwf_footer';

    if (!renderPinnedHeaderSections && isHeaderPinned) return false;
    if (!renderPinnedFooterSections && isFooterPinned) return false;

    // Always ignore legacy pinned keys inside renderer.
    if (key == 'top_bar' || key == 'main_nav' || key == 'footer') return false;

    return true;
  }

  List<HomepageSection> _normalize(List<HomepageSection>? input) {
    final list = (input ?? const <HomepageSection>[]).toList(growable: false);
    if (list.isEmpty) return const <HomepageSection>[];

    // DB is the single source of truth: order by numeric display_order.
    final sorted = [...list];
    sorted.sort((a, b) {
      final ao = a.displayOrder;
      final bo = b.displayOrder;
      final aOrder = ao == 0 ? 999999 : ao;
      final bOrder = bo == 0 ? 999999 : bo;
      final c = aOrder.compareTo(bOrder);
      if (c != 0) return c;
      return a.sectionName.compareTo(b.sectionName);
    });
    return sorted;
  }

  Widget _buildSection(BuildContext context, String key) {
    final effectiveBuilders = builders ?? kDefaultBuilders;
    final b = effectiveBuilders[key];
    if (b != null) return b(context, unitSlug);

    assert(() {
      debugPrint(
        'PwfHomeSectionsRenderer: missing builder for "$key" (unit=$unitSlug)',
      );
      return true;
    }());

    // Runtime: no placeholders.
    return const SizedBox.shrink();
  }

  /// Canonicalize keys so legacy names can't cause duplicates.
  ///
  /// NOTE: Do NOT merge distinct PWF keys here (e.g., keep pwf_news and
  /// pwf_news_tabs distinct) — merging would hide sections.
  String _canonicalKey(String raw) {
    final n = _normalizeKey(raw);

    // Legacy -> PWF mapping
    switch (n) {
      case 'minister':
        return 'pwf_minister_word';
      case 'statistics':
        return 'pwf_stats_grid';
      case 'breaking_news':
        return 'pwf_breaking_news_marquee';
      case 'announcements':
        return 'pwf_announcements';
      case 'services':
        return 'pwf_quick_services';
      case 'news':
        return 'pwf_news_tabs';
      case 'top_bar':
      case 'pwf_topbar':
      case 'pwf_top_bar':
        return 'pwf_top_bar';
      case 'main_nav':
      case 'pwf_mainnav':
      case 'pwf_main_nav':
        return 'pwf_main_nav';
      case 'footer':
      case 'pwf_footer':
        return 'pwf_footer';
      default:
        return n;
    }
  }

  String _normalizeKey(String raw) {
    final lower = raw.trim().toLowerCase();
    final a = lower.replaceAll(RegExp(r'[^a-z0-9]+'), '_');
    return a.replaceAll(RegExp(r'_+'), '_');
  }
}
