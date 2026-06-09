part of 'pwf_public_pages_admin_screens.dart';

class _PublicPageEditorTab extends ConsumerStatefulWidget {
  const _PublicPageEditorTab({required this.config});

  final PwfPublicPageAdminConfig config;

  @override
  ConsumerState<_PublicPageEditorTab> createState() =>
      _PublicPageEditorTabState();
}

class _PublicPageEditorTabState extends ConsumerState<_PublicPageEditorTab> {
  late final TextEditingController _titleArCtrl;
  late final TextEditingController _titleEnCtrl;
  late final TextEditingController _subtitleArCtrl;
  late final TextEditingController _subtitleEnCtrl;
  late final TextEditingController _bodyArCtrl;
  late final TextEditingController _bodyEnCtrl;

  bool _isPublished = true;
  bool _isSaving = false;
  String? _statusMessage;
  String? _hydratedRevision;
  bool _hasLocalEdits = false;
  bool _isHydrating = false;

  @override
  void initState() {
    super.initState();
    final seed = _seedForConfig(widget.config);
    _titleArCtrl = TextEditingController(text: seed.titleAr);
    _titleEnCtrl = TextEditingController(text: seed.titleEn);
    _subtitleArCtrl = TextEditingController(text: seed.subtitleAr);
    _subtitleEnCtrl = TextEditingController(text: seed.subtitleEn);
    _bodyArCtrl = TextEditingController(text: seed.bodyAr);
    _bodyEnCtrl = TextEditingController(text: seed.bodyEn);
    _isPublished = seed.isPublished;

    for (final controller in <TextEditingController>[
      _titleArCtrl,
      _titleEnCtrl,
      _subtitleArCtrl,
      _subtitleEnCtrl,
      _bodyArCtrl,
      _bodyEnCtrl,
    ]) {
      controller.addListener(_markDirty);
    }
  }

  void _markDirty() {
    if (_isHydrating || _hasLocalEdits) return;
    setState(() => _hasLocalEdits = true);
  }

  @override
  void dispose() {
    _titleArCtrl.dispose();
    _titleEnCtrl.dispose();
    _subtitleArCtrl.dispose();
    _subtitleEnCtrl.dispose();
    _bodyArCtrl.dispose();
    _bodyEnCtrl.dispose();
    super.dispose();
  }

  void _hydrateFrom(PwfSitePage? page) {
    final revision =
        '${widget.config.pageSlug}:${page?.updatedAt?.toIso8601String() ?? 'fallback'}:${page?.isPublished ?? true}';
    if (_hydratedRevision == revision || _hasLocalEdits) return;
    final seed = page == null
        ? _seedForConfig(widget.config)
        : _CmsPageSeed.fromPage(page);
    _hydratedRevision = revision;
    _isHydrating = true;
    _titleArCtrl.text = seed.titleAr;
    _titleEnCtrl.text = seed.titleEn;
    _subtitleArCtrl.text = seed.subtitleAr;
    _subtitleEnCtrl.text = seed.subtitleEn;
    _bodyArCtrl.text = seed.bodyAr;
    _bodyEnCtrl.text = seed.bodyEn;
    _isPublished = seed.isPublished;
    _statusMessage = null;
    _isHydrating = false;
  }

  Future<void> _save() async {
    final slug = widget.config.pageSlug;
    if (slug == null || slug.trim().isEmpty) return;

    setState(() {
      _isSaving = true;
      _statusMessage = null;
    });

    try {
      final repo = ref.read(pwfSitePagesRepositoryProvider);
      await repo.upsertGlobalPage(
        slug: slug,
        titleAr: _titleArCtrl.text,
        titleEn: _titleEnCtrl.text,
        subtitleAr: _subtitleArCtrl.text,
        subtitleEn: _subtitleEnCtrl.text,
        bodyAr: _bodyArCtrl.text,
        bodyEn: _bodyEnCtrl.text,
        isPublished: _isPublished,
      );
      ref.invalidate(pwfGlobalSitePageProvider(slug));
      ref.invalidate(
        pwfSitePageProvider(PwfSitePageParam(unitSlug: 'home', slug: slug)),
      );
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _hasLocalEdits = false;
        _statusMessage = _isPublished
            ? 'تم الحفظ والنشر بنجاح.'
            : 'تم الحفظ كمسودة بنجاح.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _statusMessage = 'تعذر الحفظ: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final slug = widget.config.pageSlug;
    if (slug == null || slug.trim().isEmpty) {
      return const PwfAdminSectionCard(
        title: 'لا يوجد محرر CMS مباشر',
        subtitle:
            'هذه الصفحة لا تعتمد على site_pages كمسار إدارة مباشر في هذه المرحلة.',
        child: Text(
          'يُستكمل إغلاق هذا المسار لاحقًا عبر مصدره السيادي المناسب.',
        ),
      );
    }

    final pageAsync = ref.watch(pwfGlobalSitePageProvider(slug));
    ref.listen<AsyncValue<PwfSitePage?>>(pwfGlobalSitePageProvider(slug), (
      previous,
      next,
    ) {
      next.whenData((page) {
        if (!mounted) return;
        setState(() => _hydrateFrom(page));
      });
    });

    final currentPage = pageAsync.valueOrNull;
    _hydrateFrom(currentPage);

    return Column(
      children: [
        PwfAdminSectionCard(
          title: 'تحرير الصفحة وربطها بـ site_pages',
          subtitle:
              'هذا المحرر يقرأ السجل العالمي الحالي ويحفظ مباشرة في قاعدة البيانات بدل الاكتفاء بعرض وصفي أو fallback.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: 280,
                    child: SwitchListTile.adaptive(
                      value: _isPublished,
                      title: const Text('منشور'),
                      subtitle: const Text('تفعيل النشر العام من نفس السجل.'),
                      contentPadding: EdgeInsets.zero,
                      onChanged: _isSaving
                          ? null
                          : (v) => setState(() {
                              _isPublished = v;
                              _hasLocalEdits = true;
                            }),
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: _isSaving ? null : _save,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(_isSaving ? 'جارٍ الحفظ...' : 'حفظ الصفحة'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => context.go(widget.config.publicRoute),
                    icon: const Icon(Icons.open_in_new_rounded),
                    label: const Text('فتح الصفحة العامة'),
                  ),
                ],
              ),
              if (_statusMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _statusMessage!,
                  style: TextStyle(
                    color: _statusMessage!.startsWith('تم')
                        ? const Color(0xFF166534)
                        : const Color(0xFFB91C1C),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              if (pageAsync.isLoading)
                const LinearProgressIndicator(minHeight: 3),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final stacked = constraints.maxWidth < 980;
                  final left = Column(
                    children: [
                      _AdminTextField(
                        controller: _titleArCtrl,
                        label: 'العنوان العربي',
                      ),
                      const SizedBox(height: 12),
                      _AdminTextField(
                        controller: _subtitleArCtrl,
                        label: 'الوصف العربي',
                      ),
                      const SizedBox(height: 12),
                      _AdminTextField(
                        controller: _bodyArCtrl,
                        label: 'المحتوى العربي',
                        maxLines: 12,
                      ),
                    ],
                  );
                  final right = Column(
                    children: [
                      _AdminTextField(
                        controller: _titleEnCtrl,
                        label: 'English title',
                      ),
                      const SizedBox(height: 12),
                      _AdminTextField(
                        controller: _subtitleEnCtrl,
                        label: 'English subtitle',
                      ),
                      const SizedBox(height: 12),
                      _AdminTextField(
                        controller: _bodyEnCtrl,
                        label: 'English body',
                        maxLines: 12,
                      ),
                    ],
                  );

                  if (stacked) {
                    return Column(
                      children: [left, const SizedBox(height: 16), right],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: left),
                      const SizedBox(width: 16),
                      Expanded(child: right),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        PwfAdminSectionCard(
          title: 'ملاحظات إغلاق Batch A',
          subtitle:
              'هذه الصفحات هي أول دفعة من مسارات site_pages التي يجب أن تنتقل من workspace وصفي إلى إدارة حقيقية قابلة للحفظ والنشر.',
          child: PwfAdminBulletList(
            items: [
              'الصفحة العامة تقرأ من السجل العالمي للـ slug نفسه عند توفره.',
              'الصفحة الإدارية تحفظ في public.site_pages مباشرة ولا تعتمد على بيانات وهمية.',
              'أي fallback يبقى فقط عند عدم وجود سجل فعلي بعد، وليس كبديل دائم عن الإدارة.',
            ],
          ),
        ),
      ],
    );
  }
}

class _CmsPageSeed {
  const _CmsPageSeed({
    required this.titleAr,
    required this.titleEn,
    required this.subtitleAr,
    required this.subtitleEn,
    required this.bodyAr,
    required this.bodyEn,
    required this.isPublished,
  });

  final String titleAr;
  final String titleEn;
  final String subtitleAr;
  final String subtitleEn;
  final String bodyAr;
  final String bodyEn;
  final bool isPublished;

  factory _CmsPageSeed.fromPage(PwfSitePage page) {
    return _CmsPageSeed(
      titleAr: page.titleAr,
      titleEn: page.titleEn,
      subtitleAr: page.subtitleAr,
      subtitleEn: page.subtitleEn,
      bodyAr: page.bodyAr,
      bodyEn: page.bodyEn,
      isPublished: page.isPublished,
    );
  }
}

_CmsPageSeed _seedForConfig(PwfPublicPageAdminConfig config) {
  switch (config.pageSlug) {
    case 'about':
      return const _CmsPageSeed(
        titleAr: 'عن الوزارة',
        titleEn: 'About the Ministry',
        subtitleAr: 'نبذة تعريفية ورسالة الوزارة وأهدافها الأساسية',
        subtitleEn: 'Overview, mission, and core objectives',
        bodyAr:
            '## نبذة\nتتولى وزارة الأوقاف والشؤون الدينية إدارة شؤون الأوقاف وخدمة المساجد وتنظيم أعمال الزكاة والصدقات والإشراف على التعليم الشرعي والوعظ والإرشاد.\n\n## الأهداف\n- حماية الأوقاف وتنميتها وتعظيم منفعتها العامة.\n- خدمة المساجد وتطوير إدارتها وصيانتها.\n- تطوير منظومة التعليم الشرعي والوعظ والإرشاد.\n- تعزيز الشفافية والتحول الرقمي في خدمات الوزارة.',
        bodyEn:
            '## Overview\nThe Ministry of Awqaf and Religious Affairs manages awqaf affairs, supports mosques, organizes zakat and charity work, and oversees religious education and guidance.\n\n## Objectives\n- Protect and develop awqaf assets.\n- Support mosques and improve their management.\n- Advance religious education and outreach.\n- Strengthen transparency and digital transformation.',
        isPublished: true,
      );
    case 'minister':
      return const _CmsPageSeed(
        titleAr: 'كلمة الوزير',
        titleEn: "Minister's Message",
        subtitleAr: 'رسالة توجيهية حول دور الوزارة وأولويات العمل',
        subtitleEn: 'A guiding message on the ministry role and priorities',
        bodyAr:
            '## الرسالة\nنسعى في وزارة الأوقاف والشؤون الدينية إلى صون الأمانة وتعظيم أثر الوقف لخدمة المجتمع، وتعزيز دور المساجد، وتطوير خدماتنا وفق منهجية مؤسسية شفافة.\n\n## أولويات العمل\n- حوكمة إدارة الأوقاف وتحديث بياناتها.\n- تطوير خدمات المواطنين والبوابات الإلكترونية.\n- تمكين المديريات وتعزيز التكامل بين الأنظمة.',
        bodyEn:
            '## Message\nThe ministry seeks to safeguard this trust, maximize the impact of awqaf for society, strengthen the role of mosques, and modernize services through transparent institutional work.\n\n## Priorities\n- Govern awqaf management and modernize data.\n- Improve citizen services and portals.\n- Empower directorates and strengthen system integration.',
        isPublished: true,
      );
    case 'vision-mission':
      return const _CmsPageSeed(
        titleAr: 'الرؤية والرسالة',
        titleEn: 'Vision & Mission',
        subtitleAr: 'إطار العمل المؤسسي والقيم الحاكمة',
        subtitleEn: 'Institutional framework and guiding values',
        bodyAr:
            '## الرؤية\nأوقاف مستدامة وخدمات دينية رائدة تعزز التنمية المجتمعية وتحفظ الهوية.\n\n## الرسالة\nإدارة الأوقاف وتنميتها بكفاءة وشفافية، ودعم المساجد والأنشطة الدينية، وتطوير الخدمات للمواطنين بالتكامل مع المديريات والجهات الشريكة.\n\n## القيم\n- الأمانة\n- الشفافية\n- العدالة\n- الخدمة العامة\n- الاحترافية',
        bodyEn:
            '## Vision\nSustainable awqaf and leading religious services that enhance community development and preserve identity.\n\n## Mission\nManage and develop awqaf efficiently and transparently, support mosques and religious activities, and improve citizen services in coordination with directorates and partners.\n\n## Values\n- Trust\n- Transparency\n- Fairness\n- Public service\n- Professionalism',
        isPublished: true,
      );
    case 'contact':
      return const _CmsPageSeed(
        titleAr: 'اتصل بنا',
        titleEn: 'Contact Us',
        subtitleAr: 'قنوات التواصل الرسمية المعتمدة مع الوزارة',
        subtitleEn: 'Official communication channels with the ministry',
        bodyAr:
            'يمكنك من خلال هذه الصفحة الوصول إلى قنوات التواصل الرسمية المعتمدة، واستخدام البيانات المنشورة للاتصال أو الانتقال إلى نظام الشكاوى والمتابعة عند الحاجة.',
        bodyEn:
            'Use this page to access the approved communication channels, contact the ministry, or move to the complaints service when an official follow-up is needed.',
        isPublished: true,
      );
    case 'privacy':
      return const _CmsPageSeed(
        titleAr: 'سياسة الخصوصية',
        titleEn: 'Privacy Policy',
        subtitleAr: 'مبادئ التعامل مع البيانات عبر البوابة العامة',
        subtitleEn: 'Data handling principles across the public portal',
        bodyAr:
            '## النطاق\nتوضح هذه الصفحة كيفية التعامل مع البيانات العامة ورسائل النماذج والاستعلامات المقدمة عبر البوابة العامة.\n\n## الالتزام\n- حماية البيانات ضمن الحدود القانونية والتنظيمية.\n- عدم مشاركة البيانات مع جهات غير مخولة.\n- استخدام البيانات لتحسين الخدمة العامة والمتابعة الإدارية فقط.',
        bodyEn:
            '## Scope\nThis page explains how public data, form messages, and inquiries submitted through the portal are handled.\n\n## Commitment\n- Protect data within legal and administrative boundaries.\n- Do not share data with unauthorized parties.\n- Use data only for service improvement and administrative follow-up.',
        isPublished: true,
      );
    case 'terms':
      return const _CmsPageSeed(
        titleAr: 'شروط الاستخدام',
        titleEn: 'Terms of Use',
        subtitleAr: 'القواعد العامة للاستفادة من بوابة الوزارة وخدماتها العامة',
        subtitleEn: 'General rules for using the ministry portal and services',
        bodyAr:
            '## الاستخدام المقبول\n- استخدام البوابة للأغراض المشروعة فقط.\n- عدم إساءة استخدام النماذج أو الخدمات العامة.\n- الالتزام بصحة البيانات المرسلة عبر النماذج العامة.\n\n## العلاقة مع الخصوصية\nترتبط هذه الصفحة بسياسة الخصوصية وبالقواعد الحاكمة لاستخدام بوابة الوزارة وخدماتها العامة.',
        bodyEn:
            '## Acceptable use\n- Use the portal for lawful purposes only.\n- Do not misuse public forms or services.\n- Ensure the accuracy of submitted information.\n\n## Relationship with privacy\nThis page works together with the privacy policy and the governing rules of using the ministry public portal.',
        isPublished: true,
      );
    case 'sitemap':
      return const _CmsPageSeed(
        titleAr: 'خريطة الموقع',
        titleEn: 'Site Map',
        subtitleAr: 'دليل سريع للمسارات العامة والخدمات الأساسية داخل المنصة',
        subtitleEn:
            'A quick guide to public routes and essential platform services',
        bodyAr:
            'تجمع هذه الصفحة أهم الروابط العامة والخدمات الأساسية حتى يصل المستخدم إلى المسار الصحيح بسرعة، وتُراجع دوريًا مع أي تحديث على القوائم العامة أو الخدمات المنشورة.',
        bodyEn:
            'This page gathers the most important public links and essential platform services so users can reach the correct route quickly. It should be reviewed whenever public menus or services are updated.',
        isPublished: true,
      );
    case 'services':
      return const _CmsPageSeed(
        titleAr: 'الخدمات',
        titleEn: 'Services',
        subtitleAr: 'بوابة الخدمات العامة والمسارات الرسمية المرتبطة بها',
        subtitleEn: 'Public services gateway and official related routes',
        bodyAr: '''## بوابة الخدمات
تعرض هذه الصفحة المدخل الموحد للخدمات العامة التي تقدمها الوزارة عبر المنصة، مع إبراز الروابط الحقيقية فقط وتجنب أي مسارات غير مكتملة.

## ضوابط العرض
- إظهار الخدمات الجاهزة فعليًا فقط.
- الحفاظ على تصنيف واضح بين الخدمات العامة والخدمات الإلكترونية.
- ربط كل بطاقة أو زر بمسار حقيقي داخل المنصة أو رابط خارجي معتمد.''',
        bodyEn: '''## Services gateway
This page presents a unified entry point for the ministry public services available through the platform, while showing only real routes and avoiding unfinished paths.

## Display rules
- Show only truly available services.
- Keep a clear distinction between public services and e-services.
- Every card or action must point to a real internal route or an approved external link.''',
        isPublished: true,
      );
    case 'eservices':
      return const _CmsPageSeed(
        titleAr: 'الخدمات الإلكترونية',
        titleEn: 'E-Services',
        subtitleAr: 'بوابة الخدمات الرقمية والنماذج الإلكترونية المعتمدة',
        subtitleEn: 'Gateway to approved digital services and electronic forms',
        bodyAr: '''## الخدمات الإلكترونية
تمثل هذه الصفحة بوابة الوصول إلى الخدمات والنماذج الرقمية التي تم اعتمادها داخل المنصة.

## ضوابط النشر
- لا تُعرض أي خدمة إلكترونية قبل اكتمال مسارها الفعلي.
- يجب أن يبقى الربط بين الصفحة وبين بطاقات البوابة الإلكترونية حقيقيًا ومباشرًا.
- تُراجع الروابط دوريًا لضمان عملها وعدم إحالة المستخدم إلى صفحات وهمية.''',
        bodyEn: '''## E-services
This page acts as the gateway to approved digital services and electronic forms available on the platform.

## Publishing rules
- No e-service should be shown before its real route is complete.
- The page must stay directly linked with the actual portal cards and routes.
- Links should be reviewed regularly to avoid broken or placeholder destinations.''',
        isPublished: true,
      );
    default:
      return _CmsPageSeed(
        titleAr: config.title,
        titleEn: config.title,
        subtitleAr: config.subtitle,
        subtitleEn: config.subtitle,
        bodyAr: '',
        bodyEn: '',
        isPublished: true,
      );
  }
}
