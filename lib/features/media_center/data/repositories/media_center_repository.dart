import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/media_center_models.dart';

class MediaCenterRepository {
  const MediaCenterRepository(this._client);

  final SupabaseClient _client;

  Future<MediaCenterDashboardState> loadDashboardState() async {
    var remoteReadinessAvailable = true;
    var remoteFamiliesAvailable = true;
    var remoteWorkflowAvailable = true;
    var remoteRuntimeChecksAvailable = true;
    var remoteRolesAvailable = true;
    var remotePublishingRulesAvailable = true;
    var remoteGovernanceReadinessAvailable = true;
    var remotePermissionUatAvailable = true;
    var remoteEditorialEventsAvailable = true;
    String? noticeAr;

    var readinessStages = _fallbackReadiness;
    var families = _localFamilies;
    var editorialWorkflow = _fallbackEditorialWorkflow;
    var runtimeUxChecks = _fallbackRuntimeUxChecks;
    var editorialRoles = _fallbackEditorialRoles;
    var publishingRules = _fallbackPublishingRules;
    var governanceReadiness = _fallbackGovernanceReadiness;
    var permissionUatScenarios = _fallbackPermissionUatScenarios;
    var editorialDecisionEvents =
        const <MediaCenterEditorialDecisionEventSummary>[];

    try {
      final result = await _client.rpc('rpc_media_center_readiness_v1');
      final rows = _asRows(result);
      if (rows.isNotEmpty) {
        readinessStages = rows
            .map(MediaCenterReadinessStage.fromJson)
            .toList(growable: false);
      }
    } catch (_) {
      remoteReadinessAvailable = false;
    }

    try {
      final result = await _client.rpc('rpc_media_center_family_registry_v1');
      final rows = _asRows(result);
      if (rows.isNotEmpty) {
        families = rows
            .map(MediaCenterFamilySummary.fromJson)
            .toList(growable: false);
      }
    } catch (_) {
      remoteFamiliesAvailable = false;
    }

    try {
      final result = await _client.rpc(
        'rpc_media_center_editorial_workflow_v1',
      );
      final rows = _asRows(result);
      if (rows.isNotEmpty) {
        editorialWorkflow = rows
            .map(MediaCenterEditorialWorkflowStep.fromJson)
            .toList(growable: false);
      }
    } catch (_) {
      remoteWorkflowAvailable = false;
    }

    try {
      final result = await _client.rpc('rpc_media_center_runtime_ux_checks_v1');
      final rows = _asRows(result);
      if (rows.isNotEmpty) {
        runtimeUxChecks = rows
            .map(MediaCenterRuntimeUxCheck.fromJson)
            .toList(growable: false);
      }
    } catch (_) {
      remoteRuntimeChecksAvailable = false;
    }

    try {
      final result = await _client.rpc(
        'rpc_media_center_editorial_roles_matrix_v1',
      );
      final rows = _asRows(result);
      if (rows.isNotEmpty) {
        editorialRoles = rows
            .map(MediaCenterEditorialRoleCapability.fromJson)
            .toList(growable: false);
      }
    } catch (_) {
      remoteRolesAvailable = false;
    }

    try {
      final result = await _client.rpc(
        'rpc_media_center_publishing_governance_rules_v1',
      );
      final rows = _asRows(result);
      if (rows.isNotEmpty) {
        publishingRules = rows
            .map(MediaCenterPublishingGovernanceRule.fromJson)
            .toList(growable: false);
      }
    } catch (_) {
      remotePublishingRulesAvailable = false;
    }

    try {
      final result = await _client.rpc(
        'rpc_media_center_publishing_governance_readiness_v1',
      );
      final rows = _asRows(result);
      if (rows.isNotEmpty) {
        governanceReadiness = rows
            .map(MediaCenterGovernanceReadinessStage.fromJson)
            .toList(growable: false);
      }
    } catch (_) {
      remoteGovernanceReadinessAvailable = false;
    }

    try {
      final result = await _client.rpc(
        'rpc_media_center_live_user_permission_uat_v1',
      );
      final rows = _asRows(result);
      if (rows.isNotEmpty) {
        permissionUatScenarios = rows
            .map(MediaCenterPermissionUatScenario.fromJson)
            .toList(growable: false);
      }
    } catch (_) {
      remotePermissionUatAvailable = false;
    }

    try {
      final result = await _client.rpc(
        'rpc_media_center_editorial_decision_events_summary_v1',
      );
      final rows = _asRows(result);
      if (rows.isNotEmpty) {
        editorialDecisionEvents = rows
            .map(MediaCenterEditorialDecisionEventSummary.fromJson)
            .toList(growable: false);
      }
    } catch (_) {
      remoteEditorialEventsAvailable = false;
    }

    if (!remoteReadinessAvailable ||
        !remoteFamiliesAvailable ||
        !remoteWorkflowAvailable ||
        !remoteRuntimeChecksAvailable ||
        !remoteRolesAvailable ||
        !remotePublishingRulesAvailable ||
        !remoteGovernanceReadinessAvailable ||
        !remotePermissionUatAvailable ||
        !remoteEditorialEventsAvailable) {
      noticeAr =
          'بعض RPC الخاصة بالمركز الإعلامي غير مفعلة بعد. طبّق آخر migrations ثم حدّث الصفحة؛ تعرض اللوحة الآن عقود fallback محلية لا تكسر التشغيل.';
    }

    return MediaCenterDashboardState(
      readinessStages: readinessStages,
      families: families,
      editorialWorkflow: editorialWorkflow,
      runtimeUxChecks: runtimeUxChecks,
      editorialRoles: editorialRoles,
      publishingRules: publishingRules,
      governanceReadiness: governanceReadiness,
      permissionUatScenarios: permissionUatScenarios,
      editorialDecisionEvents: editorialDecisionEvents,
      remoteReadinessAvailable: remoteReadinessAvailable,
      remoteFamiliesAvailable: remoteFamiliesAvailable,
      remoteWorkflowAvailable: remoteWorkflowAvailable,
      remoteRuntimeChecksAvailable: remoteRuntimeChecksAvailable,
      remoteRolesAvailable: remoteRolesAvailable,
      remotePublishingRulesAvailable: remotePublishingRulesAvailable,
      remoteGovernanceReadinessAvailable: remoteGovernanceReadinessAvailable,
      remotePermissionUatAvailable: remotePermissionUatAvailable,
      remoteEditorialEventsAvailable: remoteEditorialEventsAvailable,
      noticeAr: noticeAr,
    );
  }

  List<Map<String, dynamic>> _asRows(dynamic result) {
    if (result is List) {
      return result
          .whereType<Map>()
          .map(
            (row) => row.map((key, value) => MapEntry(key.toString(), value)),
          )
          .toList(growable: false);
    }
    if (result is Map) {
      return <Map<String, dynamic>>[
        result.map((key, value) => MapEntry(key.toString(), value)),
      ];
    }
    return const <Map<String, dynamic>>[];
  }

  static const _localFamilies = <MediaCenterFamilySummary>[
    MediaCenterFamilySummary(
      familyKey: 'news',
      labelAr: 'الأخبار',
      adminRoute: '/admin/media-center/news',
      publicRoute: '/home/news',
      storageOrTableAr:
          'media_center.content_items عبر public.v_media_news_compat_v1',
      statusAr: 'owner-read default؛ legacy public fallback فقط',
      editorialOwnerAr: 'الإعلام المركزي ومديرو الوحدات حسب نطاق النشر',
      runtimeNoteAr:
          'اختبر ظهور أخبار الوزارة في /home/news وأخبار الوحدة داخل صفحة الوحدة.',
    ),
    MediaCenterFamilySummary(
      familyKey: 'announcements',
      labelAr: 'الإعلانات',
      adminRoute: '/admin/media-center/announcements',
      publicRoute: '/home/announcements',
      storageOrTableAr:
          'media_center.content_items عبر public.v_media_announcements_compat_v1',
      statusAr: 'owner-read default؛ legacy public fallback فقط',
      editorialOwnerAr: 'الإعلام المركزي ومديرو الوحدات حسب الصلاحية',
      runtimeNoteAr: 'اختبر تاريخ النشر والأولوية وحالة الظهور.',
    ),
    MediaCenterFamilySummary(
      familyKey: 'activities',
      labelAr: 'الأنشطة',
      adminRoute: '/admin/media-center/activities',
      publicRoute: '/home/activities',
      storageOrTableAr:
          'media_center.content_items عبر public.v_media_activities_compat_v1',
      statusAr: 'owner-read default؛ legacy public fallback فقط',
      editorialOwnerAr: 'الإعلام المركزي والوحدات',
      runtimeNoteAr: 'اختبر الفصل بين النشاط والفعالية حسب التصنيف التشغيلي.',
    ),
    MediaCenterFamilySummary(
      familyKey: 'events',
      labelAr: 'الفعاليات',
      adminRoute: '/admin/media-center/events',
      publicRoute: '/home/activities',
      storageOrTableAr: 'public.activities مع فلترة mode=events',
      statusAr: 'مرحلة انتقالية دون جدول جديد',
      editorialOwnerAr: 'الإعلام المركزي والوحدات',
      runtimeNoteAr:
          'لا تنشئ جدولًا مستقلًا قبل قرار معماري؛ استخدم الفلترة الحالية.',
    ),
    MediaCenterFamilySummary(
      familyKey: 'photos',
      labelAr: 'معرض الصور',
      adminRoute: '/admin/media-center/photos',
      publicRoute: '/home/gallery',
      storageOrTableAr: 'public.media_gallery_items / media-gallery bucket',
      statusAr: 'موجود ومجمع تحت المركز الإعلامي',
      editorialOwnerAr: 'الإعلام المركزي/الوحدة المالكة للصورة',
      runtimeNoteAr: 'اختبر alt text والصورة المصغرة وحقوق النشر قبل النشر.',
    ),
    MediaCenterFamilySummary(
      familyKey: 'videos',
      labelAr: 'الفيديوهات',
      adminRoute: '/admin/media-center/videos',
      publicRoute: '/home/gallery',
      storageOrTableAr: 'public.media_gallery_items / media-gallery bucket',
      statusAr: 'موجود ومجمع تحت المركز الإعلامي',
      editorialOwnerAr: 'الإعلام المركزي/الوحدة المالكة للفيديو',
      runtimeNoteAr: 'اختبر الرابط/المعاينة وملاءمة الوصف قبل النشر.',
    ),
    MediaCenterFamilySummary(
      familyKey: 'breaking_news',
      labelAr: 'الأخبار العاجلة',
      adminRoute: '/admin/media-center/breaking-news',
      publicRoute: '/home',
      storageOrTableAr: 'public.breaking_news',
      statusAr: 'موجود ومجمع تحت المركز الإعلامي',
      editorialOwnerAr: 'الإعلام المركزي فقط أو من يفوضه',
      runtimeNoteAr:
          'اختبر زمن البداية والنهاية وأولوية العرض على الصفحة الرئيسية.',
    ),
    MediaCenterFamilySummary(
      familyKey: 'friday_sermons',
      labelAr: 'خُطب الجمعة',
      adminRoute: '/admin/media-center/friday-sermons',
      publicRoute: '/friday-sermon',
      storageOrTableAr: 'public.friday_sermons',
      statusAr: 'موجود ومجمع تحت المركز الإعلامي',
      editorialOwnerAr: 'الإدارة المختصة بخطب الجمعة',
      runtimeNoteAr: 'اختبر التاريخ والعنوان والملف/النص قبل النشر.',
    ),
    MediaCenterFamilySummary(
      familyKey: 'hero_slider',
      labelAr: 'السلايدر والحملات البصرية',
      adminRoute: '/admin/media-center/hero-slider',
      publicRoute: '/home',
      storageOrTableAr: 'public.hero_slides',
      statusAr: 'مصنف كإعلام بصري/حملات مع بقاء إدارة الصفحة الرئيسية مستقلة',
      editorialOwnerAr: 'الإعلام المركزي/إدارة الصفحة الرئيسية',
      runtimeNoteAr:
          'اختبر الصورة، CTA، وترتيب الشرائح دون كسر إدارة الصفحة الرئيسية.',
    ),
  ];

  static const _fallbackReadiness = <MediaCenterReadinessStage>[
    MediaCenterReadinessStage(
      stageKey: '01_content_sources',
      stageTitleAr: '1. مصادر المركز الإعلامي',
      statusKey: 'closed',
      statusLabelAr: 'مغلق',
      evidenceAr: 'مصادر المحتوى معتمدة دون إنشاء جداول موازية.',
      requiredNextActionAr: 'عدم إنشاء جداول جديدة قبل قرار معماري صريح.',
      isClosed: true,
    ),
    MediaCenterReadinessStage(
      stageKey: '02_sql_rpc',
      stageTitleAr: '2. SQL/RPC',
      statusKey: 'closed',
      statusLabelAr: 'مغلق',
      evidenceAr: 'readiness/family/audit/UAT RPC جاهزة.',
      requiredNextActionAr: 'تطبيق آخر migration عند وجود بيئة Supabase حية.',
      isClosed: true,
    ),
    MediaCenterReadinessStage(
      stageKey: '03_rbac_audit',
      stageTitleAr: '3. RBAC/Audit',
      statusKey: 'closed',
      statusLabelAr: 'مغلق',
      evidenceAr: 'دوال shim جاهزة مع سجل Audit.',
      requiredNextActionAr: 'استبدال shim لاحقًا بمصفوفة RBAC السيادية.',
      isClosed: true,
    ),
    MediaCenterReadinessStage(
      stageKey: '04_admin_navigation',
      stageTitleAr: '4. تجميع التنقل الإداري',
      statusKey: 'closed',
      statusLabelAr: 'مغلق',
      evidenceAr: 'تبويب ومسارات المركز الإعلامي جاهزة.',
      requiredNextActionAr: 'اختبار التنقل بعد أي تعديل routing لاحق.',
      isClosed: true,
    ),
    MediaCenterReadinessStage(
      stageKey: '05_public_unit_contract',
      stageTitleAr: '5. عقد الصفحة الرئيسية والوحدات',
      statusKey: 'preserved',
      statusLabelAr: 'محفوظ',
      evidenceAr: 'عقد الوزارة/الوحدات محفوظ.',
      requiredNextActionAr: 'اختبار العرض العام بعد كل تغيير نشر.',
      isClosed: true,
    ),
    MediaCenterReadinessStage(
      stageKey: '06_uat',
      stageTitleAr: '6. UAT إداري/عام',
      statusKey: 'closed',
      statusLabelAr: 'مغلق',
      evidenceAr: 'UAT مغلق عبر Audit Evidence في baseline السابق.',
      requiredNextActionAr: 'إعادة UAT بعد أي تغيير تشغيلي جديد.',
      isClosed: true,
    ),
  ];

  static const _fallbackEditorialWorkflow = <MediaCenterEditorialWorkflowStep>[
    MediaCenterEditorialWorkflowStep(
      stepKey: 'draft',
      titleAr: 'مسودة',
      statusKey: 'draft',
      descriptionAr:
          'إدخال أولي للمادة مع العنوان والوصف والصورة/الملف والنطاق المؤسسي.',
      allowedActionsAr: 'حفظ، معاينة، إرسال للمراجعة',
      requiredEvidenceAr: 'مصدر المادة، الوحدة المالكة، وحالة الظهور.',
      isRequired: true,
    ),
    MediaCenterEditorialWorkflowStep(
      stepKey: 'review',
      titleAr: 'مراجعة تحريرية',
      statusKey: 'in_review',
      descriptionAr:
          'مراجعة اللغة، التصنيف، الملكية، التاريخ، والصورة قبل الاعتماد.',
      allowedActionsAr: 'قبول، إعادة للمحرر، رفض',
      requiredEvidenceAr: 'قرار مراجع وسجل Audit.',
      isRequired: true,
    ),
    MediaCenterEditorialWorkflowStep(
      stepKey: 'approved',
      titleAr: 'اعتماد',
      statusKey: 'approved',
      descriptionAr:
          'اعتماد المادة للنشر ضمن نطاق الوزارة أو الوحدة دون خلط الملكية.',
      allowedActionsAr: 'نشر، جدولة، إلغاء اعتماد',
      requiredEvidenceAr: 'معتمد نهائيًا مع اسم/صلاحية المراجع.',
      isRequired: true,
    ),
    MediaCenterEditorialWorkflowStep(
      stepKey: 'published',
      titleAr: 'نشر',
      statusKey: 'published',
      descriptionAr:
          'ظهور المادة في المسار العام أو صفحة الوحدة وفق العقد الحاكم.',
      allowedActionsAr: 'إخفاء، تحديث، أرشفة',
      requiredEvidenceAr: 'رابط عام أو route تحقق.',
      isRequired: true,
    ),
    MediaCenterEditorialWorkflowStep(
      stepKey: 'archived',
      titleAr: 'أرشفة',
      statusKey: 'archived',
      descriptionAr: 'حفظ المادة خارج الظهور النشط مع إبقاء أثرها التدقيقي.',
      allowedActionsAr: 'استعادة، إبقاء مؤرشف',
      requiredEvidenceAr: 'سبب الأرشفة وتاريخها.',
      isRequired: false,
    ),
  ];

  static const _fallbackRuntimeUxChecks = <MediaCenterRuntimeUxCheck>[
    MediaCenterRuntimeUxCheck(
      checkKey: 'admin_hub_navigation',
      titleAr: 'تنقل لوحة المركز الإعلامي',
      statusKey: 'closed',
      statusLabelAr: 'مغلق',
      evidenceAr: 'المسارات الإدارية مجمعة تحت /admin/media-center/*.',
      requiredNextActionAr:
          'اختبار النقر من الشريط الجانبي بعد أي تعديل routes.',
      isClosed: true,
    ),
    MediaCenterRuntimeUxCheck(
      checkKey: 'public_unit_contract',
      titleAr: 'عقد الوزارة والوحدات',
      statusKey: 'closed',
      statusLabelAr: 'مغلق',
      evidenceAr:
          'الوزارة للصفحة الرئيسية، والوحدة لصفحة الوحدة، مع عرض مختصر متبادل.',
      requiredNextActionAr: 'اختبار /home و/:unitSlug بعد كل تغيير عرض.',
      isClosed: true,
    ),
    MediaCenterRuntimeUxCheck(
      checkKey: 'editorial_audit',
      titleAr: 'أثر التحرير والمراجعة',
      statusKey: 'workflow_ready',
      statusLabelAr: 'جاهز',
      evidenceAr:
          'تم توفير RPC لسجل القرارات التحريرية دون إنشاء جداول محتوى موازية.',
      requiredNextActionAr:
          'تسجيل حدث تحرير عند أول اعتماد فعلي لمادة إعلامية.',
      isClosed: true,
    ),
  ];

  static const _fallbackEditorialRoles = <MediaCenterEditorialRoleCapability>[
    MediaCenterEditorialRoleCapability(
      roleKey: 'media_viewer',
      labelAr: 'مشاهد إعلامي',
      descriptionAr: 'قراءة ومتابعة مواد المركز الإعلامي دون تعديل أو نشر.',
      scopeKey: 'all',
      scopeLabelAr: 'قراءة عامة داخل صلاحيات اللوحة',
      requiredSystemKey: 'site',
      requiredPermissionKey: 'view',
      canCreateDraft: false,
      canSubmitReview: false,
      canReview: false,
      canApprove: false,
      canPublish: false,
      canSchedule: false,
      canArchive: false,
      canCrossPublish: false,
      sovereigntyNoteAr: 'قراءة فقط ولا تمنح صلاحية نشر أو تعديل.',
      isActive: true,
      sortOrder: 10,
    ),
    MediaCenterEditorialRoleCapability(
      roleKey: 'media_contributor',
      labelAr: 'محرر مسودة',
      descriptionAr:
          'إنشاء مسودات وإرسالها للمراجعة ضمن نطاق الوزارة أو الوحدة.',
      scopeKey: 'unit_or_ministry',
      scopeLabelAr: 'وزارة/وحدة حسب التفويض',
      requiredSystemKey: 'site',
      requiredPermissionKey: 'create',
      canCreateDraft: true,
      canSubmitReview: true,
      canReview: false,
      canApprove: false,
      canPublish: false,
      canSchedule: false,
      canArchive: false,
      canCrossPublish: false,
      sovereigntyNoteAr:
          'لا يستطيع النشر أو الرفع للصفحة الرئيسية دون مراجعة واعتماد.',
      isActive: true,
      sortOrder: 20,
    ),
    MediaCenterEditorialRoleCapability(
      roleKey: 'unit_media_editor',
      labelAr: 'محرر وحدة',
      descriptionAr:
          'تحرير محتوى الوحدة ومراجعته داخل صفحة الوحدة دون امتلاك نشر الصفحة الرئيسية.',
      scopeKey: 'unit',
      scopeLabelAr: 'نطاق الوحدة',
      requiredSystemKey: 'site',
      requiredPermissionKey: 'update',
      canCreateDraft: true,
      canSubmitReview: true,
      canReview: true,
      canApprove: false,
      canPublish: false,
      canSchedule: false,
      canArchive: true,
      canCrossPublish: false,
      sovereigntyNoteAr:
          'محتوى الوحدة يبقى مملوكًا للوحدة ولا ينتقل للصفحة الرئيسية إلا بقرار مركزي.',
      isActive: true,
      sortOrder: 30,
    ),
    MediaCenterEditorialRoleCapability(
      roleKey: 'central_media_reviewer',
      labelAr: 'مراجع إعلام مركزي',
      descriptionAr: 'مراجعة واعتماد جودة وملكية المواد قبل النشر أو الإبراز.',
      scopeKey: 'ministry',
      scopeLabelAr: 'نطاق الوزارة',
      requiredSystemKey: 'site',
      requiredPermissionKey: 'manageSite',
      canCreateDraft: true,
      canSubmitReview: true,
      canReview: true,
      canApprove: true,
      canPublish: false,
      canSchedule: false,
      canArchive: true,
      canCrossPublish: false,
      sovereigntyNoteAr:
          'الاعتماد لا يعني النشر النهائي ما لم يملك المستخدم صلاحية النشر.',
      isActive: true,
      sortOrder: 40,
    ),
    MediaCenterEditorialRoleCapability(
      roleKey: 'central_publisher',
      labelAr: 'ناشر مركزي',
      descriptionAr:
          'نشر وجدولة وأرشفة مواد الوزارة والمواد المعتمدة للإبراز العام.',
      scopeKey: 'ministry',
      scopeLabelAr: 'الصفحة الرئيسية والوزارة',
      requiredSystemKey: 'site',
      requiredPermissionKey: 'manageHome',
      canCreateDraft: true,
      canSubmitReview: true,
      canReview: true,
      canApprove: true,
      canPublish: true,
      canSchedule: true,
      canArchive: true,
      canCrossPublish: true,
      sovereigntyNoteAr:
          'يمتلك قرار النشر العام مع وجوب تسجيل Audit لكل نشر أو إبراز متبادل.',
      isActive: true,
      sortOrder: 50,
    ),
    MediaCenterEditorialRoleCapability(
      roleKey: 'media_admin',
      labelAr: 'مدير حوكمة الإعلام',
      descriptionAr:
          'إدارة مصفوفة الأدوار وقواعد النشر وربطها بسياسات RBAC السيادية.',
      scopeKey: 'platform',
      scopeLabelAr: 'نطاق المنصة',
      requiredSystemKey: 'platformAdmin',
      requiredPermissionKey: 'manageHome',
      canCreateDraft: true,
      canSubmitReview: true,
      canReview: true,
      canApprove: true,
      canPublish: true,
      canSchedule: true,
      canArchive: true,
      canCrossPublish: true,
      sovereigntyNoteAr:
          'صلاحية حوكمة لا تعني تجاوز ملكية الوزارة/الوحدة أو سجل التدقيق.',
      isActive: true,
      sortOrder: 60,
    ),
  ];

  static const _fallbackPublishingRules = <MediaCenterPublishingGovernanceRule>[
    MediaCenterPublishingGovernanceRule(
      ruleKey: 'ministry_to_home_publish',
      familyKey: 'all',
      sourceScopeKey: 'ministry',
      targetScopeKey: 'home',
      requiredRoleKey: 'central_publisher',
      requiredActionKey: 'publish',
      ruleTitleAr: 'نشر محتوى الوزارة على الصفحة الرئيسية',
      ruleDescriptionAr:
          'المواد الصادرة عن الوزارة تظهر على الصفحة الرئيسية بعد مراجعة واعتماد ونشر مركزي.',
      requiresApproval: true,
      requiresAudit: true,
      conflictPolicyAr: 'تبقى ملكية المحتوى للوزارة ولا تُحوّل إلى وحدة.',
      isActive: true,
      sortOrder: 10,
    ),
    MediaCenterPublishingGovernanceRule(
      ruleKey: 'unit_to_unit_page_publish',
      familyKey: 'news,announcements,activities,events,photos,videos',
      sourceScopeKey: 'unit',
      targetScopeKey: 'unit_page',
      requiredRoleKey: 'unit_media_editor',
      requiredActionKey: 'review',
      ruleTitleAr: 'نشر محتوى الوحدة داخل صفحة الوحدة',
      ruleDescriptionAr:
          'محتوى الوحدة يظهر داخل صفحة الوحدة ولا يظهر في الصفحة الرئيسية إلا عبر إبراز مركزي لاحق.',
      requiresApproval: true,
      requiresAudit: true,
      conflictPolicyAr:
          'لا تُخلط أخبار الوحدة مع أخبار الوزارة في الملكية أو المسؤولية التحريرية.',
      isActive: true,
      sortOrder: 20,
    ),
    MediaCenterPublishingGovernanceRule(
      ruleKey: 'unit_to_home_cross_highlight',
      familyKey: 'news,announcements,activities,events',
      sourceScopeKey: 'unit',
      targetScopeKey: 'home_highlight',
      requiredRoleKey: 'central_publisher',
      requiredActionKey: 'cross_publish',
      ruleTitleAr: 'إبراز مختصر من الوحدة على الصفحة الرئيسية',
      ruleDescriptionAr:
          'يمكن عرض مختصر من أخبار/أنشطة الوحدة على الصفحة الرئيسية مع بقاء الملكية للوحدة وبعد موافقة إعلامية مركزية.',
      requiresApproval: true,
      requiresAudit: true,
      conflictPolicyAr:
          'الإبراز لا يحوّل المصدر إلى الوزارة ولا يغير unit_id/slug.',
      isActive: true,
      sortOrder: 30,
    ),
    MediaCenterPublishingGovernanceRule(
      ruleKey: 'home_to_unit_cross_highlight',
      familyKey: 'news,announcements,activities',
      sourceScopeKey: 'ministry',
      targetScopeKey: 'unit_page_highlight',
      requiredRoleKey: 'central_publisher',
      requiredActionKey: 'cross_publish',
      ruleTitleAr: 'عرض مختصر من الوزارة داخل صفحات الوحدات',
      ruleDescriptionAr:
          'تستطيع صفحة الوحدة عرض مختصر من محتوى الوزارة دون تغيير ملكية المحتوى أو منحه صلاحية تعديل للوحدة.',
      requiresApproval: true,
      requiresAudit: true,
      conflictPolicyAr: 'يبقى المحتوى مركزيًا وتعرضه الوحدة كمرجع عام فقط.',
      isActive: true,
      sortOrder: 40,
    ),
    MediaCenterPublishingGovernanceRule(
      ruleKey: 'breaking_news_central_only',
      familyKey: 'breaking_news',
      sourceScopeKey: 'ministry',
      targetScopeKey: 'home',
      requiredRoleKey: 'central_publisher',
      requiredActionKey: 'publish',
      ruleTitleAr: 'الأخبار العاجلة مركزية',
      ruleDescriptionAr:
          'الأخبار العاجلة لا تنشر إلا من الإعلام المركزي أو مفوضه بسبب أثرها المباشر على الواجهة العامة.',
      requiresApproval: true,
      requiresAudit: true,
      conflictPolicyAr:
          'لا تُدار الأخبار العاجلة كوحدة فرعية إلا بتفويض مركزي واضح.',
      isActive: true,
      sortOrder: 50,
    ),
    MediaCenterPublishingGovernanceRule(
      ruleKey: 'hero_slider_visual_campaigns',
      familyKey: 'hero_slider',
      sourceScopeKey: 'ministry',
      targetScopeKey: 'home_visual',
      requiredRoleKey: 'central_publisher',
      requiredActionKey: 'publish',
      ruleTitleAr: 'السلايدر والحملات البصرية',
      ruleDescriptionAr:
          'السلايدر إعلام بصري مرتبط بالصفحة الرئيسية ويخضع للنشر المركزي دون كسر إدارة الصفحة الرئيسية.',
      requiresApproval: true,
      requiresAudit: true,
      conflictPolicyAr:
          'السلايدر ليس جدول محتوى بديلًا ولا يغير ترتيب إدارة الصفحة الرئيسية.',
      isActive: true,
      sortOrder: 60,
    ),
  ];

  static const _fallbackGovernanceReadiness = <MediaCenterGovernanceReadinessStage>[
    MediaCenterGovernanceReadinessStage(
      stageKey: '01_roles_matrix',
      stageTitleAr: '1. مصفوفة الأدوار التحريرية',
      statusKey: 'closed',
      statusLabelAr: 'مغلقة',
      evidenceAr: 'أدوار التحرير والنشر معرفة ومربوطة بمفاتيح صلاحيات المنصة.',
      requiredNextActionAr:
          'اختبار أول مستخدم فعلي مقابل public.has_permission عند تفعيل RBAC كاملًا.',
      isClosed: true,
    ),
    MediaCenterGovernanceReadinessStage(
      stageKey: '02_publishing_rules',
      stageTitleAr: '2. قواعد النشر والملكية',
      statusKey: 'closed',
      statusLabelAr: 'مغلقة',
      evidenceAr:
          'قواعد الوزارة/الوحدة/الإبراز المتبادل معرفة دون إنشاء جداول محتوى جديدة.',
      requiredNextActionAr: 'تسجيل Audit لكل نشر أو إبراز متبادل.',
      isClosed: true,
    ),
    MediaCenterGovernanceReadinessStage(
      stageKey: '03_rbac_bridge',
      stageTitleAr: '3. ربط RBAC السيادي',
      statusKey: 'integrated',
      statusLabelAr: 'مدمج',
      evidenceAr:
          'دالة media_center_can_action_v1 تستخدم is_superuser/has_permission عند توفرها مع fallback آمن.',
      requiredNextActionAr:
          'استبدال fallback بعد اكتمال مصفوفة صلاحيات تفصيلية للمستخدمين.',
      isClosed: true,
    ),
    MediaCenterGovernanceReadinessStage(
      stageKey: '04_audit_enforcement',
      stageTitleAr: '4. إلزام الأثر التدقيقي',
      statusKey: 'closed',
      statusLabelAr: 'مغلق',
      evidenceAr:
          'قواعد النشر تشترط Audit، والقرارات التحريرية تسجل في media_center_editorial_events.',
      requiredNextActionAr: 'تسجيل أول قرار تحريري فعلي بعد تشغيل الواجهة.',
      isClosed: true,
    ),
  ];

  static const _fallbackPermissionUatScenarios = <MediaCenterPermissionUatScenario>[
    MediaCenterPermissionUatScenario(
      scenarioKey: 'viewer_read_dashboard',
      titleAr: 'مشاهد إعلامي يقرأ لوحة المركز',
      roleKey: 'media_viewer',
      actionKey: 'view',
      unitSlug: null,
      expectedAllowed: true,
      actualAllowed: null,
      statusKey: 'pending_live_user',
      statusLabelAr: 'بانتظار مستخدم حي',
      evidenceAr: 'يجب اختبار مستخدم مصادق فعلي لا جلسة SQL Editor.',
      requiredNextActionAr:
          'سجل نتيجة الاختبار عبر rpc_media_center_record_permission_uat_event_v1.',
      isClosed: false,
    ),
    MediaCenterPermissionUatScenario(
      scenarioKey: 'contributor_create_draft',
      titleAr: 'محرر مسودة ينشئ مادة',
      roleKey: 'media_contributor',
      actionKey: 'create_draft',
      unitSlug: null,
      expectedAllowed: true,
      actualAllowed: null,
      statusKey: 'pending_live_user',
      statusLabelAr: 'بانتظار مستخدم حي',
      evidenceAr: 'يتحقق من صلاحية إنشاء المسودة فقط دون نشر.',
      requiredNextActionAr: 'اختبر مستخدم create وسجل النتيجة.',
      isClosed: false,
    ),
    MediaCenterPermissionUatScenario(
      scenarioKey: 'unit_editor_review_unit_content',
      titleAr: 'محرر وحدة يراجع محتوى الوحدة',
      roleKey: 'unit_media_editor',
      actionKey: 'review',
      unitSlug: 'unit-sample',
      expectedAllowed: true,
      actualAllowed: null,
      statusKey: 'pending_live_user',
      statusLabelAr: 'بانتظار مستخدم حي',
      evidenceAr: 'يتحقق من صلاحية المراجعة داخل نطاق الوحدة دون نشر رئيسي.',
      requiredNextActionAr: 'اختبر مستخدم وحدة وسجل unit_slug الصحيح.',
      isClosed: false,
    ),
    MediaCenterPermissionUatScenario(
      scenarioKey: 'central_reviewer_approve',
      titleAr: 'مراجع مركزي يعتمد مادة',
      roleKey: 'central_media_reviewer',
      actionKey: 'approve',
      unitSlug: null,
      expectedAllowed: true,
      actualAllowed: null,
      statusKey: 'pending_live_user',
      statusLabelAr: 'بانتظار مستخدم حي',
      evidenceAr: 'يتحقق من صلاحية الاعتماد عبر manageSite دون نشر نهائي.',
      requiredNextActionAr: 'اختبر مستخدم مراجع مركزي وسجل النتيجة.',
      isClosed: false,
    ),
    MediaCenterPermissionUatScenario(
      scenarioKey: 'central_publisher_publish_home',
      titleAr: 'ناشر مركزي ينشر على الصفحة الرئيسية',
      roleKey: 'central_publisher',
      actionKey: 'publish',
      unitSlug: null,
      expectedAllowed: true,
      actualAllowed: null,
      statusKey: 'pending_live_user',
      statusLabelAr: 'بانتظار مستخدم حي',
      evidenceAr: 'يتحقق من صلاحية manageHome/النشر العام.',
      requiredNextActionAr: 'اختبر مستخدم ناشر مركزي وسجل النتيجة.',
      isClosed: false,
    ),
    MediaCenterPermissionUatScenario(
      scenarioKey: 'unit_editor_cannot_cross_publish_home',
      titleAr: 'محرر وحدة لا يبرز على الصفحة الرئيسية',
      roleKey: 'unit_media_editor',
      actionKey: 'cross_publish',
      unitSlug: 'unit-sample',
      expectedAllowed: false,
      actualAllowed: null,
      statusKey: 'pending_live_user',
      statusLabelAr: 'بانتظار مستخدم حي',
      evidenceAr: 'اختبار منع الإبراز العام دون تفويض مركزي.',
      requiredNextActionAr: 'اختبر مستخدم وحدة وتأكد أن النتيجة مرفوضة.',
      isClosed: false,
    ),
  ];
}
