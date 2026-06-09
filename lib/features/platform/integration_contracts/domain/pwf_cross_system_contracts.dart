/// Platform-side cross-system integration contracts.
///
/// This file is declarative and read-only. It defines what the platform may
/// reference across systems after a system publishes an approved integration
/// contract. It does not mutate waqf_assets, cases, tasks, billing, assistant,
/// document_intelligence, or mustakshif data.
class PwfCrossSystemIntegrationContracts {
  const PwfCrossSystemIntegrationContracts._();

  static const titleAr = 'عقود الربط بين الأنظمة';
  static const judgment =
      'contract-aligned / read-only / no source-of-truth mutation';
  static const anchorRuleAr =
      'waqf_asset_id هو مرساة الربط المستقبلية بعد جاهزية awqaf_system، مع بقاء كل نظام مالكًا لمنطقه الداخلي.';

  static const forbiddenPlatformActions = <String>[
    'إنشاء أو اعتماد أصول وقفية من جهة المنصة العامة',
    'إنشاء روابط قطع سيادية أو قرارات تكرار من جهة المنصة العامة',
    'تعديل منطق awqaf_system أو waqf_assets review workflow',
    'تحويل mustakshif إلى Master Data أو مصدر سيادي للأصل',
    'خلط خدمات العقارات الوقفية مع كتالوج خدمات الجمهور',
    'نشر أصول غير معتمدة على الواجهة العامة أو الخريطة العامة',
  ];

  static const allowedPlatformActions = <String>[
    'تسجيل route/sidebar/dashboard entry لعقد الربط فقط',
    'عرض status/readiness من عقود الأنظمة دون تعديل بياناتها',
    'ربط read-only references بعد اعتماد العقد من النظام المالك',
    'تمرير waqf_asset_id كمرجع خارجي لا كمصدر إنشاء أو اعتماد',
    'تطبيق RBAC على مستوى المنصة دون تجاوز RBAC/RLS الداخلي للنظام المالك',
    'توثيق UAT والجداول المطلوبة قبل أي ربط تشغيلي موسع',
  ];

  static const systems = <PwfSystemContract>[
    PwfSystemContract(
      key: 'awqaf_system',
      titleAr: 'awqaf_system / waqf_assets',
      ownerAr: 'مشروع awqaf_system',
      anchorField: 'waqf_asset_id',
      currentState: 'review_ready_for_platform_intake',
      platformMode: 'integration-intake only',
      allowedReferences: <String>[
        'read-only intake page',
        'contract alignment',
        'dashboard readiness summary',
        'RBAC permission mapping after awqaf_system approval',
      ],
      blockedReferences: <String>[
        'draft asset creation',
        'asset approval',
        'duplicate decision',
        'parcel link creation',
        'public visibility decision',
      ],
      requiredGate:
          'integration_ready from awqaf_system before operational links',
    ),
    PwfSystemContract(
      key: 'document_intelligence',
      titleAr: 'مركز الوثائق والذكاء الوثائقي',
      ownerAr: 'document_intelligence',
      anchorField: 'document_id + candidate waqf_asset_id',
      currentState: 'linking-ready except sovereign asset finalization',
      platformMode: 'evidence/reference linking',
      allowedReferences: <String>[
        'ربط وثيقة كدليل أو مرجع بأصل وقفي معتمد أو مسودة مراجعة',
        'تمرير citation/evidence إلى assistant أو cases',
        'إبقاء sovereign linking مؤجلًا عند غياب أصل معتمد',
      ],
      blockedReferences: <String>[
        'تحويل الوثيقة إلى أصل معتمد تلقائيًا',
        'استبدال قرار awqaf_system review workflow',
      ],
      requiredGate:
          'approved/candidate asset contract and evidence confidence policy',
    ),
    PwfSystemContract(
      key: 'cases',
      titleAr: 'نظام القضايا',
      ownerAr: 'cases',
      anchorField: 'waqf_asset_id',
      currentState: 'contract-planned',
      platformMode: 'case references after asset contract approval',
      allowedReferences: <String>[
        'ربط قضية بأصل وقفي معتمد أو مرشح مراجعة بحسب الصلاحيات',
        'عرض عدد القضايا المرتبطة في dashboard read-only',
        'فتح task follow-up من القضية دون تعديل الأصل',
      ],
      blockedReferences: <String>[
        'تغيير حالة الأصل من صفحة القضية',
        'نشر بيانات حساسة للقضية على الواجهة العامة',
      ],
      requiredGate: 'case privacy/RBAC + approved asset visibility policy',
    ),
    PwfSystemContract(
      key: 'tasks',
      titleAr: 'نظام المهام',
      ownerAr: 'tasks',
      anchorField: 'waqf_asset_id / case_id / document_id',
      currentState: 'contract-planned',
      platformMode: 'follow-up references',
      allowedReferences: <String>[
        'إنشاء مهمة متابعة تشير إلى أصل/وثيقة/قضية دون تعديل المصدر',
        'عرض مؤشرات المهام حسب النظام والمالك والصلاحية',
        'استدعاء route آمن لصفحة المهمة',
      ],
      blockedReferences: <String>[
        'اعتبار إغلاق مهمة اعتمادًا سياديًا للأصل',
        'تجاوز RBAC الخاص بالنظام المرتبط',
      ],
      requiredGate: 'task scope mapping and system/action permission matrix',
    ),
    PwfSystemContract(
      key: 'billing_system',
      titleAr: 'النظام المالي والدفع',
      ownerAr: 'billing_system',
      anchorField: 'waqf_asset_id + ledger/account reference',
      currentState: 'deferred / compliance-first',
      platformMode:
          'financial reference only until provider/compliance readiness',
      allowedReferences: <String>[
        'ربط مستحق أو عقد بأصل معتمد فقط',
        'عرض حالة مالية read-only للجهات المخولة',
        'الاحتفاظ بالدفاتر والحسابات داخل billing_system',
      ],
      blockedReferences: <String>[
        'تحصيل أو دفع إنتاجي بلا compliance/provider approval',
        'خلط خدمات الوقف العقارية مع public.services catalog',
      ],
      requiredGate:
          'financial compliance + provider integration + approved asset contract',
    ),
    PwfSystemContract(
      key: 'assistant',
      titleAr: 'المساعد الداخلي والشات العام',
      ownerAr: 'assistant',
      anchorField: 'citations + scoped references',
      currentState: 'scoped-knowledge integration',
      platformMode: 'knowledge/reference only',
      allowedReferences: <String>[
        'إجابة مبنية على وثائق أو عقود مصرح بها حسب الدور',
        'عرض citations وروابط داخلية دون كشف غير مصرح',
        'تمييز المساعد الداخلي عن الشات العام',
      ],
      blockedReferences: <String>[
        'تنفيذ قرارات اعتماد أو تعديل بيانات سيادية',
        'كشف أصول غير عامة أو قضايا/وثائق داخلية للجمهور',
      ],
      requiredGate:
          'assistant scope policy + public/private knowledge separation',
    ),
    PwfSystemContract(
      key: 'mustakshif',
      titleAr: 'المستكشف / Mustakshif',
      ownerAr: 'mustakshif',
      anchorField: 'spatial feature reference + waqf_asset_id when approved',
      currentState: 'spatial-analysis only',
      platformMode: 'read-only spatial analysis',
      allowedReferences: <String>[
        'تحليل مكاني وخرائطي للأصول المعتمدة أو المرشحة حسب الصلاحيات',
        'مطابقة مكانية كمؤشر مراجعة لا كقرار سيادي',
        'عرض evidence snapshot عند وجود صلاحية',
      ],
      blockedReferences: <String>[
        'اعتبار mustakshif مصدر Master Data',
        'تعديل أصل أو إنشاء link سيادي من الخريطة مباشرة',
      ],
      requiredGate:
          'spatial read-only contract and map/public visibility policy',
    ),
  ];
}

class PwfSystemContract {
  const PwfSystemContract({
    required this.key,
    required this.titleAr,
    required this.ownerAr,
    required this.anchorField,
    required this.currentState,
    required this.platformMode,
    required this.allowedReferences,
    required this.blockedReferences,
    required this.requiredGate,
  });

  final String key;
  final String titleAr;
  final String ownerAr;
  final String anchorField;
  final String currentState;
  final String platformMode;
  final List<String> allowedReferences;
  final List<String> blockedReferences;
  final String requiredGate;
}
