import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/homepage_section.dart';

class HomepageRepository {
  final SupabaseClient _client;

  HomepageRepository(this._client);

  // ============================================
  // TABLE NAMES
  // ============================================

  /// Public sections table name.
  // Phase 1 public-schema remediation. Runtime reads go through public
  // compatibility wrappers. Mutating admin operations keep using preserved
  // legacy public tables until owner-write RPCs are explicitly approved.
  static const String _sectionsReadSurface =
      'v_platform_homepage_sections_compat_v1';
  static const String _sectionsLegacyWriteTable = 'homepage_sections';
  static const String sectionsTable = _sectionsLegacyWriteTable;
  static const String _siteSettingsReadSurface =
      'v_platform_site_settings_compat_v1';
  static const String _siteSettingsLegacyWriteTable = 'site_settings';
  static const String _heroSlidesReadSurface =
      'v_platform_hero_slides_compat_v1';
  static const String _heroSlidesLegacyWriteTable = 'hero_slides';
  static const String _breakingNewsReadSurface =
      'v_platform_breaking_news_compat_v1';
  static const String _breakingNewsLegacyWriteTable = 'breaking_news';

  // ============================================
  // SITE SETTINGS (Single Row)
  // ============================================

  Future<SiteSettings?> fetchSiteSettings() async {
    try {
      final row = await _client
          .from(_siteSettingsReadSurface)
          .select()
          .limit(1)
          .maybeSingle();

      if (row == null) return null;
      return SiteSettings.fromJson(row);
    } catch (e) {
      log('Error fetching site settings: $e');
      return null;
    }
  }

  Future<bool> updateSiteSettings(SiteSettings settings) async {
    try {
      final userId = _client.auth.currentUser?.id;
      await _client
          .from(_siteSettingsLegacyWriteTable)
          .update({
            'logo_url': settings.logoUrl,
            'favicon_url': settings.faviconUrl,
            'site_title': settings.siteTitle,
            'site_subtitle': settings.siteSubtitle,
            'contact_email': settings.contactEmail,
            'contact_phone': settings.contactPhone,
            'contact_address': settings.contactAddress,
            'facebook_url': settings.facebookUrl,
            'twitter_url': settings.twitterUrl,
            'instagram_url': settings.instagramUrl,
            'youtube_url': settings.youtubeUrl,
            'footer_text': settings.footerText,
            'slider_autoplay': settings.sliderAutoplay,
            'slider_speed': settings.sliderSpeed,
            'slider_show_dots': settings.sliderShowDots,
            'slider_show_arrows': settings.sliderShowArrows,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
            'updated_by': userId,
          })
          .eq('id', settings.id);

      log('Site settings updated successfully');
      return true;
    } catch (e) {
      log('Error updating site settings: $e');
      return false;
    }
  }

  // ============================================
  // HERO SLIDES (Multiple Rows)
  // ============================================

  Future<List<HeroSlide>> fetchActiveHeroSlides() async {
    try {
      final rows = await _client
          .from(_heroSlidesReadSurface)
          .select()
          .eq('is_active', true)
          .order('display_order', ascending: true);

      // Fail-open: sanitize nullable DB columns to avoid runtime crashes in strict parsers.
      final nowIso = DateTime.now().toUtc().toIso8601String();
      final out = <HeroSlide>[];
      for (final raw in (rows as List<dynamic>)) {
        final m = Map<String, dynamic>.from(raw as Map);
        m['title'] ??= '';
        m['subtitle'] ??= '';
        m['description'] ??= '';
        m['image_url'] ??= '';
        m['cta_text'] ??= '';
        m['cta_link'] ??= '';
        m['display_order'] ??= 0;
        m['is_active'] ??= true;
        m['created_at'] ??= nowIso;
        m['updated_at'] ??= nowIso;
        try {
          out.add(HeroSlide.fromJson(m));
        } catch (e) {
          log('Skipping invalid hero_slides row: $e');
        }
      }
      return out;
    } catch (e) {
      log('Error fetching active hero slides: $e');
      return [];
    }
  }

  /// Fetch active hero slides scoped to a specific unit (org_units)
  ///
  /// Fail-open: if unit scoping is not yet available (e.g., missing unit_id)
  /// or any error happens, this returns an empty list.
  Future<List<HeroSlide>> fetchActiveHeroSlidesForUnit(String unitId) async {
    try {
      final rows = await _client
          .from(_heroSlidesReadSurface)
          .select()
          .eq('is_active', true)
          .eq('unit_id', unitId)
          .order('display_order', ascending: true);

      final nowIso = DateTime.now().toUtc().toIso8601String();
      final out = <HeroSlide>[];
      for (final raw in (rows as List<dynamic>)) {
        final m = Map<String, dynamic>.from(raw as Map);
        m['title'] ??= '';
        m['subtitle'] ??= '';
        m['description'] ??= '';
        m['image_url'] ??= '';
        m['cta_text'] ??= '';
        m['cta_link'] ??= '';
        m['display_order'] ??= 0;
        m['is_active'] ??= true;
        m['created_at'] ??= nowIso;
        m['updated_at'] ??= nowIso;
        try {
          out.add(HeroSlide.fromJson(m));
        } catch (e) {
          log('Skipping invalid unit hero_slides row: $e');
        }
      }
      return out;
    } catch (e) {
      log('Error fetching unit hero slides: $e');
      return [];
    }
  }

  Future<List<HeroSlide>> fetchAllHeroSlides() async {
    try {
      final rows = await _client
          .from(_heroSlidesReadSurface)
          .select()
          .order('display_order', ascending: true);

      final nowIso = DateTime.now().toUtc().toIso8601String();
      final out = <HeroSlide>[];
      for (final raw in (rows as List<dynamic>)) {
        final m = Map<String, dynamic>.from(raw as Map);
        m['title'] ??= '';
        m['subtitle'] ??= '';
        m['description'] ??= '';
        m['image_url'] ??= '';
        m['cta_text'] ??= '';
        m['cta_link'] ??= '';
        m['display_order'] ??= 0;
        m['is_active'] ??= true;
        m['created_at'] ??= nowIso;
        m['updated_at'] ??= nowIso;
        try {
          out.add(HeroSlide.fromJson(m));
        } catch (e) {
          log('Skipping invalid hero_slides row: $e');
        }
      }
      return out;
    } catch (e) {
      log('Error fetching all hero slides: $e');
      return [];
    }
  }

  Future<HeroSlide?> fetchHeroSlide(String id) async {
    try {
      final row = await _client
          .from(_heroSlidesReadSurface)
          .select()
          .eq('id', id)
          .maybeSingle();

      if (row == null) return null;
      final nowIso = DateTime.now().toUtc().toIso8601String();
      final m = Map<String, dynamic>.from(row);
      m['title'] ??= '';
      m['subtitle'] ??= '';
      m['description'] ??= '';
      m['image_url'] ??= '';
      m['cta_text'] ??= '';
      m['cta_link'] ??= '';
      m['display_order'] ??= 0;
      m['is_active'] ??= true;
      m['created_at'] ??= nowIso;
      m['updated_at'] ??= nowIso;
      return HeroSlide.fromJson(m);
    } catch (e) {
      log('Error fetching hero slide: $e');
      return null;
    }
  }

  Future<String?> createHeroSlide(HeroSlide slide) async {
    try {
      final userId = _client.auth.currentUser?.id;
      final response = await _client
          .from(_heroSlidesLegacyWriteTable)
          .insert({
            'title': slide.title,
            'subtitle': slide.subtitle,
            'description': slide.description,
            'image_url': slide.imageUrl,
            'cta_text': slide.ctaText,
            'cta_link': slide.ctaLink,
            'display_order': slide.displayOrder,
            'is_active': slide.isActive,
            'updated_by': userId,
          })
          .select('id')
          .single();

      log('Hero slide created: ${response['id']}');
      return response['id'] as String;
    } catch (e) {
      log('Error creating hero slide: $e');
      return null;
    }
  }

  Future<bool> updateHeroSlide(HeroSlide slide) async {
    try {
      final userId = _client.auth.currentUser?.id;
      await _client
          .from(_heroSlidesLegacyWriteTable)
          .update({
            'title': slide.title,
            'subtitle': slide.subtitle,
            'description': slide.description,
            'image_url': slide.imageUrl,
            'cta_text': slide.ctaText,
            'cta_link': slide.ctaLink,
            'display_order': slide.displayOrder,
            'is_active': slide.isActive,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
            'updated_by': userId,
          })
          .eq('id', slide.id);

      log('Hero slide updated: ${slide.id}');
      return true;
    } catch (e) {
      log('Error updating hero slide: $e');
      return false;
    }
  }

  Future<bool> deleteHeroSlide(String id) async {
    try {
      await _client.from(_heroSlidesLegacyWriteTable).delete().eq('id', id);
      log('Hero slide deleted: $id');
      return true;
    } catch (e) {
      log('Error deleting hero slide: $e');
      return false;
    }
  }

  /// Shift display orders to make room for new slide
  Future<void> shiftDisplayOrders(int fromOrder) async {
    try {
      // Get all active slides with display_order >= fromOrder
      final slides = await _client
          .from(_heroSlidesReadSurface)
          .select()
          .eq('is_active', true)
          .gte('display_order', fromOrder)
          .order(
            'display_order',
            ascending: false,
          ); // Start from highest to avoid conflicts

      // Update each slide's order
      for (final slideData in slides) {
        final currentOrder = slideData['display_order'] as int;
        await _client
            .from(_heroSlidesLegacyWriteTable)
            .update({'display_order': currentOrder + 1})
            .eq('id', slideData['id']);
      }
    } catch (e) {
      throw Exception('Failed to shift display orders: $e');
    }
  }

  Future<bool> reorderHeroSlides(List<String> slideIds) async {
    try {
      for (int i = 0; i < slideIds.length; i++) {
        await _client
            .from(_heroSlidesLegacyWriteTable)
            .update({'display_order': i + 1})
            .eq('id', slideIds[i]);
      }
      log('Hero slides reordered successfully');
      return true;
    } catch (e) {
      log('Error reordering hero slides: $e');
      return false;
    }
  }

  // ============================================
  // HOMEPAGE SECTIONS (Keep existing logic)
  // ============================================

  /// Back-compat getter used by some older patches.
  String get sectionsTableName => sectionsTable;

  Future<Map<String, dynamic>?> _fetchRow(String sectionName) async {
    final row = await _client
        .from(_sectionsReadSurface)
        .select(
          'id, section_name, settings, is_active, display_order, created_at, updated_at, updated_by',
        )
        .eq('section_name', sectionName)
        .limit(1)
        .maybeSingle();

    return row;
  }

  Future<void> _upsertSection({
    required String sectionName,
    required Map<String, dynamic> settingsJson,
    bool? isActive,
    int? displayOrder,
  }) async {
    final userId = _client.auth.currentUser?.id;
    final payload = <String, dynamic>{
      'section_name': sectionName,
      'settings': settingsJson,
      if (isActive != null) 'is_active': isActive,
      if (displayOrder != null) 'display_order': displayOrder,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
      'updated_by': userId,
    };

    final res = await _client
        .from(sectionsTable)
        .upsert(payload, onConflict: 'section_name')
        .select('id')
        .maybeSingle();

    log('Upsert "$sectionName" -> ${res?['id']}');
  }

  // -------- Bulk fetch ----------

  Future<List<HomepageSection>> fetchAllSections() async {
    final rows = await _client
        .from(_sectionsReadSurface)
        .select(
          'id, section_name, settings, is_active, display_order, created_at, updated_at, updated_by, unit_id',
        )
        .order('display_order', ascending: true)
        .order('section_name', ascending: true);

    // Fail-open: DB columns like created_at/updated_at are nullable in schema.
    // Older rows (or imported data) may contain null values which would crash
    // strict JSON parsers in HomepageSection.fromJson.
    final nowIso = DateTime.now().toUtc().toIso8601String();
    final out = <HomepageSection>[];
    for (final raw in (rows as List<dynamic>)) {
      final m = Map<String, dynamic>.from(raw as Map);
      m['settings'] ??= const <String, dynamic>{};
      m['is_active'] ??= true;
      m['display_order'] ??= 0;
      m['created_at'] ??= nowIso;
      m['updated_at'] ??= nowIso;
      // updated_by may be null.
      try {
        out.add(HomepageSection.fromJson(m));
      } catch (e) {
        // Last resort: skip broken row instead of crashing the whole home page.
        // The renderer will fill missing official keys via defaults.
        log('Skipping invalid homepage_sections row: $e');
      }
    }
    return out;
  }

  Future<List<HomepageSection>> fetchAllSectionsForUnit({
    required String unitId,
    String? homeUnitId,
  }) async {
    try {
      const globalUnitId = '11111111-1111-1111-1111-111111111111';

      Future<List<HomepageSection>> fetchScoped(String? scopedUnitId) async {
        final rows = scopedUnitId == null
            ? await _client
                  .from(sectionsTable)
                  .select(
                    'id, section_name, settings, is_active, display_order, created_at, updated_at, updated_by, unit_id',
                  )
                  .isFilter('unit_id', null)
            : await _client
                  .from(sectionsTable)
                  .select(
                    'id, section_name, settings, is_active, display_order, created_at, updated_at, updated_by, unit_id',
                  )
                  .eq('unit_id', scopedUnitId);

        final nowIso = DateTime.now().toUtc().toIso8601String();
        final out = <HomepageSection>[];
        for (final raw in (rows as List<dynamic>)) {
          final m = Map<String, dynamic>.from(raw as Map);
          m['settings'] ??= const <String, dynamic>{};
          m['is_active'] ??= true;
          m['display_order'] ??= 0;
          m['created_at'] ??= nowIso;
          m['updated_at'] ??= nowIso;
          try {
            out.add(HomepageSection.fromJson(m));
          } catch (e) {
            log('Skipping invalid scoped homepage_sections row: $e');
          }
        }
        return out;
      }

      final idsToFetch = <String?>[null, globalUnitId];
      if (homeUnitId != null &&
          homeUnitId.isNotEmpty &&
          homeUnitId != globalUnitId) {
        idsToFetch.add(homeUnitId);
      }
      if (unitId.isNotEmpty && unitId != globalUnitId && unitId != homeUnitId) {
        idsToFetch.add(unitId);
      }

      final scopedResults = await Future.wait(idsToFetch.map(fetchScoped));

      String normalizeKey(String raw) => raw
          .trim()
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
          .replaceAll(RegExp(r'_+'), '_');

      final merged = <String, HomepageSection>{};
      for (final rows in scopedResults) {
        for (final row in rows) {
          merged[normalizeKey(row.sectionName)] = row;
        }
      }

      final result = merged.values.toList();
      result.sort((a, b) {
        final aOrder = a.displayOrder == 0 ? 999999 : a.displayOrder;
        final bOrder = b.displayOrder == 0 ? 999999 : b.displayOrder;
        final c = aOrder.compareTo(bOrder);
        if (c != 0) return c;
        return a.sectionName.compareTo(b.sectionName);
      });
      return result;
    } catch (e) {
      log('Error fetching unit-aware homepage sections, falling back: $e');
      return fetchAllSections();
    }
  }

  Future<void> deleteSectionsOutsideCatalog({
    required Set<String> keepSectionNames,
    String? unitId,
  }) async {
    final normalizedUnitId = unitId?.trim().isEmpty ?? true
        ? null
        : unitId!.trim();
    final rows = normalizedUnitId == null
        ? await _client
              .from(_sectionsReadSurface)
              .select('id, section_name')
              .isFilter('unit_id', null)
        : await _client
              .from(_sectionsReadSurface)
              .select('id, section_name')
              .eq('unit_id', normalizedUnitId);

    for (final raw in (rows as List<dynamic>)) {
      final row = Map<String, dynamic>.from(raw as Map);
      final id = (row['id'] ?? '').toString();
      final sectionName = (row['section_name'] ?? '').toString();
      if (id.isEmpty) continue;
      if (keepSectionNames.contains(sectionName)) continue;
      await _client.from(sectionsTable).delete().eq('id', id);
    }
  }

  /// Save homepage sections meta (order/active/settings) in one pass.
  ///
  /// Uses upsert on `section_name` (the stable unique key).
  Future<void> saveSectionsMeta(
    List<HomepageSection> sections, {
    String? unitId,
  }) async {
    // Preserve current behavior: table name is defined locally in this repo.
    // NOTE: Do NOT inline any secrets here. Supabase client is already configured.
    final userId = _client.auth.currentUser?.id;
    final now = DateTime.now().toUtc().toIso8601String();
    final normalizedUnitId = unitId?.trim().isEmpty ?? true
        ? null
        : unitId!.trim();

    for (final s in sections) {
      final payload = <String, dynamic>{
        'section_name': s.sectionName,
        'settings': s.settings,
        'is_active': s.isActive,
        'display_order': s.displayOrder,
        'updated_at': now,
        'updated_by': userId,
        'unit_id': normalizedUnitId,
      };

      final existing = normalizedUnitId == null
          ? await _client
                .from(_sectionsReadSurface)
                .select('id')
                .eq('section_name', s.sectionName)
                .isFilter('unit_id', null)
                .maybeSingle()
          : await _client
                .from(_sectionsReadSurface)
                .select('id')
                .eq('section_name', s.sectionName)
                .eq('unit_id', normalizedUnitId)
                .maybeSingle();

      final existingId = (existing?['id'] ?? '').toString();
      if (existingId.isNotEmpty) {
        await _client.from(sectionsTable).update(payload).eq('id', existingId);
      } else {
        await _client.from(sectionsTable).insert(payload);
      }
    }
  }

  // -------- Minister ----------
  Future<MinisterSectionSettings?> fetchMinisterSettings() async {
    final row = await _fetchRow('minister');
    final settings = (row?['settings'] as Map<String, dynamic>?) ?? {};
    return MinisterSectionSettings.fromJson(settings);
  }

  Future<void> updateMinisterSection(
    MinisterSectionSettings settings, {
    bool? isActive,
    int? displayOrder,
  }) {
    return _upsertSection(
      sectionName: 'minister',
      settingsJson: settings.toJson(),
      isActive: isActive,
      displayOrder: displayOrder,
    );
  }

  // -------- Statistics ----------
  Future<StatisticsSectionSettings?> fetchStatisticsSettings() async {
    final row = await _fetchRow('statistics');
    final settings = (row?['settings'] as Map<String, dynamic>?) ?? {};
    return StatisticsSectionSettings.fromJson(settings);
  }

  Future<StatisticsSectionSettings?> fetchStatisticsSettingsForUnit({
    String? unitId,
    String? homeUnitId,
  }) async {
    final rows = await fetchAllSectionsForUnit(
      unitId: unitId ?? '',
      homeUnitId: homeUnitId,
    );
    HomepageSection? selected;
    for (final section in rows) {
      final key = section.sectionName.trim().toLowerCase();
      if (key == 'pwf_stats_grid' || key == 'statistics') {
        selected = section;
        break;
      }
    }
    final settings = (selected?.settings) ?? const <String, dynamic>{};
    return StatisticsSectionSettings.fromJson(
      Map<String, dynamic>.from(settings),
    );
  }

  Future<void> updateStatisticsSection(
    StatisticsSectionSettings settings, {
    bool? isActive,
    int? displayOrder,
  }) {
    return _upsertSection(
      sectionName: 'statistics',
      settingsJson: settings.toJson(),
      isActive: isActive,
      displayOrder: displayOrder,
    );
  }

  Future<void> upsertScopedStatisticsSection(
    StatisticsSectionSettings settings, {
    String? unitId,
    bool? isActive,
    int? displayOrder,
  }) {
    return saveSectionsMeta([
      HomepageSection(
        id: '',
        sectionName: 'pwf_stats_grid',
        settings: settings.toJson(),
        isActive: isActive ?? settings.enabled,
        displayOrder: displayOrder ?? 0,
        createdAt: DateTime.now().toUtc().toIso8601String(),
        updatedAt: DateTime.now().toUtc().toIso8601String(),
        updatedBy: null,
        unitId: unitId,
      ),
    ], unitId: unitId);
  }

  // -------- News ----------
  Future<NewsSectionSettings?> fetchNewsSettings() async {
    final row = await _fetchRow('news');
    final settings = (row?['settings'] as Map<String, dynamic>?) ?? {};
    return NewsSectionSettings.fromJson(settings);
  }

  Future<void> updateNewsSection(
    NewsSectionSettings settings, {
    bool? isActive,
    int? displayOrder,
  }) {
    return _upsertSection(
      sectionName: 'news',
      settingsJson: settings.toJson(),
      isActive: isActive,
      displayOrder: displayOrder,
    );
  }

  // -------- Announcements ----------
  Future<AnnouncementsSectionSettings?> fetchAnnouncementsSettings() async {
    final row = await _fetchRow('announcements');
    final settings = (row?['settings'] as Map<String, dynamic>?) ?? {};
    return AnnouncementsSectionSettings.fromJson(settings);
  }

  Future<void> updateAnnouncementsSection(
    AnnouncementsSectionSettings settings, {
    bool? isActive,
    int? displayOrder,
  }) {
    return _upsertSection(
      sectionName: 'announcements',
      settingsJson: settings.toJson(),
      isActive: isActive,
      displayOrder: displayOrder,
    );
  }

  // ============================================
  // BREAKING NEWS (Multiple Rows)
  // ============================================

  /// Fetch active breaking news items that haven't expired
  Future<List<BreakingNewsItem>> fetchActiveBreakingNews() async {
    try {
      final now = DateTime.now().toUtc().toIso8601String();
      final rows = await _client
          .from(_breakingNewsReadSurface)
          .select()
          .eq('is_active', true)
          .or('expires_at.is.null,expires_at.gt.$now')
          .order('display_order', ascending: true);

      final out = <BreakingNewsItem>[];
      for (final raw in (rows as List<dynamic>)) {
        final m = Map<String, dynamic>.from(raw as Map);
        m['text'] ??= '';
        m['link'] ??= '';
        m['icon'] ??= '';
        m['priority'] ??= 'normal';
        m['bg_color'] ??= '';
        m['text_color'] ??= '';
        m['display_order'] ??= 0;
        m['is_active'] ??= true;
        m['created_at'] ??= now;
        m['updated_at'] ??= now;
        // expires_at can be null.
        try {
          out.add(BreakingNewsItem.fromJson(m));
        } catch (e) {
          log('Skipping invalid breaking_news row: $e');
        }
      }
      return out;
    } catch (e) {
      log('Error fetching active breaking news: $e');
      return [];
    }
  }

  /// Fetch active breaking news items scoped to a specific unit (org_units)
  ///
  /// Fail-open: if unit scoping is not yet available (e.g., missing unit_id)
  /// or any error happens, this returns an empty list.
  Future<List<BreakingNewsItem>> fetchActiveBreakingNewsForUnit(
    String unitId,
  ) async {
    try {
      final now = DateTime.now().toUtc().toIso8601String();
      final rows = await _client
          .from(_breakingNewsReadSurface)
          .select()
          .eq('unit_id', unitId)
          .eq('is_active', true)
          .or('expires_at.is.null,expires_at.gt.$now')
          .order('display_order', ascending: true);

      final out = <BreakingNewsItem>[];
      for (final raw in (rows as List<dynamic>)) {
        final m = Map<String, dynamic>.from(raw as Map);
        m['text'] ??= '';
        m['link'] ??= '';
        m['icon'] ??= '';
        m['priority'] ??= 'normal';
        m['bg_color'] ??= '';
        m['text_color'] ??= '';
        m['display_order'] ??= 0;
        m['is_active'] ??= true;
        m['created_at'] ??= now;
        m['updated_at'] ??= now;
        try {
          out.add(BreakingNewsItem.fromJson(m));
        } catch (e) {
          log('Skipping invalid unit breaking_news row: $e');
        }
      }
      return out;
    } catch (e) {
      log('Error fetching unit breaking news: $e');
      return [];
    }
  }

  /// Fetch all breaking news items (for admin)
  Future<List<BreakingNewsItem>> fetchAllBreakingNews() async {
    try {
      final rows = await _client
          .from(_breakingNewsReadSurface)
          .select()
          .order('display_order', ascending: true);

      final nowIso = DateTime.now().toUtc().toIso8601String();
      final out = <BreakingNewsItem>[];
      for (final raw in (rows as List<dynamic>)) {
        final m = Map<String, dynamic>.from(raw as Map);
        m['text'] ??= '';
        m['link'] ??= '';
        m['icon'] ??= '';
        m['priority'] ??= 'normal';
        m['bg_color'] ??= '';
        m['text_color'] ??= '';
        m['display_order'] ??= 0;
        m['is_active'] ??= true;
        m['created_at'] ??= nowIso;
        m['updated_at'] ??= nowIso;
        try {
          out.add(BreakingNewsItem.fromJson(m));
        } catch (e) {
          log('Skipping invalid breaking_news row: $e');
        }
      }
      return out;
    } catch (e) {
      log('Error fetching all breaking news: $e');
      return [];
    }
  }

  /// Fetch single breaking news item
  Future<BreakingNewsItem?> fetchBreakingNewsItem(String id) async {
    try {
      final row = await _client
          .from(_breakingNewsReadSurface)
          .select()
          .eq('id', id)
          .maybeSingle();

      if (row == null) return null;
      final nowIso = DateTime.now().toUtc().toIso8601String();
      final m = Map<String, dynamic>.from(row);
      m['text'] ??= '';
      m['link'] ??= '';
      m['icon'] ??= '';
      m['priority'] ??= 'normal';
      m['bg_color'] ??= '';
      m['text_color'] ??= '';
      m['display_order'] ??= 0;
      m['is_active'] ??= true;
      m['created_at'] ??= nowIso;
      m['updated_at'] ??= nowIso;
      return BreakingNewsItem.fromJson(m);
    } catch (e) {
      log('Error fetching breaking news item: $e');
      return null;
    }
  }

  /// Create new breaking news item
  Future<String?> createBreakingNewsItem(BreakingNewsItem item) async {
    try {
      final userId = _client.auth.currentUser?.id;
      final response = await _client
          .from(_breakingNewsLegacyWriteTable)
          .insert({
            'text': item.text,
            'link': item.link,
            'icon': item.icon,
            'priority': item.priority,
            'bg_color': item.bgColor,
            'text_color': item.textColor,
            'display_order': item.displayOrder,
            'is_active': item.isActive,
            'expires_at': item.expiresAt?.toUtc().toIso8601String(),
            'updated_by': userId,
          })
          .select('id')
          .single();

      log('Breaking news item created: ${response['id']}');
      return response['id'] as String;
    } catch (e) {
      log('Error creating breaking news item: $e');
      return null;
    }
  }

  /// Update breaking news item
  Future<bool> updateBreakingNewsItem(BreakingNewsItem item) async {
    try {
      final userId = _client.auth.currentUser?.id;
      await _client
          .from(_breakingNewsLegacyWriteTable)
          .update({
            'text': item.text,
            'link': item.link,
            'icon': item.icon,
            'priority': item.priority,
            'bg_color': item.bgColor,
            'text_color': item.textColor,
            'display_order': item.displayOrder,
            'is_active': item.isActive,
            'expires_at': item.expiresAt?.toUtc().toIso8601String(),
            'updated_at': DateTime.now().toUtc().toIso8601String(),
            'updated_by': userId,
          })
          .eq('id', item.id);

      log('Breaking news item updated: ${item.id}');
      return true;
    } catch (e) {
      log('Error updating breaking news item: $e');
      return false;
    }
  }

  /// Delete breaking news item
  Future<bool> deleteBreakingNewsItem(String id) async {
    try {
      await _client.from(_breakingNewsLegacyWriteTable).delete().eq('id', id);
      log('Breaking news item deleted: $id');
      return true;
    } catch (e) {
      log('Error deleting breaking news item: $e');
      return false;
    }
  }

  /// Reorder breaking news items
  Future<bool> reorderBreakingNews(List<String> itemIds) async {
    try {
      for (int i = 0; i < itemIds.length; i++) {
        await _client
            .from(_breakingNewsLegacyWriteTable)
            .update({'display_order': i + 1})
            .eq('id', itemIds[i]);
      }
      log('Breaking news items reordered successfully');
      return true;
    } catch (e) {
      log('Error reordering breaking news items: $e');
      return false;
    }
  }

  // -------- Breaking News Settings ----------
  Future<BreakingNewsSectionSettings?> fetchBreakingNewsSettings() async {
    final row = await _fetchRow('breaking_news');
    final settings = (row?['settings'] as Map<String, dynamic>?) ?? {};
    return BreakingNewsSectionSettings.fromJson(settings);
  }

  Future<void> updateBreakingNewsSection(
    BreakingNewsSectionSettings settings, {
    bool? isActive,
    int? displayOrder,
  }) {
    return _upsertSection(
      sectionName: 'breaking_news',
      settingsJson: settings.toJson(),
      isActive: isActive,
      displayOrder: displayOrder,
    );
  }
}

/// ============================================================================
/// Models (Restored for backward compatibility)
/// ----------------------------------------------------------------------------
/// Many parts of the codebase import `homepage_repository.dart` as a "barrel"
/// and expect these types to be available from it.
/// We keep them here to avoid touching dozens of files.
/// ============================================================================

class SiteSettings {
  final String id;

  final String logoUrl;
  final String faviconUrl;
  final String siteTitle;
  final String siteSubtitle;

  final String contactEmail;
  final String contactPhone;
  final String contactAddress;

  final String facebookUrl;
  final String twitterUrl;
  final String instagramUrl;
  final String youtubeUrl;

  final String footerText;

  final bool sliderAutoplay;
  final int sliderSpeed;
  final bool sliderShowDots;
  final bool sliderShowArrows;

  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? updatedBy;

  const SiteSettings({
    required this.id,
    this.logoUrl = '',
    this.faviconUrl = '',
    this.siteTitle = '',
    this.siteSubtitle = '',
    this.contactEmail = '',
    this.contactPhone = '',
    this.contactAddress = '',
    this.facebookUrl = '',
    this.twitterUrl = '',
    this.instagramUrl = '',
    this.youtubeUrl = '',
    this.footerText = '',
    this.sliderAutoplay = true,
    this.sliderSpeed = 5000,
    this.sliderShowDots = true,
    this.sliderShowArrows = true,
    this.createdAt,
    this.updatedAt,
    this.updatedBy,
  });

  factory SiteSettings.fromJson(Map<String, dynamic> json) {
    DateTime? _dt(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
      return null;
    }

    bool _bool(dynamic v, bool def) {
      if (v is bool) return v;
      if (v is num) return v != 0;
      if (v is String) return v.toLowerCase() == 'true';
      return def;
    }

    int _int(dynamic v, int def) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? def;
      return def;
    }

    return SiteSettings(
      id: (json['id'] ?? '').toString(),
      logoUrl: (json['logo_url'] ?? '').toString(),
      faviconUrl: (json['favicon_url'] ?? '').toString(),
      siteTitle: (json['site_title'] ?? '').toString(),
      siteSubtitle: (json['site_subtitle'] ?? '').toString(),
      contactEmail: (json['contact_email'] ?? '').toString(),
      contactPhone: (json['contact_phone'] ?? '').toString(),
      contactAddress: (json['contact_address'] ?? '').toString(),
      facebookUrl: (json['facebook_url'] ?? '').toString(),
      twitterUrl: (json['twitter_url'] ?? '').toString(),
      instagramUrl: (json['instagram_url'] ?? '').toString(),
      youtubeUrl: (json['youtube_url'] ?? '').toString(),
      footerText: (json['footer_text'] ?? '').toString(),
      sliderAutoplay: _bool(json['slider_autoplay'], true),
      sliderSpeed: _int(json['slider_speed'], 5000),
      sliderShowDots: _bool(json['slider_show_dots'], true),
      sliderShowArrows: _bool(json['slider_show_arrows'], true),
      createdAt: _dt(json['created_at']),
      updatedAt: _dt(json['updated_at']),
      updatedBy: json['updated_by']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'logo_url': logoUrl,
    'favicon_url': faviconUrl,
    'site_title': siteTitle,
    'site_subtitle': siteSubtitle,
    'contact_email': contactEmail,
    'contact_phone': contactPhone,
    'contact_address': contactAddress,
    'facebook_url': facebookUrl,
    'twitter_url': twitterUrl,
    'instagram_url': instagramUrl,
    'youtube_url': youtubeUrl,
    'footer_text': footerText,
    'slider_autoplay': sliderAutoplay,
    'slider_speed': sliderSpeed,
    'slider_show_dots': sliderShowDots,
    'slider_show_arrows': sliderShowArrows,
    if (createdAt != null) 'created_at': createdAt!.toUtc().toIso8601String(),
    if (updatedAt != null) 'updated_at': updatedAt!.toUtc().toIso8601String(),
    if (updatedBy != null) 'updated_by': updatedBy,
  };

  SiteSettings copyWith({
    String? id,
    String? logoUrl,
    String? faviconUrl,
    String? siteTitle,
    String? siteSubtitle,
    String? contactEmail,
    String? contactPhone,
    String? contactAddress,
    String? facebookUrl,
    String? twitterUrl,
    String? instagramUrl,
    String? youtubeUrl,
    String? footerText,
    bool? sliderAutoplay,
    int? sliderSpeed,
    bool? sliderShowDots,
    bool? sliderShowArrows,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? updatedBy,
  }) {
    return SiteSettings(
      id: id ?? this.id,
      logoUrl: logoUrl ?? this.logoUrl,
      faviconUrl: faviconUrl ?? this.faviconUrl,
      siteTitle: siteTitle ?? this.siteTitle,
      siteSubtitle: siteSubtitle ?? this.siteSubtitle,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      contactAddress: contactAddress ?? this.contactAddress,
      facebookUrl: facebookUrl ?? this.facebookUrl,
      twitterUrl: twitterUrl ?? this.twitterUrl,
      instagramUrl: instagramUrl ?? this.instagramUrl,
      youtubeUrl: youtubeUrl ?? this.youtubeUrl,
      footerText: footerText ?? this.footerText,
      sliderAutoplay: sliderAutoplay ?? this.sliderAutoplay,
      sliderSpeed: sliderSpeed ?? this.sliderSpeed,
      sliderShowDots: sliderShowDots ?? this.sliderShowDots,
      sliderShowArrows: sliderShowArrows ?? this.sliderShowArrows,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }
}

class HeroSlide {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String imageUrl;
  final String ctaText;
  final String ctaLink;

  final bool isActive;
  final int displayOrder;

  final String? unitId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? updatedBy;

  HeroSlide({
    this.id = '',
    this.title = '',
    this.subtitle = '',
    this.description = '',
    String? imageUrl,
    String? ctaText,
    String? ctaLink,
    this.isActive = true,
    this.displayOrder = 0,
    this.unitId,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.updatedBy,
  }) : imageUrl = imageUrl ?? '',
       ctaText = ctaText ?? '',
       ctaLink = ctaLink ?? '',
       createdAt =
           createdAt ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
       updatedAt =
           updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  factory HeroSlide.fromJson(Map<String, dynamic> json) {
    DateTime _dt(dynamic v) {
      if (v is DateTime) return v.toUtc();
      if (v is String && v.isNotEmpty)
        return (DateTime.tryParse(v) ?? DateTime.now()).toUtc();
      return DateTime.now().toUtc();
    }

    bool _bool(dynamic v, bool def) {
      if (v is bool) return v;
      if (v is num) return v != 0;
      if (v is String) return v.toLowerCase() == 'true';
      return def;
    }

    int _int(dynamic v, int def) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? def;
      return def;
    }

    return HeroSlide(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      subtitle: (json['subtitle'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      imageUrl: (json['image_url'] ?? '').toString(),
      ctaText: (json['cta_text'] ?? '').toString(),
      ctaLink: (json['cta_link'] ?? '').toString(),
      isActive: _bool(json['is_active'], true),
      displayOrder: _int(json['display_order'], 0),
      unitId: json['unit_id']?.toString(),
      createdAt: _dt(json['created_at']),
      updatedAt: _dt(json['updated_at']),
      updatedBy: json['updated_by']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'subtitle': subtitle,
    'description': description,
    'image_url': imageUrl,
    'cta_text': ctaText,
    'cta_link': ctaLink,
    'is_active': isActive,
    'display_order': displayOrder,
    if (unitId != null) 'unit_id': unitId,
    'created_at': createdAt.toUtc().toIso8601String(),
    'updated_at': updatedAt.toUtc().toIso8601String(),
    if (updatedBy != null) 'updated_by': updatedBy,
  };

  HeroSlide copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? description,
    String? imageUrl,
    String? ctaText,
    String? ctaLink,
    bool? isActive,
    int? displayOrder,
    String? unitId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? updatedBy,
  }) {
    return HeroSlide(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      ctaText: ctaText ?? this.ctaText,
      ctaLink: ctaLink ?? this.ctaLink,
      isActive: isActive ?? this.isActive,
      displayOrder: displayOrder ?? this.displayOrder,
      unitId: unitId ?? this.unitId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }
}

class BreakingNewsItem {
  final String id;
  final String text;
  final String link;
  final String icon;

  /// Expected values: 'urgent' | 'high' | 'normal' | 'low'
  final String priority;

  final String bgColor;
  final String textColor;

  final int displayOrder;
  final bool isActive;

  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? expiresAt;

  final String? unitId;
  final String? updatedBy;

  BreakingNewsItem({
    this.id = '',
    this.text = '',
    String? link,
    this.icon = '',
    this.priority = 'normal',
    this.bgColor = '',
    this.textColor = '',
    this.displayOrder = 0,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.expiresAt,
    this.unitId,
    this.updatedBy,
  }) : link = link ?? '',
       createdAt =
           createdAt ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
       updatedAt =
           updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  factory BreakingNewsItem.fromJson(Map<String, dynamic> json) {
    DateTime _dt(dynamic v) {
      if (v == null) return DateTime.now().toUtc();
      if (v is DateTime) return v.toUtc();
      if (v is String && v.isNotEmpty)
        return (DateTime.tryParse(v) ?? DateTime.now()).toUtc();
      return DateTime.now().toUtc();
    }

    DateTime? _dtOpt(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v.toUtc();
      if (v is String && v.isNotEmpty) return DateTime.tryParse(v)?.toUtc();
      return null;
    }

    bool _bool(dynamic v, bool def) {
      if (v is bool) return v;
      if (v is num) return v != 0;
      if (v is String) return v.toLowerCase() == 'true';
      return def;
    }

    int _int(dynamic v, int def) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? def;
      return def;
    }

    final pr = (json['priority'] ?? 'normal').toString();
    return BreakingNewsItem(
      id: (json['id'] ?? '').toString(),
      text: (json['text'] ?? '').toString(),
      link: (json['link'] ?? '').toString(),
      icon: (json['icon'] ?? '').toString(),
      priority: pr.isEmpty ? 'normal' : pr,
      bgColor: (json['bg_color'] ?? '').toString(),
      textColor: (json['text_color'] ?? '').toString(),
      displayOrder: _int(json['display_order'], 0),
      isActive: _bool(json['is_active'], true),
      createdAt: _dt(json['created_at']),
      updatedAt: _dt(json['updated_at']),
      expiresAt: _dtOpt(json['expires_at']),
      unitId: json['unit_id']?.toString(),
      updatedBy: json['updated_by']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'link': link,
    'icon': icon,
    'priority': priority,
    'bg_color': bgColor,
    'text_color': textColor,
    'display_order': displayOrder,
    'is_active': isActive,
    'created_at': createdAt.toUtc().toIso8601String(),
    'updated_at': updatedAt.toUtc().toIso8601String(),
    if (expiresAt != null) 'expires_at': expiresAt!.toUtc().toIso8601String(),
    if (unitId != null) 'unit_id': unitId,
    if (updatedBy != null) 'updated_by': updatedBy,
  };

  BreakingNewsItem copyWith({
    String? id,
    String? text,
    String? link,
    String? icon,
    String? priority,
    String? bgColor,
    String? textColor,
    int? displayOrder,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? expiresAt,
    String? unitId,
    String? updatedBy,
  }) {
    return BreakingNewsItem(
      id: id ?? this.id,
      text: text ?? this.text,
      link: link ?? this.link,
      icon: icon ?? this.icon,
      priority: priority ?? this.priority,
      bgColor: bgColor ?? this.bgColor,
      textColor: textColor ?? this.textColor,
      displayOrder: displayOrder ?? this.displayOrder,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      unitId: unitId ?? this.unitId,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }
}

// -----------------------------------------------------------------------------
// Section Settings Models
// -----------------------------------------------------------------------------

/// Base class for section settings stored as JSON in DB.
///
/// We keep [extra] to preserve any unknown fields when round-tripping.
abstract class PwfSectionSettingsBase {
  final Map<String, dynamic> extra;

  const PwfSectionSettingsBase({this.extra = const {}});

  Map<String, dynamic> toJson();
}

Map<String, dynamic> _extractExtra(
  Map<String, dynamic> json, {
  required Set<String> knownKeys,
}) {
  final out = <String, dynamic>{};
  for (final e in json.entries) {
    if (!knownKeys.contains(e.key)) out[e.key] = e.value;
  }
  return out;
}

class MinisterSectionSettings extends PwfSectionSettingsBase {
  final bool enabled;
  final String name;
  final String position;
  final String message;
  final String quote;
  final bool showQuote;
  final bool showSignature;
  final String messageLink;
  final String imageUrl;

  const MinisterSectionSettings({
    this.enabled = true,
    this.name = '',
    this.position = '',
    this.message = '',
    this.quote = '',
    this.showQuote = true,
    this.showSignature = true,
    this.messageLink = '',
    this.imageUrl = '',
    super.extra = const {},
  });

  factory MinisterSectionSettings.fromJson(Map<String, dynamic>? json) {
    final m = json ?? const <String, dynamic>{};
    const known = <String>{
      'enabled',
      'name',
      'minister_name',
      'position',
      'minister_position',
      'message',
      'text',
      'quote',
      'show_quote',
      'showQuote',
      'show_signature',
      'showSignature',
      'message_link',
      'link',
      'image_url',
    };
    bool b(dynamic v, bool fallback) {
      if (v is bool) return v;
      if (v is num) return v != 0;
      if (v is String) return v.toLowerCase() == 'true';
      return fallback;
    }

    return MinisterSectionSettings(
      enabled: b(m['enabled'], true),
      name: (m['name'] ?? m['minister_name'] ?? '').toString(),
      position: (m['position'] ?? m['minister_position'] ?? '').toString(),
      message: (m['message'] ?? m['text'] ?? '').toString(),
      quote: (m['quote'] ?? '').toString(),
      showQuote: b(m['show_quote'] ?? m['showQuote'], true),
      showSignature: b(m['show_signature'] ?? m['showSignature'], true),
      messageLink: (m['message_link'] ?? m['link'] ?? '').toString(),
      imageUrl: (m['image_url'] ?? '').toString(),
      extra: _extractExtra(Map<String, dynamic>.from(m), knownKeys: known),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'name': name,
    'position': position,
    'message': message,
    'quote': quote,
    'show_quote': showQuote,
    'show_signature': showSignature,
    'message_link': messageLink,
    'image_url': imageUrl,
    ...extra,
  };
}

class StatisticsSectionSettings extends PwfSectionSettingsBase {
  final bool enabled;
  final List<dynamic> counters;
  final bool showAnimatedCounters;
  final int animationDuration;
  final bool showTargets;
  final bool showProgress;
  final String layout;

  const StatisticsSectionSettings({
    this.enabled = true,
    this.counters = const <dynamic>[],
    this.showAnimatedCounters = true,
    this.animationDuration = 1200,
    this.showTargets = true,
    this.showProgress = true,
    this.layout = 'grid',
    super.extra = const {},
  });

  factory StatisticsSectionSettings.fromJson(Map<String, dynamic>? json) {
    final m = json ?? const <String, dynamic>{};
    const known = <String>{
      'enabled',
      'counters',
      'show_animated_counters',
      'showAnimatedCounters',
      'animation_duration',
      'animationDuration',
      'show_targets',
      'showTargets',
      'show_progress',
      'showProgress',
      'layout',
    };
    bool b(dynamic v, bool fallback) {
      if (v is bool) return v;
      if (v is num) return v != 0;
      if (v is String) return v.toLowerCase() == 'true';
      return fallback;
    }

    int i(dynamic v, int fallback) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v?.toString() ?? '') ?? fallback;
    }

    return StatisticsSectionSettings(
      enabled: b(m['enabled'], true),
      counters: (m['counters'] as List?)?.toList() ?? const <dynamic>[],
      showAnimatedCounters: b(
        m['show_animated_counters'] ?? m['showAnimatedCounters'],
        true,
      ),
      animationDuration: i(
        m['animation_duration'] ?? m['animationDuration'],
        1200,
      ),
      showTargets: b(m['show_targets'] ?? m['showTargets'], true),
      showProgress: b(m['show_progress'] ?? m['showProgress'], true),
      layout: (m['layout'] ?? 'grid').toString(),
      extra: _extractExtra(Map<String, dynamic>.from(m), knownKeys: known),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'counters': counters,
    'show_animated_counters': showAnimatedCounters,
    'animation_duration': animationDuration,
    'show_targets': showTargets,
    'show_progress': showProgress,
    'layout': layout,
    ...extra,
  };
}

class NewsSectionSettings extends PwfSectionSettingsBase {
  final bool enabled;
  final int maxItems;
  final int showCount;
  final bool showCategories;
  final bool showViewCounts;
  final bool showDates;
  final String layout;
  final bool autoRefresh;
  final int refreshInterval;
  final bool showExcerpts;
  final bool showAuthors;
  final bool showImages;

  const NewsSectionSettings({
    this.enabled = true,
    this.maxItems = 6,
    this.showCount = 3,
    this.showCategories = true,
    this.showViewCounts = false,
    this.showDates = true,
    this.layout = 'grid',
    this.autoRefresh = true,
    this.refreshInterval = 300,
    this.showExcerpts = true,
    this.showAuthors = false,
    this.showImages = true,
    super.extra = const {},
  });

  factory NewsSectionSettings.fromJson(Map<String, dynamic>? json) {
    final m = json ?? const <String, dynamic>{};
    const known = <String>{
      'enabled',
      'max_items',
      'maxItems',
      'show_count',
      'showCount',
      'show_categories',
      'showCategories',
      'show_view_counts',
      'showViewCounts',
      'show_dates',
      'showDates',
      'layout',
      'auto_refresh',
      'autoRefresh',
      'refresh_interval',
      'refreshInterval',
      'show_excerpts',
      'showExcerpts',
      'show_authors',
      'showAuthors',
      'show_images',
      'showImages',
    };
    bool b(dynamic v, bool fallback) {
      if (v is bool) return v;
      if (v is num) return v != 0;
      if (v is String) return v.toLowerCase() == 'true';
      return fallback;
    }

    int i(dynamic v, int fallback) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v?.toString() ?? '') ?? fallback;
    }

    final max = i(m['max_items'] ?? m['maxItems'], 6);
    return NewsSectionSettings(
      enabled: b(m['enabled'], true),
      maxItems: max,
      showCount: i(m['show_count'] ?? m['showCount'], max < 3 ? max : 3),
      showCategories: b(m['show_categories'] ?? m['showCategories'], true),
      showViewCounts: b(m['show_view_counts'] ?? m['showViewCounts'], false),
      showDates: b(m['show_dates'] ?? m['showDates'], true),
      layout: (m['layout'] ?? 'grid').toString(),
      autoRefresh: b(m['auto_refresh'] ?? m['autoRefresh'], true),
      refreshInterval: i(m['refresh_interval'] ?? m['refreshInterval'], 300),
      showExcerpts: b(m['show_excerpts'] ?? m['showExcerpts'], true),
      showAuthors: b(m['show_authors'] ?? m['showAuthors'], false),
      showImages: b(m['show_images'] ?? m['showImages'], true),
      extra: _extractExtra(Map<String, dynamic>.from(m), knownKeys: known),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'max_items': maxItems,
    'show_count': showCount,
    'show_categories': showCategories,
    'show_view_counts': showViewCounts,
    'show_dates': showDates,
    'layout': layout,
    'auto_refresh': autoRefresh,
    'refresh_interval': refreshInterval,
    'show_excerpts': showExcerpts,
    'show_authors': showAuthors,
    'show_images': showImages,
    ...extra,
  };
}

class AnnouncementsSectionSettings extends PwfSectionSettingsBase {
  final bool enabled;
  final int maxItems;
  final int showCount;
  final bool showPriorities;
  final bool showExpiry;
  final bool highlightUrgent;
  final String layout;
  final bool showIcons;
  final bool showDates;

  const AnnouncementsSectionSettings({
    this.enabled = true,
    this.maxItems = 6,
    this.showCount = 4,
    this.showPriorities = true,
    this.showExpiry = true,
    this.highlightUrgent = true,
    this.layout = 'cards',
    this.showIcons = true,
    this.showDates = true,
    super.extra = const {},
  });

  factory AnnouncementsSectionSettings.fromJson(Map<String, dynamic>? json) {
    final m = json ?? const <String, dynamic>{};
    const known = <String>{
      'enabled',
      'max_items',
      'maxItems',
      'show_count',
      'showCount',
      'show_priorities',
      'showPriorities',
      'show_expiry',
      'showExpiry',
      'highlight_urgent',
      'highlightUrgent',
      'layout',
      'show_icons',
      'showIcons',
      'show_dates',
      'showDates',
    };
    bool b(dynamic v, bool fallback) {
      if (v is bool) return v;
      if (v is num) return v != 0;
      if (v is String) return v.toLowerCase() == 'true';
      return fallback;
    }

    int i(dynamic v, int fallback) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v?.toString() ?? '') ?? fallback;
    }

    return AnnouncementsSectionSettings(
      enabled: b(m['enabled'], true),
      maxItems: i(m['max_items'] ?? m['maxItems'], 6),
      showCount: i(m['show_count'] ?? m['showCount'], 4),
      showPriorities: b(m['show_priorities'] ?? m['showPriorities'], true),
      showExpiry: b(m['show_expiry'] ?? m['showExpiry'], true),
      highlightUrgent: b(m['highlight_urgent'] ?? m['highlightUrgent'], true),
      layout: (m['layout'] ?? 'cards').toString(),
      showIcons: b(m['show_icons'] ?? m['showIcons'], true),
      showDates: b(m['show_dates'] ?? m['showDates'], true),
      extra: _extractExtra(Map<String, dynamic>.from(m), knownKeys: known),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'max_items': maxItems,
    'show_count': showCount,
    'show_priorities': showPriorities,
    'show_expiry': showExpiry,
    'highlight_urgent': highlightUrgent,
    'layout': layout,
    'show_icons': showIcons,
    'show_dates': showDates,
    ...extra,
  };
}

class BreakingNewsSectionSettings extends PwfSectionSettingsBase {
  final bool enabled;
  final bool autoScroll;
  final bool showBorder;
  final bool showIcon;
  final String defaultIcon;
  final bool showSeparator;
  final String separatorText;
  final bool allowClick;
  final double height;
  final int scrollSpeed;
  final int pauseDuration;
  final int maxItems;
  final String backgroundColor;

  const BreakingNewsSectionSettings({
    this.enabled = true,
    this.autoScroll = true,
    this.showBorder = true,
    this.showIcon = true,
    this.defaultIcon = 'campaign',
    this.showSeparator = true,
    this.separatorText = 'آخر الأخبار',
    this.allowClick = true,
    this.height = 48,
    this.scrollSpeed = 60,
    this.pauseDuration = 3000,
    this.maxItems = 10,
    this.backgroundColor = '#B22222',
    super.extra = const {},
  });

  factory BreakingNewsSectionSettings.fromJson(Map<String, dynamic>? json) {
    final m = json ?? const <String, dynamic>{};
    bool b(dynamic v, bool fallback) {
      if (v is bool) return v;
      if (v is num) return v != 0;
      if (v is String) return v.toLowerCase() == 'true';
      return fallback;
    }

    int i(dynamic v, int fallback) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v?.toString() ?? '') ?? fallback;
    }

    double d(dynamic v, double fallback) {
      if (v is num) return v.toDouble();
      return double.tryParse(v?.toString() ?? '') ?? fallback;
    }

    const known = <String>{
      'enabled',
      'auto_scroll',
      'autoScroll',
      'show_border',
      'showBorder',
      'show_icon',
      'showIcon',
      'default_icon',
      'defaultIcon',
      'show_separator',
      'showSeparator',
      'separator_text',
      'separatorText',
      'allow_click',
      'allowClick',
      'height',
      'scroll_speed',
      'scrollSpeed',
      'pause_duration',
      'pauseDuration',
      'max_items',
      'maxItems',
      'background_color',
      'backgroundColor',
    };
    return BreakingNewsSectionSettings(
      enabled: b(m['enabled'], true),
      autoScroll: b(m['auto_scroll'] ?? m['autoScroll'], true),
      showBorder: b(m['show_border'] ?? m['showBorder'], true),
      showIcon: b(m['show_icon'] ?? m['showIcon'], true),
      defaultIcon: (m['default_icon'] ?? m['defaultIcon'] ?? 'campaign')
          .toString(),
      showSeparator: b(m['show_separator'] ?? m['showSeparator'], true),
      separatorText:
          (m['separator_text'] ?? m['separatorText'] ?? 'آخر الأخبار')
              .toString(),
      allowClick: b(m['allow_click'] ?? m['allowClick'], true),
      height: d(m['height'], 48),
      scrollSpeed: i(m['scroll_speed'] ?? m['scrollSpeed'], 60),
      pauseDuration: i(m['pause_duration'] ?? m['pauseDuration'], 3000),
      maxItems: i(m['max_items'] ?? m['maxItems'], 10),
      backgroundColor:
          (m['background_color'] ?? m['backgroundColor'] ?? '#B22222')
              .toString(),
      extra: _extractExtra(Map<String, dynamic>.from(m), knownKeys: known),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'auto_scroll': autoScroll,
    'show_border': showBorder,
    'show_icon': showIcon,
    'default_icon': defaultIcon,
    'show_separator': showSeparator,
    'separator_text': separatorText,
    'allow_click': allowClick,
    'height': height,
    'scroll_speed': scrollSpeed,
    'pause_duration': pauseDuration,
    'max_items': maxItems,
    'background_color': backgroundColor,
    ...extra,
  };
}
