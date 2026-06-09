part of 'pwf_public_pages_admin_screens.dart';

class PwfPublicPageAdminScreen extends ConsumerWidget {
  const PwfPublicPageAdminScreen({super.key, required this.config});

  final PwfPublicPageAdminConfig config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageAsync = config.pageSlug == null
        ? const AsyncValue<PwfSitePage?>.data(null)
        : ref.watch(pwfGlobalSitePageProvider(config.pageSlug!));

    final page = pageAsync.valueOrNull;
    final hasCms = page != null;
    final bodyLength = (page?.bodyAr.trim().isNotEmpty ?? false)
        ? page!.bodyAr.trim().length
        : (page?.bodyEn.trim().length ?? 0);
    final hasRealCmsEditor = _supportsRealCmsClosure(config);
    final extraTabs = <PwfServiceAdminTab>[
      if (config.id == 'contact')
        const PwfServiceAdminTab(
          label: 'بيانات التواصل',
          icon: Icons.contact_mail_outlined,
          child: _ContactChannelsAdminTab(),
        ),
      if (config.id == 'former_ministers')
        const PwfServiceAdminTab(
          label: 'السجل التاريخي',
          icon: Icons.history_edu_outlined,
          child: _FormerMinistersAdminTab(),
        ),
      if (config.id == 'services' || config.id == 'eservices')
        const PwfServiceAdminTab(
          label: 'الخدمات السريعة',
          icon: Icons.miscellaneous_services_outlined,
          child: _ServicesLinksAdminTab(),
        ),
      if (config.id == 'services' || config.id == 'eservices')
        const PwfServiceAdminTab(
          label: 'بوابة الخدمات الإلكترونية',
          icon: Icons.apps_outlined,
          child: _EServicesPortalAdminTab(),
        ),
    ];

    return PwfPlatformServiceAdminScreen(
      currentRoute: config.route,
      title: config.title,
      subtitle: config.subtitle,
      stats: [
        PwfServiceAdminStat(
          label: 'المسار العام',
          value: config.publicRoute,
          icon: config.icon,
          hint: 'المسار الفعلي الظاهر للجمهور',
        ),
        PwfServiceAdminStat(
          label: 'مصدر الصفحة',
          value: config.sourceLabel,
          icon: Icons.link_rounded,
          hint: config.sourceDescription,
        ),
        PwfServiceAdminStat(
          label: 'حالة الربط',
          value: config.requiresCms
              ? (hasCms ? 'CMS فعلي' : 'Fallback')
              : 'غير إلزامي',
          icon: Icons.article_outlined,
          hint: config.pageSlug == null
              ? 'الصفحة تعتمد على مصدر بنيوي/خدمي أكثر من CMS ثابت.'
              : 'فحص الربط الحالي مع site_pages العالمي.',
        ),
        PwfServiceAdminStat(
          label: 'الإدارة الحالية',
          value: hasRealCmsEditor ? 'CRUD فعلي' : 'Workspace',
          icon: hasRealCmsEditor
              ? Icons.edit_note_rounded
              : Icons.dashboard_customize_outlined,
          hint: hasRealCmsEditor
              ? 'هذه الصفحة أصبحت قابلة للقراءة والحفظ والنشر مباشرة فوق site_pages.'
              : 'هذه الصفحة ما زالت مساحة إدارة تمهيدية وتحتاج إغلاقًا لاحقًا.',
        ),
      ],
      quickActions: [
        PwfServiceAdminAction(
          label: 'فتح الصفحة العامة',
          icon: Icons.open_in_new_rounded,
          route: config.publicRoute,
        ),
        const PwfServiceAdminAction(
          label: 'إدارة الصفحة الرئيسية',
          icon: Icons.space_dashboard_outlined,
          route: AppRoutes.adminHomeManagement,
        ),
        const PwfServiceAdminAction(
          label: 'المحتوى المشترك',
          icon: Icons.article_outlined,
          route: AppRoutes.adminSharedContent,
        ),
      ],
      tabs: [
        PwfServiceAdminTab(
          label: 'نظرة عامة',
          icon: Icons.dashboard_outlined,
          child: _PublicPageOverviewTab(config: config, page: page),
        ),
        if (hasRealCmsEditor)
          PwfServiceAdminTab(
            label: 'تحرير الصفحة',
            icon: Icons.edit_note_rounded,
            child: _PublicPageEditorTab(config: config),
          ),
        ...extraTabs,
        PwfServiceAdminTab(
          label: 'المحتوى الفعلي',
          icon: Icons.description_outlined,
          child: _PublicPageContentTab(config: config, pageAsync: pageAsync),
        ),
        PwfServiceAdminTab(
          label: 'الهوية والتنقل',
          icon: Icons.account_tree_outlined,
          child: _PublicPageIdentityTab(config: config),
        ),
        PwfServiceAdminTab(
          label: 'الحوكمة والنشر',
          icon: Icons.policy_outlined,
          child: _PublicPageGovernanceTab(
            config: config,
            page: page,
            bodyLength: bodyLength,
          ),
        ),
      ],
    );
  }
}

class _PublicPageOverviewTab extends StatelessWidget {
  const _PublicPageOverviewTab({required this.config, required this.page});

  final PwfPublicPageAdminConfig config;
  final PwfSitePage? page;

  @override
  Widget build(BuildContext context) {
    final pageRecord = page;
    final statusValue = pageRecord == null
        ? 'تعتمد على fallback/feature source'
        : (pageRecord.isPublished ? 'منشورة' : 'غير منشورة');
    final statusBadge = pageRecord == null
        ? 'fallback'
        : (pageRecord.isPublished ? 'منشور' : 'مسودة');

    return Column(
      children: [
        PwfAdminSectionCard(
          title: 'الدور الإداري للصفحة',
          subtitle:
              'هذه الصفحة الإدارية تضبط العمل العام المرتبط بالصفحة العامة، ولا تكتفي بتحويل المسؤول إلى الصفحة العامة نفسها.',
          child: PwfAdminBulletList(items: config.managementFocus),
        ),
        const SizedBox(height: 16),
        PwfAdminSectionCard(
          title: 'ملخص الربط الحالي',
          subtitle: 'قراءة فعلية للحالة الحالية للصفحة داخل المنصة.',
          child: Column(
            children: [
              PwfAdminInfoRow(label: 'المسار العام', value: config.publicRoute),
              PwfAdminInfoRow(label: 'نوع المصدر', value: config.sourceLabel),
              PwfAdminInfoRow(
                label: 'slug المرتبط بـ CMS',
                value: config.pageSlug ?? 'لا يوجد slug CMS مباشر',
              ),
              PwfAdminInfoRow(
                label: 'الحالة الحالية',
                value: statusValue,
                trailing: PwfAdminBadge(label: statusBadge),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PublicPageContentTab extends StatelessWidget {
  const _PublicPageContentTab({required this.config, required this.pageAsync});

  final PwfPublicPageAdminConfig config;
  final AsyncValue<PwfSitePage?> pageAsync;

  @override
  Widget build(BuildContext context) {
    return pageAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, _) => PwfAdminSectionCard(
        title: 'تعذر قراءة المحتوى الفعلي',
        subtitle:
            'حدث خطأ أثناء محاولة قراءة المصدر الحقيقي لهذه الصفحة من قاعدة البيانات.',
        child: Text(error.toString()),
      ),
      data: (page) {
        if (page == null) {
          return PwfAdminSectionCard(
            title: 'لا يوجد سجل CMS مباشر حاليًا',
            subtitle:
                'الصفحة العامة تعمل حاليًا من خلال المصدر البنيوي/المرجعي المعرّف لها أو fallback محلي منسجم مع هوية المنصة.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PwfAdminInfoRow(
                  label: 'المصدر الحالي',
                  value: config.sourceDescription,
                ),
                const SizedBox(height: 12),
                if (config.pageSlug != null)
                  Text(
                    'عند إنشاء أو تفعيل سجل في site_pages بالـ slug: ${config.pageSlug} ستبدأ الصفحة العامة بقراءة المحتوى منه تلقائيًا.',
                    style: const TextStyle(height: 1.7),
                  ),
              ],
            ),
          );
        }

        return Column(
          children: [
            PwfAdminSectionCard(
              title: 'السجل الحالي من site_pages',
              subtitle: 'المحتوى التالي مقروء فعليًا من قاعدة البيانات.',
              child: Column(
                children: [
                  PwfAdminInfoRow(
                    label: 'العنوان العربي',
                    value: _safeText(page.titleAr),
                  ),
                  PwfAdminInfoRow(
                    label: 'العنوان الإنجليزي',
                    value: _safeText(page.titleEn),
                  ),
                  PwfAdminInfoRow(
                    label: 'الوصف العربي',
                    value: _safeText(page.subtitleAr),
                  ),
                  PwfAdminInfoRow(
                    label: 'الوصف الإنجليزي',
                    value: _safeText(page.subtitleEn),
                  ),
                  PwfAdminInfoRow(
                    label: 'النشر',
                    value: page.isPublished ? 'منشور' : 'غير منشور',
                  ),
                  PwfAdminInfoRow(
                    label: 'آخر تحديث',
                    value: _fmtDate(page.updatedAt),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            PwfAdminSectionCard(
              title: 'معاينة مقتطف المحتوى',
              subtitle:
                  'قراءة مباشرة لمقتطف من body العربي/الإنجليزي كما هو محفوظ الآن.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PreviewBox(title: 'العربي', body: page.bodyAr),
                  const SizedBox(height: 12),
                  _PreviewBox(title: 'English', body: page.bodyEn),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PublicPageIdentityTab extends StatelessWidget {
  const _PublicPageIdentityTab({required this.config});

  final PwfPublicPageAdminConfig config;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const PwfAdminSectionCard(
          title: 'قواعد الهوية والـ shell',
          subtitle:
              'ملخص تنفيذي ثابت يوضح كيف يجب أن تبقى الصفحة العامة متصلة بالمنصة.',
          child: PwfAdminBulletList(
            items: [
              'Top Bar وHeader وFooter تأتي من المنصة العامة نفسها.',
              'Hero والمحتوى الداخلي خاصان بالصفحة أو الخدمة.',
              'لا ينبغي أن تفتح الصفحة العامة خارج PwfWebPageScaffold.',
              'أي تحديث في القوائم العامة أو الروابط المهمة يجب أن ينعكس هنا وفي خريطة الموقع.',
            ],
          ),
        ),
        const SizedBox(height: 16),
        PwfAdminSectionCard(
          title: 'مسارات مرتبطة بهذه الصفحة',
          subtitle: 'روابط تشغيلية وإدارية مرتبطة مباشرة بالصفحة.',
          child: Column(
            children: [
              PwfAdminInfoRow(label: 'المسار العام', value: config.publicRoute),
              PwfAdminInfoRow(label: 'المسار الإداري', value: config.route),
              const PwfAdminInfoRow(
                label: 'إدارة القسم العام',
                value: AppRoutes.adminHomeManagement,
              ),
              const PwfAdminInfoRow(
                label: 'المحتوى المشترك',
                value: AppRoutes.adminSharedContent,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PublicPageGovernanceTab extends StatelessWidget {
  const _PublicPageGovernanceTab({
    required this.config,
    required this.page,
    required this.bodyLength,
  });

  final PwfPublicPageAdminConfig config;
  final PwfSitePage? page;
  final int bodyLength;

  @override
  Widget build(BuildContext context) {
    final pageRecord = page;
    final publishState = pageRecord == null
        ? 'fallback/feature source'
        : (pageRecord.isPublished ? 'منشور' : 'مسودة');

    return Column(
      children: [
        PwfAdminSectionCard(
          title: 'ضوابط حاكمة',
          subtitle:
              'اعتبارات يجب تثبيتها أثناء تطوير هذه الصفحة أو ربطها بالبيانات.',
          child: PwfAdminBulletList(items: config.governanceNotes),
        ),
        const SizedBox(height: 16),
        PwfAdminSectionCard(
          title: 'مؤشرات ربط فعلية',
          subtitle:
              'ليست بيانات وهمية؛ بل قراءة مباشرة لوجود سجل محتوى وطبيعته الحالية.',
          child: Column(
            children: [
              PwfAdminInfoRow(
                label: 'هل يوجد سجل CMS؟',
                value: pageRecord == null ? 'لا' : 'نعم',
              ),
              PwfAdminInfoRow(label: 'حالة النشر', value: publishState),
              PwfAdminInfoRow(
                label: 'طول المحتوى النصي',
                value: bodyLength.toString(),
              ),
              PwfAdminInfoRow(label: 'نوع المصدر', value: config.sourceLabel),
            ],
          ),
        ),
      ],
    );
  }
}
