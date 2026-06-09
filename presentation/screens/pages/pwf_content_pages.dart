import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/pwf_ui_prefs_provider.dart';
import '../../theme/pwf_theme_tokens.dart';
import '../pwf_web_page_scaffold.dart';
import '../../widgets/pwf_section_container.dart';
import '../../../data/providers/pwf_site_pages_providers.dart';

/// Real content pages for public site (Web identity).
///
/// These pages replace the temporary placeholders created earlier and keep the
/// new HTML identity via [PwfWebPageScaffold].
///
/// Notes:
/// - Web-only in current phase; mobile keeps legacy screens.
/// - Bilingual: picks Arabic when locale is `ar`, else English.

class PwfAboutWebScreen extends ConsumerWidget {
  const PwfAboutWebScreen({super.key, required this.unitSlug});
  final String unitSlug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAr =
        Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';
    return _PwfCmsOrFallbackPage(
      unitSlug: unitSlug,
      pageSlug: 'about',
      title: isAr ? 'عن الوزارة' : 'About the Ministry',
      subtitle: isAr
          ? 'نبذة تعريفية ورسالة الوزارة وأهدافها الأساسية'
          : 'Overview, mission, and core objectives',
      sections: [
        _PwfContentSection(
          heading: isAr ? 'نبذة' : 'Overview',
          body: isAr
              ? 'تتولى وزارة الأوقاف والشؤون الدينية في دولة فلسطين إدارة شؤون الأوقاف، وخدمة المساجد، وتنظيم أعمال الزكاة والصدقات، والإشراف على التعليم الشرعي والوعظ والإرشاد، وتطوير الخدمات الدينية وفق الأنظمة والقوانين النافذة.'
              : 'The Ministry of Awqaf and Religious Affairs in the State of Palestine manages awqaf assets, supports mosques, organizes zakat and charity work, oversees religious education and guidance, and develops religious services in accordance with applicable laws and regulations.',
        ),
        _PwfContentSection(
          heading: isAr ? 'الأهداف' : 'Objectives',
          bullets: isAr
              ? const [
                  'حماية الأوقاف وتنميتها وتعظيم منفعتها العامة.',
                  'خدمة المساجد وتطوير إدارتها وصيانتها.',
                  'تطوير منظومة التعليم الشرعي والوعظ والإرشاد.',
                  'تعزيز الشفافية والتحول الرقمي في خدمات الوزارة.',
                ]
              : const [
                  'Protect and develop awqaf assets and maximize public benefit.',
                  'Support mosques and improve their management and maintenance.',
                  'Advance religious education, guidance, and outreach.',
                  'Strengthen transparency and digital transformation of services.',
                ],
        ),
      ],
      primaryActionLabel: isAr ? 'تواصل معنا' : 'Contact us',
      primaryActionPath: '/contact',
    );
  }
}

class PwfMinisterMessageWebScreen extends ConsumerWidget {
  const PwfMinisterMessageWebScreen({super.key, required this.unitSlug});
  final String unitSlug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAr =
        Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';
    return _PwfCmsOrFallbackPage(
      unitSlug: unitSlug,
      pageSlug: 'minister',
      title: isAr ? 'كلمة الوزير' : "Minister's Message",
      subtitle: isAr
          ? 'رسالة توجيهية حول دور الوزارة وأولويات العمل'
          : 'A guiding note on the ministry’s role and priorities',
      sections: [
        _PwfContentSection(
          heading: isAr ? 'رسالة' : 'Message',
          body: isAr
              ? 'نسعى في وزارة الأوقاف والشؤون الدينية إلى صون الأمانة وتعظيم أثر الوقف لخدمة المجتمع، وتعزيز دور المساجد، وتطوير خدماتنا وفق منهجية مؤسسية شفافة. نعمل على تحديث الإجراءات والتحول الرقمي لتسهيل الوصول إلى الخدمات ورفع كفاءة الأداء.'
              : 'At the Ministry of Awqaf and Religious Affairs, we work to safeguard this trust and maximize the impact of awqaf for the community, strengthen the role of mosques, and enhance services through transparent institutional practices. We are modernizing procedures and enabling digital services to improve access and efficiency.',
        ),
        _PwfContentSection(
          heading: isAr ? 'أولويات' : 'Priorities',
          bullets: isAr
              ? const [
                  'حوكمة إدارة الأوقاف وتوثيقها وتحديث بياناتها.',
                  'تطوير خدمات المواطنين والبوابات الإلكترونية.',
                  'تمكين المديريات وتعزيز التكامل بين الأنظمة.',
                ]
              : const [
                  'Governance of awqaf management and data modernization.',
                  'Improving citizen services and e-portals.',
                  'Empowering directorates and integrating systems.',
                ],
        ),
      ],
      primaryActionLabel: isAr ? 'استعرض الخدمات' : 'Explore services',
      primaryActionPath: '/services',
    );
  }
}

class PwfVisionMissionWebScreen extends ConsumerWidget {
  const PwfVisionMissionWebScreen({super.key, required this.unitSlug});
  final String unitSlug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAr =
        Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';
    return _PwfCmsOrFallbackPage(
      unitSlug: unitSlug,
      pageSlug: 'vision-mission',
      title: isAr ? 'الرؤية والرسالة' : 'Vision & Mission',
      subtitle: isAr
          ? 'إطار العمل المؤسسي والقيم الحاكمة'
          : 'Institutional framework and guiding values',
      sections: [
        _PwfContentSection(
          heading: isAr ? 'الرؤية' : 'Vision',
          body: isAr
              ? 'أوقافٌ مُستدامة وخدماتٌ دينية رائدة تُعزّز التنمية المجتمعية وتحفظ الهوية.'
              : 'Sustainable awqaf and leading religious services that enhance community development and preserve identity.',
        ),
        _PwfContentSection(
          heading: isAr ? 'الرسالة' : 'Mission',
          body: isAr
              ? 'إدارة الأوقاف وتنميتها بكفاءة وشفافية، ودعم المساجد والأنشطة الدينية، وتطوير الخدمات للمواطنين بالتكامل مع المديريات والجهات الشريكة.'
              : 'Manage and develop awqaf efficiently and transparently, support mosques and religious activities, and improve citizen services in coordination with directorates and partners.',
        ),
        _PwfContentSection(
          heading: isAr ? 'القيم' : 'Values',
          bullets: isAr
              ? const [
                  'الأمانة',
                  'الشفافية',
                  'العدالة',
                  'الخدمة العامة',
                  'الاحترافية',
                ]
              : const [
                  'Trust',
                  'Transparency',
                  'Fairness',
                  'Public service',
                  'Professionalism',
                ],
        ),
      ],
      primaryActionLabel: isAr ? 'عن الوزارة' : 'About',
      primaryActionPath: '/about',
    );
  }
}

class PwfOrgStructureWebScreen extends ConsumerWidget {
  const PwfOrgStructureWebScreen({super.key, required this.unitSlug});
  final String unitSlug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAr =
        Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';
    return _PwfCmsOrFallbackPage(
      unitSlug: unitSlug,
      pageSlug: 'structure',
      title: isAr ? 'الهيكل التنظيمي' : 'Organizational Structure',
      subtitle: isAr
          ? 'الإدارات والمديريات وأقسام العمل'
          : 'Departments, directorates, and functions',
      sections: [
        _PwfContentSection(
          heading: isAr ? 'وحدات رئيسية' : 'Main units',
          bullets: isAr
              ? const [
                  'الإدارة العامة للأوقاف والأملاك الوقفية',
                  'الإدارة العامة للمساجد',
                  'الإدارة العامة للزكاة والصدقات',
                  'الإدارة العامة للتعليم الشرعي',
                  'الإدارة العامة للحج والعمرة',
                ]
              : const [
                  'General Directorate of Awqaf & Waqf Properties',
                  'General Directorate of Mosques',
                  'General Directorate of Zakat & Charity',
                  'General Directorate of Religious Education',
                  'General Directorate of Hajj & Umrah',
                ],
        ),
        _PwfContentSection(
          heading: isAr ? 'ملاحظة' : 'Note',
          body: isAr
              ? 'سيتم لاحقًا عرض المخطط التنظيمي الكامل بصيغة تفاعلية وربطه بصفحات المديريات ضمن المنصة.'
              : 'A full interactive organization chart will be added later and linked to directorate pages within the platform.',
        ),
      ],
      primaryActionLabel: isAr ? 'المديريات' : 'Directorates',
      primaryActionPath: '/systems',
    );
  }
}

class PwfMosquesAwqafWebScreen extends ConsumerWidget {
  const PwfMosquesAwqafWebScreen({super.key, required this.unitSlug});
  final String unitSlug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAr =
        Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';
    return _PwfCmsOrFallbackPage(
      unitSlug: unitSlug,
      pageSlug: 'mosques',
      title: isAr ? 'المساجد والأوقاف' : 'Mosques & Awqaf',
      subtitle: isAr
          ? 'الخدمات المرتبطة بالمساجد وإدارة الأصول الوقفية'
          : 'Services for mosques and management of awqaf assets',
      sections: [
        _PwfContentSection(
          heading: isAr ? 'خدمات المساجد' : 'Mosques services',
          bullets: isAr
              ? const [
                  'إدارة شؤون المساجد وصيانتها وتجهيزاتها.',
                  'تنظيم شؤون الأئمة والمؤذنين والخطباء.',
                  'متابعة الأنشطة الدينية وبرامج الوعظ والإرشاد.',
                ]
              : const [
                  'Mosque administration, maintenance, and facilities.',
                  'Organizing imams, muezzins, and khutbah services.',
                  'Supporting religious programs and outreach.',
                ],
        ),
        _PwfContentSection(
          heading: isAr ? 'إدارة الأوقاف' : 'Awqaf management',
          body: isAr
              ? 'تشمل إدارة الأوقاف توثيق الأصول الوقفية وتنميتها واستثمارها وفق الضوابط الشرعية والقانونية، مع تعزيز الشفافية عبر الأنظمة الرقمية والخرائط.'
              : 'Awqaf management includes documenting, developing, and investing waqf assets under Sharia and legal controls, with enhanced transparency through digital systems and maps.',
        ),
      ],
      primaryActionLabel: isAr ? 'المشاريع' : 'Projects',
      primaryActionPath: '/projects',
    );
  }
}

class PwfProjectsWebScreen extends ConsumerWidget {
  const PwfProjectsWebScreen({super.key, required this.unitSlug});
  final String unitSlug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAr =
        Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';
    return _PwfCmsOrFallbackPage(
      unitSlug: unitSlug,
      pageSlug: 'projects',
      title: isAr ? 'المشاريع' : 'Projects',
      subtitle: isAr
          ? 'مبادرات الوزارة ومشاريع التطوير والاستدامة'
          : 'Ministry initiatives and sustainability projects',
      sections: [
        _PwfContentSection(
          heading: isAr ? 'محاور' : 'Tracks',
          bullets: isAr
              ? const [
                  'تحسين كفاءة تشغيل المساجد وترشيد الاستهلاك.',
                  'مشاريع الطاقة الشمسية للأوقاف والمساجد (وقف شمسي).',
                  'رقمنة خدمات الأوقاف وربطها بالخرائط (GIS).',
                ]
              : const [
                  'Improving mosque operations and energy efficiency.',
                  'Solar initiatives for mosques and awqaf (Solar Waqf).',
                  'Digitizing awqaf services with GIS integration.',
                ],
        ),
        _PwfContentSection(
          heading: isAr ? 'قريبًا' : 'Coming soon',
          body: isAr
              ? 'سيتم ربط هذه الصفحة لاحقًا بقاعدة بيانات المشاريع مع إمكانية التصفية حسب المحافظة والمديرية.'
              : 'This page will be connected to the Projects database with filtering by governorate and directorate.',
        ),
      ],
      primaryActionLabel: isAr ? 'بوابة الخدمات' : 'Services portal',
      primaryActionPath: '/services',
    );
  }
}

class PwfServicesWebScreen extends ConsumerWidget {
  const PwfServicesWebScreen({super.key, required this.unitSlug});
  final String unitSlug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAr =
        Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';
    return _PwfCmsOrFallbackPage(
      unitSlug: unitSlug,
      pageSlug: 'services',
      title: isAr ? 'الخدمات' : 'Services',
      subtitle: isAr
          ? 'الخدمات المقدمة للمواطنين والمؤسسات'
          : 'Services for citizens and institutions',
      sections: [
        _PwfContentSection(
          heading: isAr ? 'خدمات عامة' : 'General services',
          bullets: isAr
              ? const [
                  'إرشادات وإعلانات وتعليمات رسمية.',
                  'شؤون الحج والعمرة.',
                  'خدمات المساجد والخطابة والوعظ.',
                ]
              : const [
                  'Official guidance, announcements, and circulars.',
                  'Hajj & Umrah services.',
                  'Mosque-related services and religious guidance.',
                ],
        ),
        _PwfContentSection(
          heading: isAr ? 'الخدمات الإلكترونية' : 'E-Services',
          body: isAr
              ? 'توفر الوزارة مجموعة من الخدمات الرقمية لتسهيل الإجراءات والطلبات. سيتم توسيعها تدريجيًا ضمن منصة PalWakf.'
              : 'The ministry provides digital services to simplify requests and procedures, expanding gradually within the PalWakf platform.',
        ),
      ],
      primaryActionLabel: isAr ? 'الخدمات الإلكترونية' : 'E-Services',
      primaryActionPath: '/eservices',
    );
  }
}

class PwfEServicesWebScreen extends ConsumerWidget {
  const PwfEServicesWebScreen({super.key, required this.unitSlug});
  final String unitSlug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAr =
        Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';
    return _PwfCmsOrFallbackPage(
      unitSlug: unitSlug,
      pageSlug: 'eservices',
      title: isAr ? 'الخدمات الإلكترونية' : 'E-Services',
      subtitle: isAr
          ? 'بوابة الخدمات الرقمية وتكامل الأنظمة'
          : 'Digital services portal and system integration',
      sections: [
        _PwfContentSection(
          heading: isAr ? 'منصات' : 'Platforms',
          bullets: isAr
              ? const [
                  'مستكشف الوقف (GIS) للبحث والاستعلام.',
                  'إدارة الأخبار والإعلانات والأنشطة.',
                  'خدمات النماذج والطلبات (قريبًا).',
                ]
              : const [
                  'Waqf Explorer (GIS) for search and inquiry.',
                  'News/announcements/activities management.',
                  'Forms and request services (coming soon).',
                ],
        ),
      ],
      primaryActionLabel: isAr ? 'مستكشف الوقف' : 'Waqf Explorer',
      primaryActionPath: '/systems',
    );
  }
}

class PwfSocialServicesWebScreen extends ConsumerWidget {
  const PwfSocialServicesWebScreen({super.key, required this.unitSlug});
  final String unitSlug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAr =
        Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';
    return _PwfCmsOrFallbackPage(
      unitSlug: unitSlug,
      pageSlug: 'social-services',
      title: isAr ? 'الخدمات الاجتماعية' : 'Social Services',
      subtitle: isAr
          ? 'برامج الدعم الاجتماعي والزكاة والصدقات'
          : 'Zakat, charity, and social support programs',
      sections: [
        _PwfContentSection(
          heading: isAr ? 'مجالات' : 'Areas',
          bullets: isAr
              ? const [
                  'برامج الزكاة والصدقات والإغاثة.',
                  'دعم الأسر المحتاجة عبر اللجان المعتمدة.',
                  'شراكات مجتمعية لتعزيز الأثر.',
                ]
              : const [
                  'Zakat, charity, and relief programs.',
                  'Supporting families through approved committees.',
                  'Community partnerships to maximize impact.',
                ],
        ),
      ],
      primaryActionLabel: isAr ? 'تواصل معنا' : 'Contact',
      primaryActionPath: '/contact',
    );
  }
}

class PwfContactWebScreen extends ConsumerWidget {
  const PwfContactWebScreen({super.key, required this.unitSlug});
  final String unitSlug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAr =
        Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';
    return _PwfCmsOrFallbackPage(
      unitSlug: unitSlug,
      pageSlug: 'contact',
      title: isAr ? 'اتصل بنا' : 'Contact',
      subtitle: isAr
          ? 'بيانات التواصل الرسمية ونموذج الرسائل'
          : 'Official contacts and message form',
      sections: [
        _PwfContentSection(
          heading: isAr ? 'بيانات التواصل' : 'Contact details',
          body: isAr
              ? 'رام الله - فلسطين - شارع الإرسال - مجمع الوزارات\nهاتف: +970-2-2406340\nبريد: info@awqaf.ps'
              : 'Ramallah - Palestine - Al-Irsal Street - Government Complex\nPhone: +970-2-2406340\nEmail: info@awqaf.ps',
        ),
        _PwfContentSection(
          heading: isAr ? 'رسالة' : 'Message',
          body: isAr
              ? 'سيتم تفعيل نموذج تواصل وربطه بالخدمات البريدية/المنصة في مرحلة لاحقة.'
              : 'A contact form will be enabled and linked to email/platform services in a later phase.',
        ),
      ],
      primaryActionLabel: isAr ? 'العودة للرئيسية' : 'Back to Home',
      primaryActionPath: '/home',
    );
  }
}

class PwfFormerMinistersWebScreen extends ConsumerWidget {
  const PwfFormerMinistersWebScreen({super.key, required this.unitSlug});
  final String unitSlug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAr =
        Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';
    return _PwfCmsOrFallbackPage(
      unitSlug: unitSlug,
      pageSlug: 'former-ministers',
      title: isAr ? 'وزراء سابقون' : 'Former Ministers',
      subtitle: isAr
          ? 'توثيق تعاقب الوزراء وقيادات الوزارة عبر السنوات'
          : 'A record of former ministers and ministry leadership over the years',
      sections: [
        _PwfContentSection(
          heading: isAr ? 'لماذا هذه الصفحة؟' : 'Why this page?',
          body: isAr
              ? 'تهدف هذه الصفحة إلى حفظ السجل المؤسسي وتكريم الجهود السابقة. سيتم استكمال القائمة وتحديثها رسميًا عبر نظام إدارة المحتوى (CMS) ضمن المنصة.'
              : 'This page preserves institutional memory and honors previous efforts. The list will be completed and officially maintained via the platform CMS.',
        ),
        _PwfContentSection(
          heading: isAr ? 'إرشادات التحديث' : 'Update guidance',
          bullets: isAr
              ? const [
                  'أضِف كل وزير مع مدة توليه (من/إلى).',
                  'يمكن إضافة سيرة مختصرة وروابط قرارات/إنجازات.',
                  'عند توفر بيانات رسمية سيتم عرضها تلقائيًا من قاعدة البيانات.',
                ]
              : const [
                  'Add each minister with tenure (from/to).',
                  'Optionally include a short bio and key decisions/achievements.',
                  'Once official data exists, it will be loaded automatically from the database.',
                ],
        ),
        _PwfContentSection(
          heading: isAr ? 'قائمة أولية' : 'Initial list',
          body: isAr
              ? 'سيتم إدراج الأسماء الرسمية هنا عبر CMS. (حالياً: لا توجد بيانات مُدخلة)'
              : 'Official names will appear here via CMS. (Currently: no entries)',
        ),
      ],
      primaryActionLabel: isAr ? 'عن الوزارة' : 'About',
      primaryActionPath: '/about',
    );
  }
}

/// Wraps a content page with CMS (DB) override.
///
/// If a CMS page exists in `public.site_pages`, it will be rendered.
/// Otherwise, the fallback (hard-coded) content is shown.
class _PwfCmsOrFallbackPage extends ConsumerWidget {
  const _PwfCmsOrFallbackPage({
    required this.unitSlug,
    required this.pageSlug,
    required this.title,
    required this.subtitle,
    required this.sections,
    required this.primaryActionLabel,
    required this.primaryActionPath,
  });

  final String unitSlug;
  final String pageSlug;
  final String title;
  final String subtitle;
  final List<_PwfContentSection> sections;
  final String primaryActionLabel;
  final String primaryActionPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageAsync = ref.watch(
      pwfSitePageProvider(PwfSitePageParam(unitSlug: unitSlug, slug: pageSlug)),
    );

    return pageAsync.when(
      loading: () {
        // Fail-open: show fallback while loading (no skeleton jitter on public pages).
        return _PwfContentPage(
          unitSlug: unitSlug,
          title: title,
          subtitle: subtitle,
          sections: sections,
          primaryActionLabel: primaryActionLabel,
          primaryActionPath: primaryActionPath,
        );
      },
      error: (_, __) {
        // Fail-open: always show fallback.
        return _PwfContentPage(
          unitSlug: unitSlug,
          title: title,
          subtitle: subtitle,
          sections: sections,
          primaryActionLabel: primaryActionLabel,
          primaryActionPath: primaryActionPath,
        );
      },
      data: (page) {
        if (page == null) {
          return _PwfContentPage(
            unitSlug: unitSlug,
            title: title,
            subtitle: subtitle,
            sections: sections,
            primaryActionLabel: primaryActionLabel,
            primaryActionPath: primaryActionPath,
          );
        }

        final isAr =
            Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';
        final cmsTitle = isAr ? page.titleAr : page.titleEn;
        final cmsSubtitle = isAr ? page.subtitleAr : page.subtitleEn;
        final cmsBody = isAr ? page.bodyAr : page.bodyEn;
        final cmsSections = _pwfParseCmsBodyToSections(cmsBody);

        return _PwfContentPage(
          unitSlug: unitSlug,
          title: cmsTitle.trim().isEmpty ? title : cmsTitle,
          subtitle: cmsSubtitle.trim().isEmpty ? subtitle : cmsSubtitle,
          sections: cmsSections.isEmpty ? sections : cmsSections,
          primaryActionLabel: primaryActionLabel,
          primaryActionPath: primaryActionPath,
        );
      },
    );
  }
}

List<_PwfContentSection> _pwfParseCmsBodyToSections(String body) {
  final text = body.trim();
  if (text.isEmpty) return const [];

  final lines = text.split('\n');
  final sections = <_PwfContentSection>[];

  String currentHeading = '';
  final paragraphBuffer = <String>[];
  final bullets = <String>[];

  void flush() {
    final p = paragraphBuffer.join('\n').trim();
    if (currentHeading.isEmpty && p.isEmpty && bullets.isEmpty) return;
    sections.add(
      _PwfContentSection(
        heading: currentHeading,
        body: p.isEmpty ? null : p,
        bullets: bullets.isEmpty ? null : List<String>.from(bullets),
      ),
    );
    paragraphBuffer.clear();
    bullets.clear();
  }

  for (final raw in lines) {
    final line = raw.trimRight();
    if (line.trim().startsWith('## ')) {
      flush();
      currentHeading = line.trim().substring(3).trim();
      continue;
    }
    if (line.trim().startsWith('- ')) {
      bullets.add(line.trim().substring(2).trim());
      continue;
    }
    paragraphBuffer.add(line);
  }
  flush();

  // If the CMS body has no headings at all, ensure one section.
  if (sections.length == 1 && sections.first.heading.trim().isEmpty) {
    return sections;
  }
  return sections;
}

// ----------------- Shared building blocks -----------------

class _PwfContentPage extends ConsumerWidget {
  const _PwfContentPage({
    required this.unitSlug,
    required this.title,
    required this.subtitle,
    required this.sections,
    required this.primaryActionLabel,
    required this.primaryActionPath,
  });

  final String unitSlug;
  final String title;
  final String subtitle;
  final List<_PwfContentSection> sections;
  final String primaryActionLabel;
  final String primaryActionPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeKey = ref.watch(pwfUiPrefsProvider).themeKey;
    final t = PwfThemeTokens.forKey(themeKey);

    return PwfWebPageScaffold(
      unitSlug: unitSlug,
      title: title,
      showTitleSection: true,
      child: PwfSectionContainer(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
          decoration: BoxDecoration(
            color: t.cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: t.cardBorder),
            boxShadow: t.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: t.mutedText,
                  height: 1.7,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              for (final s in sections) ...[
                _SectionBlock(section: s),
                const SizedBox(height: 14),
              ],
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _ActionButton(
                    label: primaryActionLabel,
                    filled: true,
                    onTap: () => context.go(primaryActionPath),
                  ),
                  _ActionButton(
                    label:
                        Localizations.localeOf(
                              context,
                            ).languageCode.toLowerCase() ==
                            'ar'
                        ? 'آخر الأخبار'
                        : 'Latest News',
                    filled: false,
                    onTap: () => context.go('/home/news'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PwfContentSection {
  const _PwfContentSection({required this.heading, this.body, this.bullets});

  final String heading;
  final String? body;
  final List<String>? bullets;
}

class _SectionBlock extends ConsumerWidget {
  const _SectionBlock({required this.section});
  final _PwfContentSection section;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeKey = ref.watch(pwfUiPrefsProvider).themeKey;
    final t = PwfThemeTokens.forKey(themeKey);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          section.heading,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        if (section.body != null && section.body!.trim().isNotEmpty)
          Text(
            section.body!,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(height: 1.75),
          ),
        if (section.bullets != null && section.bullets!.isNotEmpty) ...[
          const SizedBox(height: 6),
          for (final b in section.bullets!)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 7),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: t.accent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      b,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(height: 1.7),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}

class _ActionButton extends ConsumerStatefulWidget {
  const _ActionButton({
    required this.label,
    required this.onTap,
    required this.filled,
  });

  final String label;
  final VoidCallback onTap;
  final bool filled;

  @override
  ConsumerState<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends ConsumerState<_ActionButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final themeKey = ref.watch(pwfUiPrefsProvider).themeKey;
    final t = PwfThemeTokens.forKey(themeKey);

    final bg = widget.filled
        ? (_hover ? t.accentHover : t.accent)
        : (_hover ? t.surfaceHover : t.surface);

    final fg = widget.filled ? t.onAccent : t.text;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.filled ? Colors.transparent : t.border,
            ),
          ),
          child: Text(
            widget.label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
