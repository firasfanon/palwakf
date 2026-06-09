enum SystemKey {
  site,
  platformAdmin,
  mustakshif,
  adminData,
  awqafSystem,
  zakat,
  prayerTimes,
  quran,
  lands,
  properties,
  cases,
  tasks,
  mosques,
  billing,
}

extension SystemKeyX on SystemKey {
  /// Slug used in routes and (optionally) org_units.slug
  String get slug => switch (this) {
    SystemKey.site => 'site',
    SystemKey.platformAdmin => 'admin',
    SystemKey.mustakshif => 'mustakshif',
    SystemKey.adminData => 'admin-data',
    SystemKey.awqafSystem => 'awqaf-system',
    SystemKey.zakat => 'zakat',
    SystemKey.prayerTimes => 'prayer-times',
    SystemKey.quran => 'quran',
    SystemKey.lands => 'lands',
    SystemKey.properties => 'properties',
    SystemKey.cases => 'cases',
    SystemKey.tasks => 'tasks',
    SystemKey.mosques => 'mosques',
    SystemKey.billing => 'billing',
  };

  /// Arabic display name (used in dashboards / UI)
  String get nameAr => switch (this) {
    SystemKey.site => 'الموقع العام',
    SystemKey.platformAdmin => 'لوحة الإدارة',
    SystemKey.mustakshif => 'مستكشف الوقف',
    SystemKey.adminData => 'البيانات الإدارية',
    SystemKey.awqafSystem => 'أوقاف سيستم',
    SystemKey.zakat => 'خدمة الزكاة',
    SystemKey.prayerTimes => 'خدمة مواقيت الصلاة',
    SystemKey.quran => 'خدمة القرآن الكريم',
    SystemKey.lands => 'نظام الأراضي',
    SystemKey.properties => 'نظام العقارات',
    SystemKey.cases => 'نظام القضايا',
    SystemKey.tasks => 'نظام المهام',
    SystemKey.mosques => 'نظام المساجد',
    SystemKey.billing => 'الفوترة',
  };

  /// English display name (optional)
  String get nameEn => switch (this) {
    SystemKey.site => 'Public Site',
    SystemKey.platformAdmin => 'Admin',
    SystemKey.mustakshif => 'Waqf Explorer',
    SystemKey.adminData => 'Admin Data',
    SystemKey.awqafSystem => 'Awqaf System',
    SystemKey.zakat => 'Zakat',
    SystemKey.prayerTimes => 'Prayer Times',
    SystemKey.quran => 'Quran',
    SystemKey.lands => 'Lands',
    SystemKey.properties => 'Properties',
    SystemKey.cases => 'Cases',
    SystemKey.tasks => 'Tasks',
    SystemKey.mosques => 'Mosques',
    SystemKey.billing => 'Billing',
  };
}
