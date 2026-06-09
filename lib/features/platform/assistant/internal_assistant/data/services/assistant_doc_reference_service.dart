import '../../../assistant_core/data/services/chat_route_context_service.dart';
import '../models/assistant_context.dart';
import '../models/assistant_doc_reference.dart';
import 'assistant_capability_service.dart';

class AssistantDocReferenceService {
  const AssistantDocReferenceService({
    AssistantCapabilityService capabilityService =
        const AssistantCapabilityService(),
  }) : _capabilityService = capabilityService;

  final AssistantCapabilityService _capabilityService;

  static const List<AssistantDocReference> _all = <AssistantDocReference>[
    AssistantDocReference(
      id: 'assistant-phase-plan',
      titleAr: 'خطة مراحل المساعد',
      titleEn: 'Assistant phase plan',
      path: 'docs/admin/ASSISTANT_STACK_PHASE_PLAN_v1.md',
      summaryAr:
          'المرجع التنفيذي الحالي لمراحل تطوير assistant_core وpublic_chatbot وinternal_assistant.',
      summaryEn:
          'Current execution plan for assistant_core, public_chatbot, and internal_assistant.',
      systemKeys: {'all'},
      isGovernance: true,
      isDocsAdmin: true,
    ),
    AssistantDocReference(
      id: 'page-managers-master',
      titleAr: 'مرجع مدراء الصفحات والمستخدمين',
      titleEn: 'Page managers & users master',
      path: 'docs/admin/PALWAKF_ADMIN_PAGE_MANAGERS_USERS_MASTER_MERGED_v2.md',
      summaryAr:
          'مرجع الحوكمة الإداري للصفحات والمستخدمين والصلاحيات والجداول المطلوبة.',
      summaryEn:
          'Administrative governance reference for pages, users, permissions, and required tables.',
      systemKeys: {'awqaf_system', 'all'},
      isGovernance: true,
      isDocsAdmin: true,
    ),
    AssistantDocReference(
      id: 'unit-pages-audit',
      titleAr: 'تنفيذ Unit Pages والأوديت',
      titleEn: 'Unit Pages & audit execution',
      path: 'docs/admin/UNIT_PAGES_PAGE_MANAGERS_AUDIT_EXECUTION.md',
      summaryAr: 'تفاصيل إغلاق Unit Pages وربط مدراء الصفحات والأوديت.',
      summaryEn:
          'Details for Unit Pages closure, page-manager linkage, and audit.',
      systemKeys: {'awqaf_system', 'all'},
      isGovernance: true,
      isDocsAdmin: true,
    ),
    AssistantDocReference(
      id: 'visual-identity-master',
      titleAr: 'الهوية البصرية السيادية',
      titleEn: 'Sovereign visual identity',
      path:
          'docs/visual_identity/PALWAKF_VISUAL_IDENTITY_MASTER_MERGED_V1_1_AR.md',
      summaryAr: 'المرجع الأعلى للعائلات البصرية والسياقات التشغيلية والتوكنز.',
      summaryEn:
          'Top reference for visual families, operational contexts, and tokens.',
      systemKeys: {'all'},
      isDocsVisualIdentity: true,
    ),
    AssistantDocReference(
      id: 'mustakshif-assistant-bridge',
      titleAr: 'جسر المساعد مع مستكشف الوقف',
      titleEn: 'Mustakshif assistant bridge',
      path: 'docs/systems/MUSTAKSHIF_ASSISTANT_BRIDGE_v1.md',
      summaryAr:
          'مرجع يشرح ربط internal_assistant تدريجيًا بمستكشف الوقف مع الحفاظ على سياق الأصل الوقفي والصفحة الحالية.',
      summaryEn:
          'Reference explaining the gradual internal-assistant linkage to Mustakshif while preserving waqf-asset and current page context.',
      systemKeys: {'mustakshif', 'mustakshif_alwaqf', 'all'},
      isDocsSystems: true,
    ),
    AssistantDocReference(
      id: 'systems-readme-master',
      titleAr: 'المرجع الأعلى لدمج الأنظمة',
      titleEn: 'Systems integration master',
      path: 'docs/systems/README_MASTER.md',
      summaryAr: 'المرجع الأعلى لتجهيز الأنظمة الخارجية للاندماج داخل PalWakf.',
      summaryEn:
          'Top reference for preparing external systems to integrate into PalWakf.',
      systemKeys: {
        'mustakshif',
        'waqf_cases_system',
        'billing_system',
        'tasks_system',
        'all',
      },
      isDocsSystems: true,
    ),
    AssistantDocReference(
      id: 'systems-prompt',
      titleAr: 'برومت دمج الأنظمة الخارجية',
      titleEn: 'External systems integration prompt',
      path:
          'docs/systems/PALWAKF_EXTERNAL_SYSTEM_INTEGRATION_MASTER_PROMPT_v1.md',
      summaryAr:
          'تعليمات مؤسسية لتجهيز أي نظام خارجي ليعمل تحت المنصة دون كسرها.',
      summaryEn:
          'Institutional prompt for preparing any external system to work under the platform without breaking it.',
      systemKeys: {
        'mustakshif',
        'waqf_cases_system',
        'billing_system',
        'tasks_system',
        'all',
      },
      isDocsSystems: true,
    ),
    AssistantDocReference(
      id: 'assistant-maturity-closure',
      titleAr: 'إغلاق نضج PalWakf Assistant',
      titleEn: 'PalWakf Assistant maturity closure',
      path: 'docs/assistant/PALWAKF_ASSISTANT_MATURITY_CLOSURE_2026_05_25.md',
      summaryAr:
          'مرجع نضج المساعد القائم: RAG، الاستشهادات، الأدوات، RBAC/RLS، جسر ذكاء الوثائق، مساعد الأصول الوقفية، التقييمات، وبوابة الإنتاج.',
      summaryEn:
          'Maturity reference for the existing assistant: RAG, citations, tools, RBAC/RLS, document intelligence bridge, waqf-assets assistant, evals, and production gate.',
      systemKeys: {'assistant', 'awqaf_system', 'document_intelligence', 'all'},
      isGovernance: true,
      isDocsAdmin: true,
      isDocsSystems: true,
    ),
    AssistantDocReference(
      id: 'systems-required-files',
      titleAr: 'الملفات والمسارات المطلوبة للأنظمة',
      titleEn: 'Required files & paths for systems',
      path:
          'docs/systems/PALWAKF_EXTERNAL_SYSTEM_REQUIRED_FILES_AND_PATHS_v1.md',
      summaryAr:
          'القائمة المعيارية للملفات والمسارات المطلوبة لأي نظام ينضم إلى PalWakf.',
      summaryEn:
          'Standard list of files and paths required for any system joining PalWakf.',
      systemKeys: {
        'mustakshif',
        'waqf_cases_system',
        'billing_system',
        'tasks_system',
        'all',
      },
      isDocsSystems: true,
    ),
  ];

  List<AssistantDocReference> referencesFor(AssistantContext context) {
    final capability = _capabilityService.resolve(context);
    final routeContext = ChatRouteContextService.resolve(
      context.currentRoute,
      fallbackUnitSlug: context.unitSlug ?? context.unitId ?? 'home',
    );

    return _all
        .where((entry) {
          final matchesSystem =
              entry.systemKeys.contains('all') ||
              entry.systemKeys.contains(context.systemKey) ||
              entry.systemKeys.contains(routeContext.systemKey);
          if (!matchesSystem) return false;
          if (entry.isDocsAdmin && !capability.canUseDocsAdmin) return false;
          if (entry.isDocsSystems && !capability.canUseDocsSystems)
            return false;
          if (entry.isDocsVisualIdentity &&
              !capability.canUseVisualIdentityDocs)
            return false;
          if (entry.isGovernance &&
              !capability.canUseRbacGuidance &&
              entry.id == 'page-managers-master')
            return false;
          return true;
        })
        .toList(growable: false);
  }
}
