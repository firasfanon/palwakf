part of 'pwf_content_pages.dart';

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
          ? 'تعريف مؤسسي موجز بدور وزارة الأوقاف والشؤون الدينية ونطاق عملها العام.'
          : 'A concise institutional overview of the Ministry of Awqaf and Religious Affairs and its public mandate.',
      sections: [
        _PwfContentSection(
          heading: isAr ? 'نبذة عن الوزارة' : 'Overview',
          body: isAr
              ? 'وزارة الأوقاف والشؤون الدينية في دولة فلسطين هي الجهة المختصة بمتابعة شؤون الأوقاف والمساجد والخدمات الدينية العامة ضمن إطار قانوني ومؤسسي منظم. تعمل الوزارة من خلال وحداتها ومديرياتها على حماية المال الوقفي، وتنظيم شؤون المساجد، وتطوير الخدمات المقدمة للجمهور، وتعزيز الإدارة الرشيدة والشفافية في إدارة مواردها ومجالات عملها.'
              : 'The Ministry of Awqaf and Religious Affairs in the State of Palestine oversees awqaf, mosques, and public religious services within a regulated institutional framework. Through its departments and directorates, the ministry works to protect awqaf assets, organize mosque affairs, improve public services, and strengthen governance and transparency.',
        ),
        _PwfContentSection(
          heading: isAr ? 'مجالات العمل المؤسسي' : 'Institutional work areas',
          bullets: isAr
              ? const [
                  'حماية الأوقاف وتنظيم بياناتها ومتابعة استثمارها بما يحقق المنفعة العامة.',
                  'خدمة المساجد والمصليات ومتابعة احتياجاتها الإدارية والفنية.',
                  'تنظيم الخطاب الديني والوعظ والإرشاد والتعليم الشرعي ضمن الأطر الرسمية.',
                  'تطوير الخدمات العامة والإلكترونية وربطها بالمديريات والوحدات المختصة.',
                  'تعزيز التوثيق والأرشفة والرقابة المؤسسية على الإجراءات والقرارات.',
                ]
              : const [
                  'Protect awqaf assets, organize their records, and support their public benefit.',
                  'Support mosques and prayer spaces through administrative and operational follow-up.',
                  'Organize religious guidance, preaching, and related educational work through official channels.',
                  'Improve public and digital services with directorate and unit integration.',
                  'Strengthen documentation, archiving, and institutional oversight.',
                ],
        ),
        _PwfContentSection(
          heading: isAr ? 'التحول الرقمي' : 'Digital transformation',
          body: isAr
              ? 'تأتي منصة PalWakf كمسار رقمي تدريجي لتوحيد البيانات والخدمات والصفحات العامة والأنظمة التشغيلية للوزارة، مع الحفاظ على الفصل بين المحتوى العام، والخدمات، والأوقاف، والمهام، والقضايا، والأنظمة المساندة.'
              : 'PalWakf provides a gradual digital track to unify data, public pages, services, and operational systems while preserving clear boundaries between public content, services, awqaf operations, tasks, legal affairs, and supporting systems.',
        ),
        _PwfContentSection(
          heading: isAr ? 'المديريات والوحدات' : 'Directorates and units',
          body: isAr
              ? 'تعرض المنصة صفحات الوزارة والمديريات ضمن نفس الهوية البصرية، مع احترام نطاق كل وحدة تنظيمية ومصدر بياناتها وصلاحياتها. لذلك تبقى الصفحة العامة مرجعًا مركزيًا، بينما تحتفظ صفحات الوحدات بسياقها المحلي عند النشر والإدارة.'
              : 'The platform presents ministry and directorate pages under one visual identity while respecting each organizational unit, data scope, and permissions. The public homepage remains the central reference, while unit pages keep their local publishing context.',
        ),
      ],
      primaryActionLabel: isAr ? 'الرؤية والرسالة' : 'Vision & Mission',
      primaryActionPath: '/vision-mission',
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
                  'تنظيم إدارة الأوقاف وتوثيقها وتحديث بياناتها.',
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
          ? 'إطار مؤسسي يوضح اتجاه العمل والقيم الحاكمة لتطوير الخدمات والأوقاف.'
          : 'An institutional framework for service development, awqaf stewardship, and governing values.',
      sections: [
        _PwfContentSection(
          heading: isAr ? 'الرؤية' : 'Vision',
          body: isAr
              ? 'أوقاف مصونة ومستدامة، وخدمات دينية ومؤسسية موثوقة، ومنظومة رقمية تساعد الوزارة والمديريات على خدمة المجتمع بكفاءة وشفافية.'
              : 'Protected and sustainable awqaf, trusted religious and institutional services, and a digital ecosystem that helps the ministry and directorates serve society efficiently and transparently.',
        ),
        _PwfContentSection(
          heading: isAr ? 'الرسالة' : 'Mission',
          body: isAr
              ? 'إدارة الأوقاف وشؤون المساجد والخدمات الدينية العامة وفق قواعد الإدارة الرشيدة والشفافية، وتطوير قنوات الخدمة والتوثيق والرقابة بما يسهّل وصول الجمهور إلى الخدمات ويحفظ المال الوقفي والهوية المؤسسية.'
              : 'Manage awqaf, mosque affairs, and public religious services through governance and transparency, while improving service channels, documentation, and oversight to preserve awqaf assets and institutional identity.',
        ),
        _PwfContentSection(
          heading: isAr ? 'محاور العمل' : 'Work pillars',
          bullets: isAr
              ? const [
                  'تنظيم بيانات الأوقاف وربطها بالملفات المؤسسية الرسمية.',
                  'تطوير الخدمات العامة والإلكترونية مع تتبع واضح للطلبات والمعاملات.',
                  'تعزيز إدارة المحتوى الرسمي دون خلط بين الأخبار والإعلانات والأنشطة والفعاليات.',
                  'رفع جودة التنسيق بين الوزارة والمديريات ضمن نظام صلاحيات واضح.',
                  'تفعيل الأرشفة والتوثيق وربطها بالمراجع الرسمية والمساعد المعرفي.',
                ]
              : const [
                  'Organize awqaf data and connect it with official institutional records.',
                  'Improve public and electronic services with clear request tracking.',
                  'Manage official content without mixing news, announcements, activities, and events.',
                  'Strengthen ministry-directorate coordination through clear permissions.',
                  'Activate documentation and archiving linked to official references and the knowledge assistant.',
                ],
        ),
        _PwfContentSection(
          heading: isAr ? 'القيم الحاكمة' : 'Governing values',
          bullets: isAr
              ? const [
                  'الأمانة في إدارة الوقف والموارد العامة.',
                  'الشفافية في الإجراءات والخدمات والنشر.',
                  'العدالة في الوصول إلى الخدمات والتعامل مع الجمهور.',
                  'المسؤولية المؤسسية والتدقيق القابل للتتبع.',
                  'الاحترافية في الإدارة والتحول الرقمي.',
                ]
              : const [
                  'Trust in managing awqaf and public resources.',
                  'Transparency in procedures, services, and publishing.',
                  'Fair access to services and public interaction.',
                  'Institutional accountability with traceable audit records.',
                  'Professional administration and digital transformation.',
                ],
        ),
      ],
      primaryActionLabel: isAr ? 'عن الوزارة' : 'About the Ministry',
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
    final unitsAsync = ref.watch(orgUnitsListProvider);

    return PwfWebPageScaffold(
      unitSlug: unitSlug,
      title: isAr ? 'الهيكل التنظيمي' : 'Organizational Structure',
      showTitleSection: true,
      child: PwfSectionContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PwfPublicIntroCard(
              title: isAr
                  ? 'الهيكل التنظيمي للوزارة'
                  : 'Ministry organizational structure',
              subtitle: isAr
                  ? 'عرض منظم للوحدات والمديريات التابعة للوزارة.'
                  : 'A structured view of the ministry units and directorates.',
              icon: Icons.account_tree_outlined,
              unitSlug: unitSlug,
              note: isAr
                  ? 'تعرض هذه الصفحة الوحدات والمديريات المتاحة للزائر ضمن ترتيب واضح.'
                  : 'This page presents the available units and directorates in a clear structure.',
            ),
            const SizedBox(height: 18),
            unitsAsync.when(
              loading: () => const _PwfUnitsLoadingState(),
              error: (_, __) => _PwfSimpleNoticeCard(
                title: isAr
                    ? 'تعذر تحميل الوحدات التنظيمية'
                    : 'Unable to load organizational units',
                body: isAr
                    ? 'تعذر تحميل بيانات الوحدات التنظيمية الآن. يمكنك المحاولة لاحقًا أو الرجوع إلى الصفحة الرئيسية.'
                    : 'Organizational units could not be loaded right now. Please try again later.',
              ),
              data: (rows) {
                final activeRows = rows
                    .where((row) {
                      final status = (row['status'] ?? '')
                          .toString()
                          .trim()
                          .toLowerCase();
                      return status.isEmpty ||
                          status == 'active' ||
                          status == 'published';
                    })
                    .toList(growable: false);
                final directorates = activeRows.where((row) {
                  final level = (row['unit_level'] ?? row['type'] ?? '')
                      .toString()
                      .toLowerCase();
                  return level.contains('director') || level.contains('مديرية');
                }).length;
                final departments = activeRows.where((row) {
                  final level = (row['unit_level'] ?? row['type'] ?? '')
                      .toString()
                      .toLowerCase();
                  return level.contains('department') ||
                      level.contains('إدارة');
                }).length;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    PwfStatsWrap(
                      items: [
                        PwfStatItem(
                          label: isAr ? 'إجمالي الوحدات' : 'Total units',
                          value: activeRows.length,
                          icon: Icons.apartment_rounded,
                        ),
                        PwfStatItem(
                          label: isAr ? 'المديريات' : 'Directorates',
                          value: directorates,
                          icon: Icons.location_city_rounded,
                        ),
                        PwfStatItem(
                          label: isAr ? 'الإدارات' : 'Departments',
                          value: departments,
                          icon: Icons.workspaces_outline,
                        ),
                        PwfStatItem(
                          label: isAr
                              ? 'الوحدات ذات الصفحات'
                              : 'Units with pages',
                          value: activeRows
                              .where(
                                (row) => (row['slug'] ?? '')
                                    .toString()
                                    .trim()
                                    .isNotEmpty,
                              )
                              .length,
                          icon: Icons.web_rounded,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _PwfUnitsGrid(rows: activeRows),
                  ],
                );
              },
            ),
          ],
        ),
      ),
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
          heading: isAr ? 'الوصول والمتابعة' : 'Access and follow-up',
          body: isAr
              ? 'تعرض هذه الصفحة الإطار العام للمشاريع الحالية، ويمكن تتبع المشاريع والأنظمة ذات الصلة عبر بوابة الخدمات ومحتوى المنصة العام.'
              : 'This page presents the current project framework, while project-related systems and updates remain accessible through the public services gateway and platform content.',
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
    final pageAsync = ref.watch(
      pwfSitePageProvider(
        PwfSitePageParam(unitSlug: unitSlug, slug: 'services'),
      ),
    );

    final fallbackTitle = isAr ? 'الخدمات' : 'Services';
    final fallbackSubtitle = isAr
        ? 'مدخل موحد إلى الخدمات العامة والخدمات الإلكترونية المرتبطة بوزارة الأوقاف والشؤون الدينية.'
        : 'A unified gateway to public and digital services of the Ministry of Awqaf and Religious Affairs.';

    final page = pageAsync.valueOrNull;
    final cmsTitle = page == null
        ? fallbackTitle
        : _pickLocalized(
            context,
            ar: page.titleAr,
            en: page.titleEn,
            fallbackAr: fallbackTitle,
            fallbackEn: fallbackTitle,
          );
    final cmsSubtitle = page == null
        ? fallbackSubtitle
        : _pickLocalized(
            context,
            ar: page.subtitleAr,
            en: page.subtitleEn,
            fallbackAr: fallbackSubtitle,
            fallbackEn: fallbackSubtitle,
          );
    final cmsBody = page == null
        ? ''
        : _pickLocalized(
            context,
            ar: page.bodyAr,
            en: page.bodyEn,
            fallbackAr: '',
            fallbackEn: '',
          );
    final cmsSections = _pwfParseCmsBodyToSections(cmsBody);

    return PwfWebPageScaffold(
      unitSlug: unitSlug,
      title: cmsTitle,
      showTitleSection: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PwfSectionContainer(
            child: PwfPublicIntroCard(
              title: cmsTitle,
              subtitle: cmsSubtitle,
              icon: Icons.layers_rounded,
              unitSlug: unitSlug,
              note: isAr
                  ? 'جميع الروابط في هذه الصفحة مرتبطة بمسارات عامة حقيقية داخل المنصة أو بروابط خارجية معتمدة.'
                  : 'All links on this page point to real public routes or approved external services.',
            ),
          ),
          if (cmsSections.isNotEmpty)
            PwfSectionContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < cmsSections.length; i++) ...[
                    _SectionBlock(section: cmsSections[i]),
                    if (i != cmsSections.length - 1) const SizedBox(height: 14),
                  ],
                ],
              ),
            ),
          PwfSectionContainer(
            child: _PwfPublicRequestEntrySection(unitSlug: unitSlug),
          ),
          PwfPublicServicesCatalogSection(
            unitSlug: unitSlug,
            showEmptyState: true,
          ),
          PwfQuickServicesSection(unitSlug: unitSlug),
          PwfEServicesPortalSection(unitSlug: unitSlug),
          PwfImportantLinksSection(unitSlug: unitSlug),
        ],
      ),
    );
  }
}

class _PwfPublicRequestEntrySection extends StatelessWidget {
  const _PwfPublicRequestEntrySection({required this.unitSlug});

  final String unitSlug;

  String _unitRoute(String suffix) {
    final base = PwfUnitSlugRegistry.publicBasePathFor(unitSlug);
    if (base == '/home' && !suffix.startsWith('/home')) {
      return suffix;
    }
    return '$base$suffix';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 760;
        final intro = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFB22222).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'الطلبات والنماذج',
                style: TextStyle(
                  color: Color(0xFFB22222),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'مدخل تقديم الطلبات وتتبعها',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            const Text(
              'مسار عام يربط دليل الخدمات بالنماذج ورقم المتابعة بطريقة مبسطة للمستخدم.',
              style: TextStyle(color: Color(0xFF64748B), height: 1.65),
            ),
          ],
        );
        final actionButtons = [
          FilledButton.icon(
            onPressed: () => context.go(_unitRoute('/services/request')),
            icon: const Icon(Icons.assignment_outlined),
            label: const Text(
              'تقديم طلب خدمة',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF0B3A70),
            ),
          ),
          OutlinedButton.icon(
            onPressed: () => context.go(_unitRoute('/services/track')),
            icon: const Icon(Icons.manage_search_outlined),
            label: const Text(
              'تتبع طلب',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ];
        final actions = compact
            ? PwfVisualActionStack(children: actionButtons)
            : Wrap(spacing: 10, runSpacing: 10, children: actionButtons);
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: compact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [intro, const SizedBox(height: 16), actions],
                )
              : Row(
                  children: [
                    Expanded(child: intro),
                    const SizedBox(width: 18),
                    actions,
                  ],
                ),
        );
      },
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
    final pageAsync = ref.watch(
      pwfSitePageProvider(
        PwfSitePageParam(unitSlug: unitSlug, slug: 'eservices'),
      ),
    );

    final fallbackTitle = isAr ? 'الخدمات الإلكترونية' : 'E-Services';
    final fallbackSubtitle = isAr
        ? 'وصول مباشر إلى الخدمات الإلكترونية العامة المتاحة حاليًا عبر المنصة.'
        : 'Direct access to the public digital services currently available on the platform.';

    final page = pageAsync.valueOrNull;
    final cmsTitle = page == null
        ? fallbackTitle
        : _pickLocalized(
            context,
            ar: page.titleAr,
            en: page.titleEn,
            fallbackAr: fallbackTitle,
            fallbackEn: fallbackTitle,
          );
    final cmsSubtitle = page == null
        ? fallbackSubtitle
        : _pickLocalized(
            context,
            ar: page.subtitleAr,
            en: page.subtitleEn,
            fallbackAr: fallbackSubtitle,
            fallbackEn: fallbackSubtitle,
          );
    final cmsBody = page == null
        ? ''
        : _pickLocalized(
            context,
            ar: page.bodyAr,
            en: page.bodyEn,
            fallbackAr: '',
            fallbackEn: '',
          );
    final cmsSections = _pwfParseCmsBodyToSections(cmsBody);

    return PwfWebPageScaffold(
      unitSlug: unitSlug,
      title: cmsTitle,
      showTitleSection: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PwfSectionContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PwfPublicIntroCard(
                  title: cmsTitle,
                  subtitle: cmsSubtitle,
                  icon: Icons.computer_rounded,
                  unitSlug: unitSlug,
                  note: isAr
                      ? 'تُقرأ هذه الصفحة من نفس منظومة الإعدادات التي تغذي الصفحة الرئيسية، بحيث يبقى الربط والهوية موحدين.'
                      : 'This page uses the same settings stack that powers the homepage to keep identity and routing consistent.',
                ),
                if (cmsSections.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  for (int i = 0; i < cmsSections.length; i++) ...[
                    _SectionBlock(section: cmsSections[i]),
                    if (i != cmsSections.length - 1) const SizedBox(height: 14),
                  ],
                ],
                const SizedBox(height: 18),
                const _PwfQuickRouteChips(),
              ],
            ),
          ),
          PwfEServicesPortalSection(unitSlug: unitSlug),
          PwfQuickServicesSection(unitSlug: unitSlug),
        ],
      ),
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
      title: isAr ? 'الاجتماعيات' : 'Social Posts',
      subtitle: isAr
          ? 'تهاني وتعازي ومناسبات اجتماعية رسمية ضمن المركز الإعلامي'
          : 'Official congratulations, condolences, and social occasions under the media center',
      sections: [
        _PwfContentSection(
          heading: isAr ? 'تصنيفات الاجتماعيات' : 'Social post categories',
          bullets: isAr
              ? const [
                  'تهاني رسمية مرتبطة بالمناسبات العامة والمؤسسية.',
                  'تعازي ومواساة بصياغة حكومية منضبطة.',
                  'مناسبات اجتماعية رسمية مرتبطة بالوزارة أو الوحدات.',
                ]
              : const [
                  'Official congratulations related to public and institutional occasions.',
                  'Condolences with governed public wording.',
                  'Official social occasions related to the ministry or units.',
                ],
        ),
      ],
      primaryActionLabel: isAr ? 'فتح المركز الإعلامي' : 'Open media center',
      primaryActionPath: '/media-center',
    );
  }
}

class PwfContactWebScreen extends ConsumerStatefulWidget {
  const PwfContactWebScreen({super.key, required this.unitSlug});
  final String unitSlug;

  @override
  ConsumerState<PwfContactWebScreen> createState() =>
      _PwfContactWebScreenState();
}

class _PwfContactWebScreenState extends ConsumerState<PwfContactWebScreen> {
  final _nameCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _subjectCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAr =
        Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';
    final settings =
        ref
            .watch(publicFooterSettingsProvider(widget.unitSlug))
            .maybeWhen(data: (value) => value, orElse: () => null) ??
        _pwfFallbackFooterSettings(widget.unitSlug);
    final page = ref
        .watch(
          pwfSitePageProvider(
            PwfSitePageParam(unitSlug: widget.unitSlug, slug: 'contact'),
          ),
        )
        .valueOrNull;

    final email = (settings.contactEmail ?? '').trim();
    final phone = (settings.contactPhone ?? '').trim();
    final address = (settings.contactAddress ?? '').trim();
    final title = _cmsPreferredValue(
      isAr: isAr,
      ar: page?.titleAr,
      en: page?.titleEn,
      fallbackAr: 'اتصل بنا',
      fallbackEn: 'Contact us',
    );
    final isHomeContact = widget.unitSlug.trim().toLowerCase() == 'home';
    final subtitle = _cmsPreferredValue(
      isAr: isAr,
      ar: page?.subtitleAr,
      en: page?.subtitleEn,
      fallbackAr: isHomeContact
          ? 'استخدم القنوات التالية للتواصل مع الوزارة أو الانتقال إلى نظام الشكاوى والمتابعة.'
          : 'استخدم القنوات التالية للتواصل مع الوحدة المختارة أو الانتقال إلى نظام الشكاوى والمتابعة.',
      fallbackEn: isHomeContact
          ? 'Use the following channels to contact the ministry or move to the complaints and follow-up service.'
          : 'Use the following channels to contact the selected unit or move to the complaints and follow-up service.',
    );
    final introBody = _cmsPreferredBody(
      isAr: isAr,
      ar: page?.bodyAr,
      en: page?.bodyEn,
      fallbackAr:
          'يمكنك استخدام هذه الصفحة للوصول إلى قنوات التواصل الرسمية المعتمدة حسب نطاق الصفحة الحالي، أو الانتقال إلى نظام الشكاوى والمتابعة عند الحاجة إلى متابعة رسمية.',
      fallbackEn:
          'Use this page to access the approved public contact channels for the current page scope, or move to the complaints service whenever an official follow-up is required.',
    );

    return PwfWebPageScaffold(
      unitSlug: widget.unitSlug,
      title: title,
      showTitleSection: true,
      child: PwfSectionContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PwfPublicIntroCard(
              title: title,
              subtitle: subtitle,
              icon: Icons.contact_phone_rounded,
              unitSlug: widget.unitSlug,
            ),
            if (introBody.trim().isNotEmpty) ...[
              const SizedBox(height: 18),
              PwfSurfaceCard(
                child: Text(
                  introBody,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(height: 1.8),
                ),
              ),
            ],
            const SizedBox(height: 18),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _PwfContactInfoCard(
                  title: isAr ? 'الهاتف' : 'Phone',
                  value: phone.isEmpty ? '—' : phone,
                  icon: Icons.phone_rounded,
                ),
                _PwfContactInfoCard(
                  title: isAr ? 'البريد الإلكتروني' : 'Email',
                  value: email.isEmpty ? '—' : email,
                  icon: Icons.email_rounded,
                ),
                _PwfContactInfoCard(
                  title: isAr ? 'العنوان' : 'Address',
                  value: address.isEmpty ? '—' : address,
                  icon: Icons.location_on_outlined,
                ),
              ],
            ),
            const SizedBox(height: 18),
            PwfVisualActionStack(
              children: [
                if (phone.isNotEmpty)
                  _PwfPrimaryLinkButton(
                    label: isAr ? 'اتصال هاتفي' : 'Call',
                    onTap: () => launchUrlString('tel:$phone'),
                  ),
                if (email.isNotEmpty)
                  _PwfSecondaryLinkButton(
                    label: isAr ? 'إرسال بريد' : 'Send email',
                    onTap: () => launchUrlString('mailto:$email'),
                  ),
                _PwfSecondaryLinkButton(
                  label: isAr ? 'نظام الشكاوى' : 'Complaints service',
                  onTap: () => context.go(AppRoutes.complaints),
                ),
              ],
            ),
            const SizedBox(height: 18),
            PwfSurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    isAr ? 'إرسال رسالة مباشرة' : 'Send a direct message',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _nameCtrl,
                    decoration: InputDecoration(
                      labelText: isAr ? 'الاسم' : 'Name',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _subjectCtrl,
                    decoration: InputDecoration(
                      labelText: isAr ? 'الموضوع' : 'Subject',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _messageCtrl,
                    minLines: 4,
                    maxLines: 7,
                    decoration: InputDecoration(
                      labelText: isAr ? 'نص الرسالة' : 'Message body',
                    ),
                  ),
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _PwfPrimaryLinkButton(
                      label: isAr
                          ? 'فتح البريد الإلكتروني'
                          : 'Open email composer',
                      onTap: () {
                        final subject = Uri.encodeComponent(
                          _subjectCtrl.text.trim().isEmpty
                              ? (isAr
                                    ? 'رسالة من بوابة الوزارة'
                                    : 'Message from ministry portal')
                              : _subjectCtrl.text.trim(),
                        );
                        final body = Uri.encodeComponent(
                          [
                            if (_nameCtrl.text.trim().isNotEmpty)
                              '${isAr ? 'الاسم' : 'Name'}: ${_nameCtrl.text.trim()}',
                            '',
                            _messageCtrl.text.trim(),
                          ].join('\n'),
                        );
                        final target = email.isEmpty ? 'info@awqaf.ps' : email;
                        launchUrlString(
                          'mailto:$target?subject=$subject&body=$body',
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
    final page = ref
        .watch(
          pwfSitePageProvider(
            PwfSitePageParam(unitSlug: unitSlug, slug: 'former-ministers'),
          ),
        )
        .valueOrNull;
    final ministersAsync = ref.watch(pwfFormerMinistersProvider(unitSlug));
    final title = _cmsPreferredValue(
      isAr: isAr,
      ar: page?.titleAr,
      en: page?.titleEn,
      fallbackAr: 'الوزراء السابقون',
      fallbackEn: 'Former Ministers',
    );
    final subtitle = _cmsPreferredValue(
      isAr: isAr,
      ar: page?.subtitleAr,
      en: page?.subtitleEn,
      fallbackAr: 'توثيق تعاقب الوزراء وقيادات الوزارة عبر السنوات',
      fallbackEn:
          'A record of former ministers and ministry leadership over the years',
    );
    final introBody = _cmsPreferredBody(
      isAr: isAr,
      ar: page?.bodyAr,
      en: page?.bodyEn,
      fallbackAr:
          'توثق هذه الصفحة التسلسل التاريخي للوزراء السابقين ضمن أرشيف المنصة العام، وتُعرض فيها السجلات المعتمدة فقط بعد تدقيقها ونشرها.',
      fallbackEn:
          'This page documents the historical sequence of former ministers within the public platform archive and shows only approved records after review and publication.',
    );

    return PwfWebPageScaffold(
      unitSlug: unitSlug,
      title: title,
      showTitleSection: true,
      child: PwfSectionContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PwfPublicIntroCard(
              title: title,
              subtitle: subtitle,
              icon: Icons.history_edu_outlined,
              unitSlug: unitSlug,
            ),
            if (introBody.trim().isNotEmpty) ...[
              const SizedBox(height: 18),
              PwfSurfaceCard(
                child: Text(
                  introBody,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(height: 1.8),
                ),
              ),
            ],
            const SizedBox(height: 18),
            ministersAsync.when(
              loading: () => const _PwfUnitsLoadingState(),
              error: (error, _) => PwfSurfaceCard(
                child: Text(
                  isAr
                      ? 'تعذر قراءة السجل التاريخي: $error'
                      : 'Failed to read historical records: $error',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return PwfSurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAr
                              ? 'لا توجد سجلات منشورة حاليًا'
                              : 'No published records are available yet',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          isAr
                              ? 'يمكن استكمال السجل التاريخي من صفحة الإدارة المخصصة للوزراء السابقين، وستظهر الإدخالات هنا بعد حفظها واعتمادها.'
                              : 'The historical register can be completed from the dedicated admin page. Entries will appear here once they are saved and approved.',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(height: 1.7),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    PwfStatsWrap(
                      items: [
                        PwfStatItem(
                          label: isAr ? 'إجمالي السجلات' : 'Total records',
                          value: items.length,
                          icon: Icons.groups_2_outlined,
                        ),
                        PwfStatItem(
                          label: isAr ? 'السجلات النشطة' : 'Active records',
                          value: items.where((e) => e.isActive).length,
                          icon: Icons.verified_outlined,
                        ),
                        PwfStatItem(
                          label: isAr ? 'سجلات بتاريخ انتهاء' : 'Ended tenures',
                          value: items.where((e) => e.endDate != null).length,
                          icon: Icons.event_available_outlined,
                        ),
                        PwfStatItem(
                          label: isAr ? 'الحالي/الأحدث' : 'Current/latest',
                          value: items.where((e) => e.isCurrent).isEmpty
                              ? 0
                              : 1,
                          icon: Icons.flag_outlined,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    ...items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _PwfFormerMinisterCard(item: item, isAr: isAr),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PwfFormerMinisterCard extends StatelessWidget {
  const _PwfFormerMinisterCard({required this.item, required this.isAr});

  final PwfFormerMinister item;
  final bool isAr;

  @override
  Widget build(BuildContext context) {
    final name = _displayName(item, isAr);
    final notes = _displayNotes(item, isAr);
    final tenure = _tenureLabel(item, isAr);
    final initials = _initials(name);

    return PwfSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F0FE),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF0F4C81),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        PwfMetaBadge(
                          label: tenure,
                          icon: Icons.event_note_outlined,
                        ),
                        if (item.isCurrent)
                          const PwfMetaBadge(
                            label: 'السجل الحالي',
                            icon: Icons.flag_outlined,
                            color: Color(0xFF166534),
                            backgroundColor: Color(0xFFE8F5E9),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (notes.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              notes,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(height: 1.8),
            ),
          ],
        ],
      ),
    );
  }
}

String _displayName(PwfFormerMinister item, bool isAr) {
  final primary = (isAr ? item.fullNameAr : item.fullNameEn).trim();
  if (primary.isNotEmpty) return primary;
  final secondary = (isAr ? item.fullNameEn : item.fullNameAr).trim();
  return secondary.isEmpty ? '—' : secondary;
}

String _displayNotes(PwfFormerMinister item, bool isAr) {
  final primary = (isAr ? item.notesAr : item.notesEn).trim();
  if (primary.isNotEmpty) return primary;
  return (isAr ? item.notesEn : item.notesAr).trim();
}

String _tenureLabel(PwfFormerMinister item, bool isAr) {
  final start = item.startDate == null
      ? (isAr ? 'غير محدد' : 'Unknown')
      : pwfFormatArabicDate(item.startDate);
  final end = item.isCurrent
      ? (isAr ? 'حتى الآن' : 'Present')
      : (item.endDate == null
            ? (isAr ? 'غير محدد' : 'Unknown')
            : pwfFormatArabicDate(item.endDate));
  return isAr ? '$start ← $end' : '$start → $end';
}

String _initials(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((e) => e.isNotEmpty)
      .toList(growable: false);
  if (parts.isEmpty) return '—';
  String firstChar(String value) => value.isEmpty ? '' : value.substring(0, 1);
  if (parts.length == 1) return firstChar(parts.first).toUpperCase();
  return '${firstChar(parts.first)}${firstChar(parts.last)}'.toUpperCase();
}

FooterSettings _pwfFallbackFooterSettings([String unitSlug = 'home']) {
  final now = DateTime.now();
  final isHome = unitSlug.trim().toLowerCase() == 'home';
  if (!isHome) {
    return FooterSettings(
      id: 'fallback-unit-contact',
      ministryName: 'بيانات الوحدة غير منشورة',
      ministrySubtitle: 'بوابة الوحدة العامة',
      ministryDescription:
          'لم تنشر هذه الوحدة بيانات الاتصال أو وسائل التواصل الاجتماعي الخاصة بها بعد.',
      contactPhone: null,
      contactEmail: null,
      contactAddress: null,
      workingDays: 'غير منشور',
      workingHours: 'غير منشور',
      quickLinks: const [],
      servicesLinks: const [],
      bottomLinks: const [],
      copyrightText: 'بوابة الوحدة العامة - بيانات الاتصال بانتظار الاعتماد.',
      developerCredit: '',
      createdAt: now,
      updatedAt: now,
    );
  }
  return FooterSettings(
    id: 'fallback',
    ministryName: 'وزارة الأوقاف والشؤون الدينية',
    ministrySubtitle: 'دولة فلسطين',
    ministryDescription:
        'وزارة الأوقاف والشؤون الدينية تعمل على خدمة المجتمع الفلسطيني وتعزيز القيم الدينية والتراث الإسلامي.',
    contactPhone: '02-2411937/8/9',
    contactEmail: 'info@awqaf.ps',
    contactAddress: 'رام الله - فلسطين',
    workingDays: 'من الأحد إلى الخميس',
    workingHours: '8:00 صباحاً - 3:00 مساءً',
    quickLinks: const [
      FooterLink(label: 'عن الوزارة', route: '/about'),
      FooterLink(label: 'الخدمات', route: '/services'),
    ],
    servicesLinks: const [
      FooterLink(label: 'الخدمات الإلكترونية', route: '/eservices'),
      FooterLink(label: 'الشكاوى', route: '/complaints'),
    ],
    bottomLinks: const [],
    copyrightText: '© وزارة الأوقاف والشؤون الدينية - دولة فلسطين',
    developerCredit: '',
    createdAt: now,
    updatedAt: now,
  );
}

class _PwfUnitsLoadingState extends StatelessWidget {
  const _PwfUnitsLoadingState();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: List.generate(
        6,
        (_) => const SizedBox(
          width: 280,
          child: PwfSurfaceCard(child: SizedBox(height: 120)),
        ),
      ),
    );
  }
}

class _PwfUnitsGrid extends StatelessWidget {
  const _PwfUnitsGrid({required this.rows});

  final List<Map<String, dynamic>> rows;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 1280
            ? 4
            : width >= 980
            ? 3
            : width >= 620
            ? 2
            : 1;
        const gap = 16.0;
        final itemWidth = (width - gap * (columns - 1)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final row in rows)
              SizedBox(
                width: itemWidth,
                child: _PwfUnitCard(row: row),
              ),
          ],
        );
      },
    );
  }
}

class _PwfUnitCard extends StatelessWidget {
  const _PwfUnitCard({required this.row});

  final Map<String, dynamic> row;

  @override
  Widget build(BuildContext context) {
    final name = [row['name_ar'], row['title_ar'], row['name_en'], row['name']]
        .map((e) => (e ?? '').toString().trim())
        .firstWhere((e) => e.isNotEmpty, orElse: () => 'وحدة تنظيمية');
    final slug = (row['slug'] ?? '').toString().trim();
    final level = (row['unit_level'] ?? row['type'] ?? '').toString().trim();
    final location = (row['location_label'] ?? row['current_governorate'] ?? '')
        .toString()
        .trim();

    return PwfSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          if (level.isNotEmpty)
            PwfMetaBadge(label: level, icon: Icons.account_tree_outlined),
          if (location.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(location, style: Theme.of(context).textTheme.bodyMedium),
          ],
          if (slug.isNotEmpty) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: _PwfSecondaryLinkButton(
                label: 'فتح صفحة الوحدة',
                onTap: () => context.go(PwfUnitSlugRegistry.publicBasePathFor(slug)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PwfSimpleNoticeCard extends StatelessWidget {
  const _PwfSimpleNoticeCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return PwfSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(height: 1.7),
          ),
        ],
      ),
    );
  }
}

class _PwfQuickRouteChips extends StatelessWidget {
  const _PwfQuickRouteChips();

  @override
  Widget build(BuildContext context) {
    final items = <Map<String, String>>[
      {'label': 'الشكاوى', 'route': AppRoutes.complaints},
      {'label': 'الزكاة', 'route': AppRoutes.zakat},
      {'label': 'مواقيت الصلاة', 'route': AppRoutes.prayerTimes},
      {'label': 'القرآن الكريم', 'route': AppRoutes.quran},
    ];
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final item in items)
          ActionChip(
            label: Text(item['label']!),
            onPressed: () => context.go(item['route']!),
          ),
      ],
    );
  }
}

class _PwfContactInfoCard extends StatelessWidget {
  const _PwfContactInfoCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final cardWidth = (MediaQuery.sizeOf(context).width - 64)
        .clamp(240.0, 320.0)
        .toDouble();
    final compact = cardWidth < 300;
    return SizedBox(
      width: cardWidth,
      child: PwfSurfaceCard(
        child: Row(
          children: [
            Container(
              width: compact ? 42 : 46,
              height: compact ? 42 : 46,
              decoration: BoxDecoration(
                color: const Color(0x110F2C55),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: const Color(0xFF0F2C55)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(height: 1.6),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PwfPrimaryLinkButton extends StatelessWidget {
  const _PwfPrimaryLinkButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onTap,
      child: Text(
        label,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _PwfSecondaryLinkButton extends StatelessWidget {
  const _PwfSecondaryLinkButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      child: Text(
        label,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
