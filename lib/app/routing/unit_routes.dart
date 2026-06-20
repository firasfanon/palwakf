import '../../core/unit/pwf_unit_slug_registry.dart';

class UnitRoutes {
  UnitRoutes._();

  static String norm(String slug) => PwfUnitSlugRegistry.publicSlugFor(slug);

  static String home(String slug) {
    final s = norm(slug);
    return s == 'home' ? '/home' : '/$s';
  }

  static String about(String slug) => '${home(slug)}/about';
  static String visionMission(String slug) => '${home(slug)}/vision-mission';
  static String structure(String slug) => '${home(slug)}/structure';
  static String formerMinisters(String slug) => '${home(slug)}/former-ministers';
  static String contact(String slug) => '${home(slug)}/contact';
  static String privacy(String slug) => '${home(slug)}/privacy';
  static String terms(String slug) => '${home(slug)}/terms';
  static String sitemap(String slug) => '${home(slug)}/sitemap';
  static String search(String slug) => '${home(slug)}/search';

  static String news(String slug) => '${home(slug)}/news';
  static String announcements(String slug) => '${home(slug)}/announcements';
  static String activities(String slug) => '${home(slug)}/activities';
  static String services(String slug) => '${home(slug)}/services';
  static String eservices(String slug) => '${home(slug)}/eservices';
  static String serviceRequest(String slug) => '${home(slug)}/services/request';
  static String serviceTracking(String slug) => '${home(slug)}/services/track';
  static String complaints(String slug) => '${home(slug)}/complaints';
  static String chat(String slug) => '${home(slug)}/chat';
  static String legalReferences(String slug) =>
      '${home(slug)}/legal-references';
  static String quran(String slug) => '${home(slug)}/quran';
  static String prayerTimes(String slug) => '${home(slug)}/prayer-times';
  static String zakat(String slug) => '${home(slug)}/zakat';

  static String media(String slug) => '${home(slug)}/media';
  static String gallery(String slug) => '${home(slug)}/gallery';
  static String mediaCenter(String slug) => '${home(slug)}/media-center';
  static String fridaySermons(String slug) => '${home(slug)}/friday-sermons';
  static String events(String slug) => '${home(slug)}/events';
  static String socialPosts(String slug) => '${home(slug)}/social-posts';
  static String pressReleases(String slug) => '${home(slug)}/press-releases';
  static String officialStatements(String slug) =>
      '${home(slug)}/official-statements';
  static String awarenessCampaigns(String slug) =>
      '${home(slug)}/awareness-campaigns';
  static String sanctitiesObservatory(String slug) =>
      '${home(slug)}/sanctities-observatory';

  static String _contentPathSegment(Object contentId) =>
      Uri.encodeComponent(contentId.toString().trim());

  /// Public Media Center content IDs are opaque. Never derive these routes from
  /// a bounded feed window or a lossy integer hash.
  static String newsDetail(String slug, Object contentId) =>
      '${news(slug)}/${_contentPathSegment(contentId)}';

  static String announcementDetail(String slug, Object contentId) =>
      '${announcements(slug)}/${_contentPathSegment(contentId)}';
  static String activityDetail(String slug, Object contentId) =>
      '${activities(slug)}/${_contentPathSegment(contentId)}';
}
