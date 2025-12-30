import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/homepage_section.dart';

class HomepageRepository {
  final SupabaseClient _client;

  HomepageRepository(this._client);

  // ============================================
  // SITE SETTINGS (Single Row)
  // ============================================

  Future<SiteSettings?> fetchSiteSettings() async {
    try {
      final row = await _client
          .from('site_settings')
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
      await _client.from('site_settings').update({
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
      }).eq('id', settings.id);

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
          .from('hero_slides')
          .select()
          .eq('is_active', true)
          .order('display_order', ascending: true);

      return (rows as List<dynamic>)
          .map((json) => HeroSlide.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      log('Error fetching active hero slides: $e');
      return [];
    }
  }

  Future<List<HeroSlide>> fetchAllHeroSlides() async {
    try {
      final rows = await _client
          .from('hero_slides')
          .select()
          .order('display_order', ascending: true);

      return (rows as List<dynamic>)
          .map((json) => HeroSlide.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      log('Error fetching all hero slides: $e');
      return [];
    }
  }

  Future<HeroSlide?> fetchHeroSlide(String id) async {
    try {
      final row = await _client
          .from('hero_slides')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (row == null) return null;
      return HeroSlide.fromJson(row);
    } catch (e) {
      log('Error fetching hero slide: $e');
      return null;
    }
  }

  Future<String?> createHeroSlide(HeroSlide slide) async {
    try {
      final userId = _client.auth.currentUser?.id;
      final response = await _client.from('hero_slides').insert({
        'title': slide.title,
        'subtitle': slide.subtitle,
        'description': slide.description,
        'image_url': slide.imageUrl,
        'cta_text': slide.ctaText,
        'cta_link': slide.ctaLink,
        'display_order': slide.displayOrder,
        'is_active': slide.isActive,
        'updated_by': userId,
      }).select('id').single();

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
      await _client.from('hero_slides').update({
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
      }).eq('id', slide.id);

      log('Hero slide updated: ${slide.id}');
      return true;
    } catch (e) {
      log('Error updating hero slide: $e');
      return false;
    }
  }

  Future<bool> deleteHeroSlide(String id) async {
    try {
      await _client.from('hero_slides').delete().eq('id', id);
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
          .from('hero_slides')
          .select()
          .eq('is_active', true)
          .gte('display_order', fromOrder)
          .order('display_order', ascending: false); // Start from highest to avoid conflicts

      // Update each slide's order
      for (final slideData in slides) {
        final currentOrder = slideData['display_order'] as int;
        await _client
            .from('hero_slides')
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
            .from('hero_slides')
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

  static const String sectionsTable = 'homepage_sections';

  Future<Map<String, dynamic>?> _fetchRow(String sectionName) async {
    final row = await _client
        .from(sectionsTable)
        .select(
        'id, section_name, settings, is_active, display_order, created_at, updated_at, updated_by')
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
    final rows = await _client.from(sectionsTable).select(
      'id, section_name, settings, is_active, display_order, created_at, updated_at, updated_by',
    );

    return (rows as List<dynamic>)
        .map((j) => HomepageSection.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  // -------- Minister ----------
  Future<MinisterSectionSettings?> fetchMinisterSettings() async {
    final row = await _fetchRow('minister');
    final settings = (row?['settings'] as Map<String, dynamic>?) ?? {};
    return MinisterSectionSettings.fromJson(settings);
  }

  Future<void> updateMinisterSection(MinisterSectionSettings settings,
      {bool? isActive, int? displayOrder}) {
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

  Future<void> updateStatisticsSection(StatisticsSectionSettings settings,
      {bool? isActive, int? displayOrder}) {
    return _upsertSection(
      sectionName: 'statistics',
      settingsJson: settings.toJson(),
      isActive: isActive,
      displayOrder: displayOrder,
    );
  }

  // -------- News ----------
  Future<NewsSectionSettings?> fetchNewsSettings() async {
    final row = await _fetchRow('news');
    final settings = (row?['settings'] as Map<String, dynamic>?) ?? {};
    return NewsSectionSettings.fromJson(settings);
  }

  Future<void> updateNewsSection(NewsSectionSettings settings,
      {bool? isActive, int? displayOrder}) {
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
      AnnouncementsSectionSettings settings,
      {bool? isActive, int? displayOrder}) {
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
          .from('breaking_news')
          .select()
          .eq('is_active', true)
          .or('expires_at.is.null,expires_at.gt.$now')
          .order('display_order', ascending: true);

      return (rows as List<dynamic>)
          .map((json) => BreakingNewsItem.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      log('Error fetching active breaking news: $e');
      return [];
    }
  }

  /// Fetch all breaking news items (for admin)
  Future<List<BreakingNewsItem>> fetchAllBreakingNews() async {
    try {
      final rows = await _client
          .from('breaking_news')
          .select()
          .order('display_order', ascending: true);

      return (rows as List<dynamic>)
          .map((json) => BreakingNewsItem.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      log('Error fetching all breaking news: $e');
      return [];
    }
  }

  /// Fetch single breaking news item
  Future<BreakingNewsItem?> fetchBreakingNewsItem(String id) async {
    try {
      final row = await _client
          .from('breaking_news')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (row == null) return null;
      return BreakingNewsItem.fromJson(row);
    } catch (e) {
      log('Error fetching breaking news item: $e');
      return null;
    }
  }

  /// Create new breaking news item
  Future<String?> createBreakingNewsItem(BreakingNewsItem item) async {
    try {
      final userId = _client.auth.currentUser?.id;
      final response = await _client.from('breaking_news').insert({
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
      }).select('id').single();

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
      await _client.from('breaking_news').update({
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
      }).eq('id', item.id);

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
      await _client.from('breaking_news').delete().eq('id', id);
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
            .from('breaking_news')
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
      BreakingNewsSectionSettings settings,
      {bool? isActive, int? displayOrder}) {
    return _upsertSection(
      sectionName: 'breaking_news',
      settingsJson: settings.toJson(),
      isActive: isActive,
      displayOrder: displayOrder,
    );
  }


}