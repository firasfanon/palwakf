import 'package:flutter/material.dart';

import 'pwf_internal_public_page_spec.dart';

const List<PwfInternalPublicPageSpec>
kPwfInternalPublicPageSpecs = <PwfInternalPublicPageSpec>[
  PwfInternalPublicPageSpec(
    key: 'prayer_times',
    pageSlug: 'prayer-times',
    titleAr: 'مواقيت الصلاة',
    titleEn: 'Prayer Times',
    subtitleAr:
        'خدمة داخلية عامة لعرض المواقيت اليومية والقبلة والإعدادات المرتبطة بها ضمن هوية المنصة الموحدة.',
    subtitleEn:
        'Unified internal public page for daily prayer times, Qibla, and related settings.',
    icon: Icons.access_time_rounded,
    type: PwfInternalPublicPageType.serviceTool,
    defaultSections: <PwfInternalPublicSectionType>[
      PwfInternalPublicSectionType.intro,
      PwfInternalPublicSectionType.mainContent,
    ],
  ),
  PwfInternalPublicPageSpec(
    key: 'zakat',
    pageSlug: 'zakat',
    titleAr: 'الزكاة',
    titleEn: 'Zakat',
    subtitleAr:
        'واجهة موحدة لحساب الزكاة وعرض المعلومات والتبرع ضمن الواجهة العامة للمنصة بدون بطولات بصرية منفصلة.',
    subtitleEn:
        'Unified public experience for zakat calculation, guidance, and donation workflows.',
    icon: Icons.volunteer_activism_outlined,
    type: PwfInternalPublicPageType.serviceTool,
    defaultSections: <PwfInternalPublicSectionType>[
      PwfInternalPublicSectionType.intro,
      PwfInternalPublicSectionType.mainContent,
    ],
  ),
  PwfInternalPublicPageSpec(
    key: 'quran',
    pageSlug: 'quran',
    titleAr: 'القرآن الكريم',
    titleEn: 'Quran',
    subtitleAr:
        'واجهة عامة متناسقة لقراءة السور والآيات ضمن الهوية الموحدة للمنصة.',
    subtitleEn:
        'Unified public reading experience for the Quran within the platform identity.',
    icon: Icons.menu_book_rounded,
    type: PwfInternalPublicPageType.reader,
    defaultSections: <PwfInternalPublicSectionType>[
      PwfInternalPublicSectionType.intro,
      PwfInternalPublicSectionType.mainContent,
    ],
  ),
  PwfInternalPublicPageSpec(
    key: 'services',
    pageSlug: 'services',
    titleAr: 'الخدمات',
    titleEn: 'Services',
    subtitleAr:
        'صفحة داخلية موحدة للخدمات العامة تحت هوية المنصة وبطاقة تعريف بعرض متناسق مع الأقسام.',
    subtitleEn:
        'Unified internal public services page aligned with the platform section rhythm.',
    icon: Icons.miscellaneous_services_outlined,
    type: PwfInternalPublicPageType.informational,
  ),
  PwfInternalPublicPageSpec(
    key: 'eservices',
    pageSlug: 'eservices',
    titleAr: 'الخدمات الإلكترونية',
    titleEn: 'E-Services',
    subtitleAr:
        'بوابة الخدمات الإلكترونية ضمن تنسيق موحد للصفحات الداخلية وإطار واضح للبحث والعرض.',
    subtitleEn:
        'Unified e-services portal page for search and discovery within the platform shell.',
    icon: Icons.apps_outlined,
    type: PwfInternalPublicPageType.informational,
  ),
  PwfInternalPublicPageSpec(
    key: 'news',
    pageSlug: 'news',
    titleAr: 'الأخبار',
    titleEn: 'News',
    subtitleAr:
        'صفحة أخبار داخلية متسقة تدعم المقدمة والإحصاءات والفلاتر والمحتوى الرئيسي والبلوك التكميلي.',
    subtitleEn:
        'Unified news listing and detail experience with intro, stats, filters, and complementary content.',
    icon: Icons.newspaper_rounded,
    type: PwfInternalPublicPageType.listing,
    defaultSections: <PwfInternalPublicSectionType>[
      PwfInternalPublicSectionType.intro,
      PwfInternalPublicSectionType.stats,
      PwfInternalPublicSectionType.filters,
      PwfInternalPublicSectionType.mainContent,
      PwfInternalPublicSectionType.complementary,
    ],
  ),
  PwfInternalPublicPageSpec(
    key: 'announcements',
    pageSlug: 'announcements',
    titleAr: 'الإعلانات',
    titleEn: 'Announcements',
    subtitleAr:
        'صفحة إعلانات داخلية متناسقة ضمن نفس عقد الأخبار مع اختلاف المحتوى التحريري.',
    subtitleEn:
        'Unified announcements page aligned with the internal public content contract.',
    icon: Icons.campaign_outlined,
    type: PwfInternalPublicPageType.listing,
    defaultSections: <PwfInternalPublicSectionType>[
      PwfInternalPublicSectionType.intro,
      PwfInternalPublicSectionType.stats,
      PwfInternalPublicSectionType.filters,
      PwfInternalPublicSectionType.mainContent,
      PwfInternalPublicSectionType.complementary,
    ],
  ),
  PwfInternalPublicPageSpec(
    key: 'activities',
    pageSlug: 'activities',
    titleAr: 'الأنشطة والفعاليات',
    titleEn: 'Activities',
    subtitleAr:
        'صفحة أنشطة داخلية متناسقة مع الأخبار والإعلانات في البنية والبطاقات والفلاتر.',
    subtitleEn:
        'Unified activities page aligned with the same listing and card contract used by news and announcements.',
    icon: Icons.event_note_outlined,
    type: PwfInternalPublicPageType.listing,
    defaultSections: <PwfInternalPublicSectionType>[
      PwfInternalPublicSectionType.intro,
      PwfInternalPublicSectionType.stats,
      PwfInternalPublicSectionType.filters,
      PwfInternalPublicSectionType.mainContent,
      PwfInternalPublicSectionType.complementary,
    ],
  ),
];

const List<PwfInternalPublicSectionSpec> kPwfInternalPublicSectionSpecs =
    <PwfInternalPublicSectionSpec>[
      PwfInternalPublicSectionSpec(
        key: 'pwf_prayer_times',
        titleAr: 'مواقيت الصلاة',
        pageSpecKey: 'prayer_times',
      ),
      PwfInternalPublicSectionSpec(
        key: 'pwf_quick_services',
        titleAr: 'الخدمات',
        pageSpecKey: 'services',
      ),
      PwfInternalPublicSectionSpec(
        key: 'pwf_eservices_portal',
        titleAr: 'الخدمات الإلكترونية',
        pageSpecKey: 'eservices',
      ),
      PwfInternalPublicSectionSpec(
        key: 'pwf_news',
        titleAr: 'الأخبار',
        pageSpecKey: 'news',
        supportsListing: true,
        supportsDetail: true,
        supportsFilters: true,
        supportsCompanion: true,
      ),
      PwfInternalPublicSectionSpec(
        key: 'pwf_news_tabs',
        titleAr: 'الأخبار',
        pageSpecKey: 'news',
        supportsListing: true,
        supportsDetail: true,
        supportsFilters: true,
        supportsCompanion: true,
      ),
      PwfInternalPublicSectionSpec(
        key: 'pwf_announcements',
        titleAr: 'الإعلانات',
        pageSpecKey: 'announcements',
        supportsListing: true,
        supportsDetail: true,
        supportsFilters: true,
        supportsCompanion: true,
      ),
      PwfInternalPublicSectionSpec(
        key: 'pwf_activities',
        titleAr: 'الأنشطة والفعاليات',
        pageSpecKey: 'activities',
        supportsListing: true,
        supportsDetail: true,
        supportsFilters: true,
        supportsCompanion: true,
      ),
    ];

PwfInternalPublicPageSpec? findPwfInternalPublicPageSpec(String key) {
  for (final spec in kPwfInternalPublicPageSpecs) {
    if (spec.key == key || spec.pageSlug == key) return spec;
  }
  return null;
}

PwfInternalPublicSectionSpec? findPwfInternalPublicSectionSpec(
  String sectionKey,
) {
  for (final spec in kPwfInternalPublicSectionSpecs) {
    if (spec.key == sectionKey) return spec;
  }
  return null;
}

String? pwfPageSpecKeyForSection(String sectionKey) =>
    findPwfInternalPublicSectionSpec(sectionKey)?.pageSpecKey;
