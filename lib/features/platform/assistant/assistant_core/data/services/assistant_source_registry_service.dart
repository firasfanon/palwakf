import '../models/assistant_context_contract.dart';
import '../models/assistant_source_registry_entry.dart';

class AssistantSourceRegistryService {
  const AssistantSourceRegistryService();

  static const List<AssistantSourceRegistryEntry> _entries =
      <AssistantSourceRegistryEntry>[
        AssistantSourceRegistryEntry(
          id: 'public-site-pages',
          kind: AssistantSourceKind.sitePage,
          labelAr: 'صفحات الموقع العامة',
          labelEn: 'Public site pages',
          ownerSystemKey: 'public_site',
          allowedChannels: {AssistantChannel.publicChatbot},
          allowedSurfaces: {
            AssistantSurface.platformHome,
            AssistantSurface.unitPages,
          },
          allowedScopeKeys: {
            AssistantScopeKey.publicHome,
            AssistantScopeKey.publicUnit,
          },
          isTrusted: true,
          directAnswerAllowed: true,
        ),
        AssistantSourceRegistryEntry(
          id: 'homepage-sections',
          kind: AssistantSourceKind.homepageSection,
          labelAr: 'أقسام الصفحة الرئيسية',
          labelEn: 'Homepage sections',
          ownerSystemKey: 'home_new',
          allowedChannels: {AssistantChannel.publicChatbot},
          allowedSurfaces: {
            AssistantSurface.platformHome,
            AssistantSurface.unitPages,
          },
          allowedScopeKeys: {
            AssistantScopeKey.publicHome,
            AssistantScopeKey.publicUnit,
          },
          isTrusted: true,
          directAnswerAllowed: true,
        ),
        AssistantSourceRegistryEntry(
          id: 'shared-content-news',
          kind: AssistantSourceKind.sharedContent,
          labelAr: 'الأخبار العامة',
          labelEn: 'Public news',
          ownerSystemKey: 'media_center',
          allowedChannels: {AssistantChannel.publicChatbot},
          allowedSurfaces: {
            AssistantSurface.platformHome,
            AssistantSurface.unitPages,
          },
          allowedScopeKeys: {
            AssistantScopeKey.publicHome,
            AssistantScopeKey.publicUnit,
          },
          isTrusted: true,
          directAnswerAllowed: true,
        ),
        AssistantSourceRegistryEntry(
          id: 'shared-content-announcements',
          kind: AssistantSourceKind.sharedContent,
          labelAr: 'الإعلانات العامة',
          labelEn: 'Public announcements',
          ownerSystemKey: 'media_center',
          allowedChannels: {AssistantChannel.publicChatbot},
          allowedSurfaces: {
            AssistantSurface.platformHome,
            AssistantSurface.unitPages,
          },
          allowedScopeKeys: {
            AssistantScopeKey.publicHome,
            AssistantScopeKey.publicUnit,
          },
          isTrusted: true,
          directAnswerAllowed: true,
        ),
        AssistantSourceRegistryEntry(
          id: 'shared-content-activities',
          kind: AssistantSourceKind.sharedContent,
          labelAr: 'الأنشطة العامة',
          labelEn: 'Public activities',
          ownerSystemKey: 'media_center',
          allowedChannels: {AssistantChannel.publicChatbot},
          allowedSurfaces: {
            AssistantSurface.platformHome,
            AssistantSurface.unitPages,
          },
          allowedScopeKeys: {
            AssistantScopeKey.publicHome,
            AssistantScopeKey.publicUnit,
          },
          isTrusted: true,
          directAnswerAllowed: true,
        ),
        AssistantSourceRegistryEntry(
          id: 'friday-sermons',
          kind: AssistantSourceKind.sharedContent,
          labelAr: 'خطب الجمعة',
          labelEn: 'Friday sermons',
          ownerSystemKey: 'media_center',
          allowedChannels: {AssistantChannel.publicChatbot},
          allowedSurfaces: {
            AssistantSurface.platformHome,
            AssistantSurface.unitPages,
          },
          allowedScopeKeys: {
            AssistantScopeKey.publicHome,
            AssistantScopeKey.publicUnit,
          },
          isTrusted: true,
          directAnswerAllowed: true,
        ),
        AssistantSourceRegistryEntry(
          id: 'media-gallery',
          kind: AssistantSourceKind.sharedContent,
          labelAr: 'المعرض الإعلامي',
          labelEn: 'Media gallery',
          ownerSystemKey: 'media_center',
          allowedChannels: {AssistantChannel.publicChatbot},
          allowedSurfaces: {
            AssistantSurface.platformHome,
            AssistantSurface.unitPages,
          },
          allowedScopeKeys: {
            AssistantScopeKey.publicHome,
            AssistantScopeKey.publicUnit,
          },
          isTrusted: true,
          directAnswerAllowed: false,
        ),
        AssistantSourceRegistryEntry(
          id: 'quick-links-and-services',
          kind: AssistantSourceKind.quickLinks,
          labelAr: 'الروابط والخدمات السريعة',
          labelEn: 'Quick links and services',
          ownerSystemKey: 'home_new',
          allowedChannels: {AssistantChannel.publicChatbot},
          allowedSurfaces: {
            AssistantSurface.platformHome,
            AssistantSurface.unitPages,
          },
          allowedScopeKeys: {
            AssistantScopeKey.publicHome,
            AssistantScopeKey.publicUnit,
          },
          isTrusted: true,
          directAnswerAllowed: true,
        ),
        AssistantSourceRegistryEntry(
          id: 'route-context',
          kind: AssistantSourceKind.routeContext,
          labelAr: 'سياق المسار الحالي',
          labelEn: 'Current route context',
          ownerSystemKey: 'assistant_core',
          allowedChannels: {
            AssistantChannel.publicChatbot,
            AssistantChannel.internalAssistant,
          },
          allowedSurfaces: {
            AssistantSurface.platformHome,
            AssistantSurface.unitPages,
            AssistantSurface.systemPages,
            AssistantSurface.adminInternal,
          },
          allowedScopeKeys: {
            AssistantScopeKey.publicHome,
            AssistantScopeKey.publicUnit,
            AssistantScopeKey.internalAdmin,
            AssistantScopeKey.internalSystem,
            AssistantScopeKey.restricted,
          },
          isTrusted: true,
          directAnswerAllowed: true,
        ),
        AssistantSourceRegistryEntry(
          id: 'docs-admin',
          kind: AssistantSourceKind.docsAdmin,
          labelAr: 'وثائق الإدارة الداخلية',
          labelEn: 'Admin docs',
          ownerSystemKey: 'docs_admin',
          allowedChannels: {AssistantChannel.internalAssistant},
          allowedSurfaces: {AssistantSurface.adminInternal},
          allowedScopeKeys: {AssistantScopeKey.internalAdmin},
          isTrusted: true,
          directAnswerAllowed: true,
        ),
        AssistantSourceRegistryEntry(
          id: 'docs-systems',
          kind: AssistantSourceKind.docsSystems,
          labelAr: 'وثائق الأنظمة المندمجة',
          labelEn: 'Systems docs',
          ownerSystemKey: 'docs_systems',
          allowedChannels: {AssistantChannel.internalAssistant},
          allowedSurfaces: {
            AssistantSurface.adminInternal,
            AssistantSurface.systemPages,
          },
          allowedScopeKeys: {
            AssistantScopeKey.internalAdmin,
            AssistantScopeKey.internalSystem,
          },
          isTrusted: true,
          directAnswerAllowed: true,
        ),
        AssistantSourceRegistryEntry(
          id: 'docs-visual-identity',
          kind: AssistantSourceKind.docsVisualIdentity,
          labelAr: 'وثائق الهوية البصرية',
          labelEn: 'Visual identity docs',
          ownerSystemKey: 'docs_visual_identity',
          allowedChannels: {AssistantChannel.internalAssistant},
          allowedSurfaces: {
            AssistantSurface.adminInternal,
            AssistantSurface.systemPages,
          },
          allowedScopeKeys: {
            AssistantScopeKey.internalAdmin,
            AssistantScopeKey.internalSystem,
          },
          isTrusted: true,
          directAnswerAllowed: true,
        ),
        AssistantSourceRegistryEntry(
          id: 'admin-guides',
          kind: AssistantSourceKind.internalGuide,
          labelAr: 'أدلة العمل الداخلية',
          labelEn: 'Internal work guides',
          ownerSystemKey: 'internal_assistant',
          allowedChannels: {AssistantChannel.internalAssistant},
          allowedSurfaces: {AssistantSurface.adminInternal},
          allowedScopeKeys: {AssistantScopeKey.internalAdmin},
          isTrusted: true,
          directAnswerAllowed: true,
        ),
        AssistantSourceRegistryEntry(
          id: 'governance-rbac',
          kind: AssistantSourceKind.governance,
          labelAr: 'RBAC والحوكمة',
          labelEn: 'RBAC and governance',
          ownerSystemKey: 'admin_users',
          allowedChannels: {AssistantChannel.internalAssistant},
          allowedSurfaces: {
            AssistantSurface.adminInternal,
            AssistantSurface.systemPages,
          },
          allowedScopeKeys: {
            AssistantScopeKey.internalAdmin,
            AssistantScopeKey.internalSystem,
            AssistantScopeKey.restricted,
          },
          isTrusted: true,
          directAnswerAllowed: false,
        ),
        AssistantSourceRegistryEntry(
          id: 'system-pages',
          kind: AssistantSourceKind.systemPage,
          labelAr: 'صفحات الأنظمة الداخلية',
          labelEn: 'System pages',
          ownerSystemKey: 'platform',
          allowedChannels: {AssistantChannel.internalAssistant},
          allowedSurfaces: {
            AssistantSurface.systemPages,
            AssistantSurface.adminInternal,
          },
          allowedScopeKeys: {
            AssistantScopeKey.internalAdmin,
            AssistantScopeKey.internalSystem,
          },
          isTrusted: true,
          directAnswerAllowed: true,
        ),
        AssistantSourceRegistryEntry(
          id: 'assistant-rag-index',
          kind: AssistantSourceKind.ragIndex,
          labelAr: 'فهرس RAG المحكوم',
          labelEn: 'Governed RAG index',
          ownerSystemKey: 'assistant',
          allowedChannels: {AssistantChannel.internalAssistant},
          allowedSurfaces: {
            AssistantSurface.adminInternal,
            AssistantSurface.systemPages,
          },
          allowedScopeKeys: {
            AssistantScopeKey.internalAdmin,
            AssistantScopeKey.internalSystem,
          },
          isTrusted: true,
          directAnswerAllowed: false,
          enabledByDefault: false,
        ),
        AssistantSourceRegistryEntry(
          id: 'assistant-citations',
          kind: AssistantSourceKind.ragIndex,
          labelAr: 'استشهادات المساعد',
          labelEn: 'Assistant citations',
          ownerSystemKey: 'assistant',
          allowedChannels: {
            AssistantChannel.publicChatbot,
            AssistantChannel.internalAssistant,
          },
          allowedSurfaces: {
            AssistantSurface.platformHome,
            AssistantSurface.unitPages,
            AssistantSurface.adminInternal,
            AssistantSurface.systemPages,
          },
          allowedScopeKeys: {
            AssistantScopeKey.publicHome,
            AssistantScopeKey.publicUnit,
            AssistantScopeKey.internalAdmin,
            AssistantScopeKey.internalSystem,
          },
          isTrusted: true,
          directAnswerAllowed: false,
          enabledByDefault: false,
        ),
        AssistantSourceRegistryEntry(
          id: 'assistant-tool-registry',
          kind: AssistantSourceKind.toolRegistry,
          labelAr: 'سجل أدوات المساعد',
          labelEn: 'Assistant tool registry',
          ownerSystemKey: 'assistant',
          allowedChannels: {AssistantChannel.internalAssistant},
          allowedSurfaces: {
            AssistantSurface.adminInternal,
            AssistantSurface.systemPages,
          },
          allowedScopeKeys: {
            AssistantScopeKey.internalAdmin,
            AssistantScopeKey.internalSystem,
          },
          isTrusted: true,
          directAnswerAllowed: false,
          enabledByDefault: false,
        ),
        AssistantSourceRegistryEntry(
          id: 'document-intelligence-bridge',
          kind: AssistantSourceKind.documentIntelligence,
          labelAr: 'جسر ذكاء الوثائق',
          labelEn: 'Document intelligence bridge',
          ownerSystemKey: 'document_intelligence',
          allowedChannels: {AssistantChannel.internalAssistant},
          allowedSurfaces: {
            AssistantSurface.adminInternal,
            AssistantSurface.systemPages,
          },
          allowedScopeKeys: {
            AssistantScopeKey.internalAdmin,
            AssistantScopeKey.internalSystem,
          },
          isTrusted: true,
          directAnswerAllowed: false,
          enabledByDefault: false,
        ),
        AssistantSourceRegistryEntry(
          id: 'waqf-assets-assistant-scope',
          kind: AssistantSourceKind.waqfAssets,
          labelAr: 'نطاق مساعد الأصول الوقفية',
          labelEn: 'Waqf-assets assistant scope',
          ownerSystemKey: 'awqaf_system',
          allowedChannels: {AssistantChannel.internalAssistant},
          allowedSurfaces: {
            AssistantSurface.adminInternal,
            AssistantSurface.systemPages,
          },
          allowedScopeKeys: {
            AssistantScopeKey.internalAdmin,
            AssistantScopeKey.internalSystem,
          },
          isTrusted: true,
          directAnswerAllowed: false,
          enabledByDefault: false,
        ),
        AssistantSourceRegistryEntry(
          id: 'assistant-evals',
          kind: AssistantSourceKind.evaluation,
          labelAr: 'تقييمات المساعد',
          labelEn: 'Assistant evals',
          ownerSystemKey: 'assistant',
          allowedChannels: {AssistantChannel.internalAssistant},
          allowedSurfaces: {AssistantSurface.adminInternal},
          allowedScopeKeys: {AssistantScopeKey.internalAdmin},
          isTrusted: true,
          directAnswerAllowed: false,
          enabledByDefault: false,
        ),
        AssistantSourceRegistryEntry(
          id: 'unit-pages-governance',
          kind: AssistantSourceKind.governance,
          labelAr: 'حوكمة صفحات الوحدات',
          labelEn: 'Unit pages governance',
          ownerSystemKey: 'home_management',
          allowedChannels: {AssistantChannel.internalAssistant},
          allowedSurfaces: {AssistantSurface.adminInternal},
          allowedScopeKeys: {AssistantScopeKey.internalAdmin},
          isTrusted: true,
          directAnswerAllowed: true,
        ),
      ];

  List<AssistantSourceRegistryEntry> all() =>
      List<AssistantSourceRegistryEntry>.unmodifiable(_entries);

  List<AssistantSourceRegistryEntry> resolveForContract(
    AssistantContextContract contract,
  ) {
    return _entries
        .where((entry) => entry.supportsContract(contract))
        .toList(growable: false);
  }

  List<AssistantSourceRegistryEntry> resolveByIds(Iterable<String> ids) {
    final idSet = ids.toSet();
    return _entries
        .where((entry) => idSet.contains(entry.id))
        .toList(growable: false);
  }
}
