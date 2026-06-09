class UnitRoutes {
  UnitRoutes._();

  static String norm(String slug) => slug.trim().toLowerCase();

  static String home(String slug) {
    final s = norm(slug);
    return s == 'home' ? '/home' : '/$s';
  }

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

  static String newsDetail(String slug, int id) => '${news(slug)}/$id';

  static String announcementDetail(String slug, int id) =>
      '${announcements(slug)}/$id';
  static String activityDetail(String slug, int id) =>
      '${activities(slug)}/$id';
}
