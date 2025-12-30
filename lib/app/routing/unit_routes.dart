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

  static String newsDetail(String slug, int id) => '${news(slug)}/$id';
}
