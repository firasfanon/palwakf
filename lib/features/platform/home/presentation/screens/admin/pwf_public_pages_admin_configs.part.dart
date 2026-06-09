part of 'pwf_public_pages_admin_screens.dart';

class PwfPublicPageAdminConfig {
  const PwfPublicPageAdminConfig({
    required this.id,
    required this.route,
    required this.publicRoute,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.sourceLabel,
    required this.sourceDescription,
    this.pageSlug,
    this.requiresCms = false,
    this.managementFocus = const <String>[],
    this.governanceNotes = const <String>[],
  });

  final String id;
  final String route;
  final String publicRoute;
  final String title;
  final String subtitle;
  final IconData icon;
  final String sourceLabel;
  final String sourceDescription;
  final String? pageSlug;
  final bool requiresCms;
  final List<String> managementFocus;
  final List<String> governanceNotes;
}

const pwfPublicPageAdminConfigs = <PwfPublicPageAdminConfig>[
  PwfPublicPageAdminConfig(
    id: 'about',
    route: AppRoutes.adminAboutPage,
    publicRoute: AppRoutes.about,
    title: 'إدارة صفحة عن الوزارة',
    subtitle: 'إدارة الصفحة التعريفية الرسمية للوزارة وربطها بمحتوى CMS العام.',
    icon: Icons.info_outline_rounded,
    sourceLabel: 'site_pages + fallback عام',
    sourceDescription:
        'تعتمد الصفحة العامة على site_pages عند توفر المحتوى، مع fallback محلي منسجم مع هوية المنصة.',
    pageSlug: 'about',
    requiresCms: true,
    managementFocus: [
      'العنوان والوصف المختصر',
      'المحتوى التعريفي والأهداف',
      'أزرار الإحالة إلى الخدمات أو التواصل',
    ],
    governanceNotes: [
      'هذه الصفحة مرجعية مؤسسية وليست خبرًا أو بطاقة محتوى عابرة.',
      'يجب أن تبقى منسجمة مع هوية المنصة ومرجع الوزارة الرسمي.',
    ],
  ),
  PwfPublicPageAdminConfig(
    id: 'minister',
    route: AppRoutes.adminMinisterPage,
    publicRoute: AppRoutes.minister,
    title: 'إدارة صفحة كلمة الوزير',
    subtitle: 'إدارة الرسالة الرسمية والروابط الداعمة لصفحة كلمة الوزير.',
    icon: Icons.record_voice_over_outlined,
    sourceLabel: 'site_pages + fallback عام',
    sourceDescription:
        'المحتوى الحالي يقرأ من site_pages عند وجوده ثم يعود إلى محتوى مرجعي محلي عند الحاجة.',
    pageSlug: 'minister',
    requiresCms: true,
    managementFocus: [
      'الرسالة الرسمية',
      'أولويات العمل',
      'الزر الرئيسي المحيل إلى الخدمات',
    ],
    governanceNotes: [
      'تخضع الصفحة لمراجعة مؤسسية قبل النشر.',
      'لا يجوز أن تتحول إلى مساحة أخبار أو منشورات يومية.',
    ],
  ),
  PwfPublicPageAdminConfig(
    id: 'vision_mission',
    route: AppRoutes.adminVisionMissionPage,
    publicRoute: AppRoutes.visionMission,
    title: 'إدارة صفحة الرؤية والرسالة',
    subtitle: 'إدارة النصوص المرجعية للرؤية والرسالة والقيم الحاكمة.',
    icon: Icons.track_changes_outlined,
    sourceLabel: 'site_pages + fallback عام',
    sourceDescription:
        'الصفحة تقرأ من site_pages عندما يتوفر نص سيادي، وإلا تستخدم النص المؤسسي المرجعي داخل التطبيق.',
    pageSlug: 'vision-mission',
    requiresCms: true,
    managementFocus: ['الرؤية', 'الرسالة', 'القيم', 'الربط مع صفحة عن الوزارة'],
    governanceNotes: [
      'هذه صفحة سياسات عليا وليست مساحة محتوى عادي.',
      'أي تعديل عليها يحتاج مصادقة مؤسسية واضحة.',
    ],
  ),
  PwfPublicPageAdminConfig(
    id: 'structure',
    route: AppRoutes.adminStructurePage,
    publicRoute: AppRoutes.structure,
    title: 'إدارة صفحة الهيكل التنظيمي',
    subtitle:
        'إدارة طريقة العرض والرسالة التوضيحية للهيكل التنظيمي المرتبط بمرجع الوحدات.',
    icon: Icons.account_tree_outlined,
    sourceLabel: 'core/org_units + intro page',
    sourceDescription:
        'الصفحة العامة تستمد الشبكة التنظيمية من مرجع الوحدات التنظيمية الفعلي داخل المنصة.',
    managementFocus: [
      'الرسالة التعريفية',
      'طريقة عرض الوحدات',
      'إحالات الصفحات الوحدوية',
    ],
    governanceNotes: [
      'المحتوى البنيوي هنا مستمد من مرجع الوحدات السيادي وليس من إدخالات حرة.',
      'هذه الصفحة يجب أن تعكس حالة org_units الحقيقية.',
    ],
  ),
  PwfPublicPageAdminConfig(
    id: 'former_ministers',
    route: AppRoutes.adminFormerMinistersPage,
    publicRoute: AppRoutes.formerMinisters,
    title: 'إدارة صفحة الوزراء السابقين',
    subtitle:
        'إدارة الصفحة المرجعية الخاصة بالتسلسل التاريخي للوزراء السابقين.',
    icon: Icons.history_edu_outlined,
    sourceLabel: 'site_pages + former_ministers',
    sourceDescription:
        'الصفحة العامة هجينة: المقدمة التحريرية من site_pages والسجل التاريخي الفعلي من former_ministers.',
    pageSlug: 'former-ministers',
    requiresCms: true,
    managementFocus: [
      'المقدمة التعريفية',
      'الترتيب التاريخي',
      'المحتوى البصري أو البطاقات',
    ],
    governanceNotes: [
      'الترتيب الزمني والمعلومة التاريخية يجب أن يخضعا للتدقيق.',
      'لا يجوز التعامل مع الصفحة كمساحة أخبار.',
    ],
  ),
  PwfPublicPageAdminConfig(
    id: 'services',
    route: AppRoutes.adminServicesPage,
    publicRoute: AppRoutes.services,
    title: 'إدارة صفحة الخدمات',
    subtitle: 'إدارة تنظيم وعرض الخدمات العامة وما يظهر في بوابة الخدمات.',
    icon: Icons.design_services_outlined,
    sourceLabel:
        'site_pages + homepage_sections + public.v_services_catalog_compat_v1 + footer_settings',
    sourceDescription:
        'الصفحة العامة ديناميكية: intro من site_pages، ترتيب وتفعيل الأقسام من homepage_sections، كتالوج خدمات الجمهور من public.v_services_catalog_compat_v1، والخدمات السريعة/الروابط المساندة من footer_settings.',
    managementFocus: [
      'تصنيف خدمات الجمهور العامة',
      'ترتيب أقسام الصفحة الديناميكية',
      'ربط البطاقات بمسارات حقيقية',
      'فصل خدمات العقارات الوقفية عن خدمات الجمهور',
    ],
    governanceNotes: [
      'أي خدمة غير جاهزة لا ينبغي إظهارها كخدمة مكتملة.',
      'الربط يجب أن يكون بمسارات حقيقية فقط.',
      'slug الوحدة يفلتر نفس بنية الصفحة ولا ينشئ صفحة مستقلة.',
      'خدمات العقارات الوقفية لا تخلط مع واجهة توافق خدمات الجمهور إلى حين اكتمال waqf_assets.',
    ],
  ),
  PwfPublicPageAdminConfig(
    id: 'eservices',
    route: AppRoutes.adminEServicesPage,
    publicRoute: AppRoutes.eservices,
    title: 'إدارة صفحة الخدمات الإلكترونية',
    subtitle: 'إدارة البطاقات الإلكترونية ومسارات الوصول إلى الخدمات الرقمية.',
    icon: Icons.computer_outlined,
    sourceLabel: 'site_pages + homepage_sections + footer_settings',
    sourceDescription:
        'الصفحة العامة هجينة: intro من site_pages، وبوابة الخدمات الإلكترونية من homepage_sections، وروابط الخدمات المساندة من footer_settings.',
    managementFocus: [
      'بوابة الخدمات الإلكترونية',
      'تصنيف الخدمات الرقمية',
      'الروابط والتوجيهات',
    ],
    governanceNotes: [
      'لا يجوز إدراج خدمة إلكترونية قبل اكتمال مسارها الفعلي.',
      'الروابط يجب أن تحيل إلى نماذج أو صفحات تشغيلية حقيقية.',
    ],
  ),
  PwfPublicPageAdminConfig(
    id: 'social_services',
    route: AppRoutes.adminSocialServicesPage,
    publicRoute: AppRoutes.socialServices,
    title: 'إدارة صفحة الاجتماعيات',
    subtitle:
        'إدارة محتوى الاجتماعيات باعتباره محتوى إعلاميًا اجتماعيًا لا خدمة جمهور.',
    icon: Icons.people_outline_rounded,
    sourceLabel: 'media-center social posts + legacy route alias',
    sourceDescription:
        'المسار العام الحالي /social-services يبقى alias تاريخيًا، لكن التسمية والحوكمة أصبحت اجتماعيات ضمن المركز الإعلامي.',
    managementFocus: [
      'تهاني',
      'تعازي',
      'مناسبات اجتماعية',
      'نطاق النشر الإعلامي',
    ],
    governanceNotes: [
      'لا تُعرض الاجتماعيات داخل مركز الخدمات.',
      'تخضع لصياغة ومراجعة إعلامية قبل النشر.',
    ],
  ),
  PwfPublicPageAdminConfig(
    id: 'projects',
    route: AppRoutes.adminProjectsPage,
    publicRoute: AppRoutes.projects,
    title: 'إدارة صفحة المشاريع',
    subtitle: 'إدارة عرض المشاريع والمبادرات العامة وربطها بالمحتوى المنشور.',
    icon: Icons.work_outline_rounded,
    sourceLabel: 'shared content / project cards',
    sourceDescription:
        'الصفحة العامة تعتمد على بطاقات ومحتوى مشروع فعلي وليس على صفحة ثابتة فقط.',
    managementFocus: [
      'البطاقات الرئيسية',
      'الحالات',
      'العناصر المميزة',
      'المحتوى الداعم',
    ],
    governanceNotes: [
      'لا ينبغي نشر مشروع غير مكتمل البيانات أو بدون مسار معلوماتي صحيح.',
      'تحديث الصفحة يجب أن ينسجم مع المحتوى المشترك للمنصة.',
    ],
  ),
  PwfPublicPageAdminConfig(
    id: 'contact',
    route: AppRoutes.adminContactPage,
    publicRoute: AppRoutes.contact,
    title: 'إدارة صفحة اتصل بنا',
    subtitle:
        'إدارة بيانات التواصل الرسمية، نماذج الاتصال، وقنوات الوصول للجمهور.',
    icon: Icons.contact_phone_outlined,
    sourceLabel: 'site_pages + footer_settings',
    sourceDescription:
        'الصفحة العامة هجينة: المقدمة التحريرية من site_pages وبيانات التواصل الرسمية من footer_settings.',
    pageSlug: 'contact',
    requiresCms: true,
    managementFocus: [
      'العنوان التعريفي',
      'بيانات التواصل',
      'الموقع والخريطة',
      'رسائل النموذج',
    ],
    governanceNotes: [
      'يجب أن تبقى بيانات الاتصال الرسمية متسقة مع إعدادات الوحدة والمنصة.',
      'أي نموذج إرسال يجب أن يكون مربوطًا بمسار فعلي.',
    ],
  ),
  PwfPublicPageAdminConfig(
    id: 'privacy',
    route: AppRoutes.adminPrivacyPage,
    publicRoute: AppRoutes.privacy,
    title: 'إدارة صفحة سياسة الخصوصية',
    subtitle: 'إدارة النص القانوني/الإجرائي لسياسة الخصوصية داخل المنصة.',
    icon: Icons.privacy_tip_outlined,
    sourceLabel: 'site_pages + static policy fallback',
    sourceDescription:
        'يقرأ النص من site_pages عند توفره أو يعرض نصًا مرجعيًا ثابتًا من التطبيق.',
    pageSlug: 'privacy',
    requiresCms: true,
    managementFocus: [
      'النص القانوني',
      'تاريخ آخر تحديث',
      'الروابط المرتبطة بالشروط أو التواصل',
    ],
    governanceNotes: [
      'هذه الصفحة مرجعية قانونية ويجب ضبط نسخة النشر المعتمدة فيها.',
      'لا تقبل تحديثات مرتجلة خارج مسار المراجعة.',
    ],
  ),
  PwfPublicPageAdminConfig(
    id: 'terms',
    route: AppRoutes.adminTermsPage,
    publicRoute: AppRoutes.terms,
    title: 'إدارة صفحة شروط الاستخدام',
    subtitle: 'إدارة النص الرسمي لشروط الاستخدام والالتزامات العامة.',
    icon: Icons.rule_folder_outlined,
    sourceLabel: 'site_pages + static policy fallback',
    sourceDescription:
        'تعرض الصفحة نصًا قانونيًا/إجرائيًا معتمدًا من site_pages أو من fallback منظم.',
    pageSlug: 'terms',
    requiresCms: true,
    managementFocus: [
      'نص الشروط',
      'العلاقة مع الخصوصية',
      'تاريخ الإصدار والتحديث',
    ],
    governanceNotes: [
      'شروط الاستخدام وثيقة حاكمة ويجب أن تبقى متسقة مع سياسات المنصة.',
      'أي تعديل عليها يجب أن يكون مُؤرشفًا بوضوح.',
    ],
  ),
  PwfPublicPageAdminConfig(
    id: 'sitemap',
    route: AppRoutes.adminSitemapPage,
    publicRoute: AppRoutes.sitemap,
    title: 'إدارة صفحة خريطة الموقع',
    subtitle:
        'إدارة مخرجات خريطة الموقع وروابط الأقسام العامة والخدمات الأساسية.',
    icon: Icons.map_outlined,
    sourceLabel: 'router + public registry',
    sourceDescription:
        'تستند الصفحة العامة إلى المسارات الفعلية والقوائم والروابط العامة داخل المنصة.',
    pageSlug: 'sitemap',
    requiresCms: true,
    managementFocus: [
      'الروابط الظاهرة',
      'تجميع الأقسام',
      'إبراز الخدمات الرئيسية',
    ],
    governanceNotes: [
      'يجب ألّا تعرض خريطة الموقع مسارات غير جاهزة أو مسارات وهمية.',
      'أي تحديث في القوائم العامة يستلزم مراجعة هذه الصفحة.',
    ],
  ),
];

const _kBatchACmsSlugs = <String>{
  'about',
  'minister',
  'vision-mission',
  'contact',
  'former-ministers',
  'privacy',
  'terms',
  'sitemap',
  'services',
  'eservices',
};

bool _supportsRealCmsClosure(PwfPublicPageAdminConfig config) {
  final slug = config.pageSlug?.trim();
  return slug != null && _kBatchACmsSlugs.contains(slug);
}

PwfPublicPageAdminConfig? pwfPublicPageAdminConfigByRoute(String route) {
  for (final config in pwfPublicPageAdminConfigs) {
    if (config.route == route) return config;
  }
  return null;
}

class PwfPublicPagesAdminHubScreen extends StatelessWidget {
  const PwfPublicPagesAdminHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PwfPlatformServiceAdminScreen(
      currentRoute: AppRoutes.adminPublicPagesHub,
      title: 'إدارة الصفحات العامة',
      subtitle:
          'بوابة إدارية موحدة للصفحات العامة المنجزة وربطها بمصادرها الحقيقية داخل المنصة.',
      stats: const [
        PwfServiceAdminStat(
          label: 'الصفحات الإدارية',
          value: '13',
          icon: Icons.web_asset_rounded,
          hint: 'صفحات عامة مرتبطة حقيقيًا بالمنصة',
        ),
        PwfServiceAdminStat(
          label: 'المرتبطة بـ CMS',
          value: '10',
          icon: Icons.article_outlined,
          hint: 'صفحات تقرأ من site_pages عند توفره',
        ),
        PwfServiceAdminStat(
          label: 'المرتبطة بخدمات فعلية',
          value: '5',
          icon: Icons.hub_outlined,
          hint: 'صفحات تُشتق من features عامة أو من مرجع المنصة',
        ),
        PwfServiceAdminStat(
          label: 'الوضع الحالي',
          value: 'Batch B قيد الإغلاق',
          icon: Icons.construction_outlined,
          hint:
              'تم توسيع نمط CRUD الفعلي فوق site_pages ليشمل صفحات الخدمات والخدمات الإلكترونية أيضًا.',
        ),
      ],
      quickActions: const [
        PwfServiceAdminAction(
          label: 'إدارة الصفحة الرئيسية',
          icon: Icons.home_outlined,
          route: AppRoutes.adminHomeManagement,
        ),
        PwfServiceAdminAction(
          label: 'المحتوى المشترك',
          icon: Icons.article_outlined,
          route: AppRoutes.adminSharedContent,
        ),
        PwfServiceAdminAction(
          label: 'فتح خريطة الموقع العامة',
          icon: Icons.open_in_new_rounded,
          route: AppRoutes.sitemap,
        ),
      ],
      tabs: [
        PwfServiceAdminTab(
          label: 'الفهرس',
          icon: Icons.grid_view_rounded,
          child: _HubIndexTab(),
        ),
        PwfServiceAdminTab(
          label: 'الربط الفعلي',
          icon: Icons.link_rounded,
          child: _HubSourcesTab(),
        ),
        PwfServiceAdminTab(
          label: 'الحوكمة',
          icon: Icons.policy_outlined,
          child: _HubGovernanceTab(),
        ),
      ],
    );
  }
}

class _HubIndexTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PwfAdminSectionCard(
      title: 'الصفحات العامة المنجزة',
      subtitle:
          'روابط مباشرة إلى مساحات الإدارة الحقيقية لكل صفحة عامة تم تطويرها وربطها بالقوائم.',
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: pwfPublicPageAdminConfigs
            .map(
              (config) => SizedBox(
                width: 280,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => context.go(config.route),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: const Color(0xFFE8F0FE),
                          child: Icon(
                            config.icon,
                            color: const Color(0xFF0F4C81),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                config.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                config.publicRoute,
                                style: const TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class _HubSourcesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PwfAdminSectionCard(
      title: 'مصادر الصفحات',
      subtitle:
          'يوضح هذا الجدول المصدر الفعلي لكل صفحة عامة حتى لا تتحول الإدارة إلى روابط وهمية.',
      child: Column(
        children: pwfPublicPageAdminConfigs
            .map(
              (config) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  tileColor: const Color(0xFFF8FAFC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFE8F0FE),
                    child: Icon(config.icon, color: const Color(0xFF0F4C81)),
                  ),
                  title: Text(config.title),
                  subtitle: Text(config.sourceDescription),
                  trailing: PwfAdminBadge(label: config.sourceLabel),
                ),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class _HubGovernanceTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        PwfAdminSectionCard(
          title: 'قواعد حاكمة',
          subtitle:
              'مبادئ تنفيذية يجب تثبيتها عند إدارة الصفحات العامة من داخل لوحة التحكم.',
          child: PwfAdminBulletList(
            items: [
              'لا تُربط أي صفحة عامة داخل لوحة التحكم بواجهة الموقع العامة مباشرة بوصفها صفحة إدارة.',
              'الصفحات الإدارية هنا هي workspaces حقيقية تستند إلى مصادر فعلية مثل site_pages أو shared content أو مرجع الوحدات.',
              'أي صفحة لا تزال غير جاهزة لا ينبغي أن تظهر في القوائم العامة أو الإدارية كصفحة مكتملة.',
              'تظل Top Bar وHeader وFooter من المنصة العامة، أما الإدارة فتتم داخل admin shell فقط.',
            ],
          ),
        ),
      ],
    );
  }
}
