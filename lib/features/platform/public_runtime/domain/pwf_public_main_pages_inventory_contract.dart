/// Public main pages inventory and PWF-SIS compliance contract.
///
/// This file is deliberately declarative. It is used to keep the public
/// homepage/runtime work from becoming scattered route-by-route patching.
/// It records every main public surface, its canonical route, the expected
/// official data source, and whether the page is runtime-ready, needs data
/// completion, or needs PWF-SIS visual polishing.
///
/// No database write, route guard, or runtime side effect is executed here.
class PwfPublicMainPageInventoryItem {
  final String key;
  final String canonicalRoute;
  final List<String> legacyAliases;
  final String pageFamily;
  final String pwfSisStatus;
  final String officialDataContract;
  final String officialOwner;
  final String dataReadiness;
  final String polishDecision;
  final List<String> requiredChecks;

  const PwfPublicMainPageInventoryItem({
    required this.key,
    required this.canonicalRoute,
    this.legacyAliases = const [],
    required this.pageFamily,
    required this.pwfSisStatus,
    required this.officialDataContract,
    required this.officialOwner,
    required this.dataReadiness,
    required this.polishDecision,
    required this.requiredChecks,
  });

  bool get isCanonicalHomeRoute =>
      canonicalRoute == '/home' || canonicalRoute.startsWith('/home/');
  bool get needsOfficialDataCompletion => dataReadiness.contains('incomplete');
  bool get needsPwfSisPolish => polishDecision.contains('polish-required');
}

class PwfPublicMainPagesPwfSisInventoryContract {
  const PwfPublicMainPagesPwfSisInventoryContract._();

  static const String batch =
      'mega_batch_public_main_pages_pwf_sis_inventory_official_data_polish_2026_05_22';

  static const String methodology =
      'inventory-first; no random disabling; official-table-source-gates before polish implementation';

  static const String canonicalNamespace = '/home/*';

  static const List<PwfPublicMainPageInventoryItem> pages = [
    PwfPublicMainPageInventoryItem(
      key: 'home',
      canonicalRoute: '/home',
      pageFamily: 'main_homepage',
      pwfSisStatus: 'candidate-needs-full-section-width-review',
      officialDataContract:
          'public.homepage_sections + public.homepage_* runtime sections',
      officialOwner: 'platform/public_homepage_contracts',
      dataReadiness: 'official-data-partial-dynamic-homepage-sections-present',
      polishDecision: 'polish-required-unify-section-spacing-and-card-grid',
      requiredChecks: [
        'hero/breaking/footer visible',
        'all dynamic sections ordered from database',
        'no blue text on blue background',
        'console clean',
      ],
    ),
    PwfPublicMainPageInventoryItem(
      key: 'news_list',
      canonicalRoute: '/home/news',
      legacyAliases: ['/news'],
      pageFamily: 'media_news',
      pwfSisStatus: 'runtime-passed-needs-final-visual-consistency-pass',
      officialDataContract: 'public.v_media_news_compat_v1',
      officialOwner: 'media_center via public wrapper',
      dataReadiness: 'official-data-ready-news-wrapper-nonzero',
      polishDecision: 'polish-required-align-with-pwf-sis-public-list-template',
      requiredChecks: [
        'filters',
        'cards',
        'stats',
        'detail link',
        'console clean',
      ],
    ),
    PwfPublicMainPageInventoryItem(
      key: 'news_detail',
      canonicalRoute: '/home/news/:id',
      pageFamily: 'media_news_detail',
      pwfSisStatus: 'runtime-passed-needs-final-detail-template-pass',
      officialDataContract: 'public.v_media_news_compat_v1 stable id resolver',
      officialOwner: 'media_center via public wrapper',
      dataReadiness: 'official-data-ready-news-detail-tested',
      polishDecision: 'polish-required-unify-metadata-actions-related-items',
      requiredChecks: [
        'metadata',
        'body',
        'share actions',
        'back action',
        'console clean',
      ],
    ),
    PwfPublicMainPageInventoryItem(
      key: 'announcements_list',
      canonicalRoute: '/home/announcements',
      legacyAliases: ['/announcements'],
      pageFamily: 'media_announcements',
      pwfSisStatus: 'runtime-passed-needs-final-visual-consistency-pass',
      officialDataContract: 'public.v_media_announcements_compat_v1',
      officialOwner: 'media_center via public wrapper',
      dataReadiness: 'official-data-ready-announcements-wrapper-nonzero',
      polishDecision: 'polish-required-align-with-pwf-sis-public-list-template',
      requiredChecks: [
        'priority filters',
        'metrics',
        'cards',
        'detail link',
        'console clean',
      ],
    ),
    PwfPublicMainPageInventoryItem(
      key: 'announcements_detail',
      canonicalRoute: '/home/announcements/:id',
      pageFamily: 'media_announcements_detail',
      pwfSisStatus: 'runtime-passed-after-stable-family-key-fix',
      officialDataContract:
          'public.v_media_announcements_compat_v1 stable id resolver',
      officialOwner: 'media_center via public wrapper',
      dataReadiness: 'official-data-ready-announcement-detail-tested',
      polishDecision: 'polish-required-unify-detail-template-with-news-detail',
      requiredChecks: [
        'metadata',
        'validity',
        'body',
        'no loading loop',
        'console clean',
      ],
    ),
    PwfPublicMainPageInventoryItem(
      key: 'activities',
      canonicalRoute: '/home/activities',
      legacyAliases: ['/activities'],
      pageFamily: 'media_activities',
      pwfSisStatus: 'pwf-sis-list-template-ready-browser-uat-required',
      officialDataContract: 'public.v_media_activities_compat_v1',
      officialOwner: 'media_center via public wrapper',
      dataReadiness:
          'official-data-ready-activities-wrapper-nonzero-after-controlled-execution',
      polishDecision:
          'polish-executed-align-with-public-list-template-browser-uat-required',
      requiredChecks: [
        'wrapper nonzero',
        'cards render',
        'detail route policy',
        'console clean',
      ],
    ),
    PwfPublicMainPageInventoryItem(
      key: 'gallery',
      canonicalRoute: '/home/gallery',
      legacyAliases: ['/gallery', '/media', '/home/media'],
      pageFamily: 'media_gallery',
      pwfSisStatus: 'incomplete-data-and-polish-required',
      officialDataContract:
          'public.v_media_gallery_compat_v1 after asset/content mapping',
      officialOwner: 'media_center/content_assets via public wrapper',
      dataReadiness:
          'official-data-incomplete-content-assets-zero-before-controlled-execution-uat',
      polishDecision: 'polish-required-after-asset-mapping-confirmation',
      requiredChecks: [
        'wrapper nonzero or official empty-state',
        'image fallback',
        'console clean',
      ],
    ),
    PwfPublicMainPageInventoryItem(
      key: 'services',
      canonicalRoute: '/home/services',
      legacyAliases: ['/services'],
      pageFamily: 'services_catalog',
      pwfSisStatus: 'candidate-needs-card-template-and-data-label-review',
      officialDataContract: 'public.v_services_catalog_compat_v1',
      officialOwner: 'platform_services',
      dataReadiness: 'official-data-ready-services-wrapper-nonzero',
      polishDecision:
          'polish-required-align-request-track-cards-and-empty-states',
      requiredChecks: [
        'cards from wrapper',
        'request route',
        'tracking route',
        'console clean',
      ],
    ),
    PwfPublicMainPageInventoryItem(
      key: 'press_releases',
      canonicalRoute: '/home/press-releases',
      legacyAliases: ['/press-releases'],
      pageFamily: 'platform_center_content',
      pwfSisStatus: 'candidate-needs-official-content-density-review',
      officialDataContract: 'public.v_platform_center_content published-only',
      officialOwner: 'platform_content/platform_center',
      dataReadiness: 'official-data-must-be-confirmed-by-category-counts',
      polishDecision: 'polish-required-unify-with-news-list-and-detail-pattern',
      requiredChecks: [
        'published-only',
        'cards/detail if supported',
        'console clean',
      ],
    ),
    PwfPublicMainPageInventoryItem(
      key: 'zakat',
      canonicalRoute: '/home/zakat',
      legacyAliases: ['/zakat', '/donations', '/donate'],
      pageFamily: 'public_religious_tool',
      pwfSisStatus: 'pwf-sis-interactive-tool-shell-applied',
      officialDataContract:
          'zakat schema official config wrapper + billing integration contract guard',
      officialOwner:
          'zakat owns rules/config; billing_system owns payments; public exposes wrappers only',
      dataReadiness: 'official-config-gap-visible-no-fake-data',
      polishDecision:
          'polish-executed-pwf-sis-public-service-tool-template-browser-uat-required',
      requiredChecks: [
        'official rates/config source',
        'calculator sections',
        'responsive layout',
        'console clean',
      ],
    ),
    PwfPublicMainPageInventoryItem(
      key: 'chat',
      canonicalRoute: '/home/chat',
      legacyAliases: ['/chat', '/public-chat', '/ask'],
      pageFamily: 'public_assistant',
      pwfSisStatus: 'pwf-sis-interactive-tool-shell-applied',
      officialDataContract:
          'assistant allowed public knowledge scope + official page/service/media wrappers',
      officialOwner: 'assistant/platform public knowledge scope',
      dataReadiness: 'official-source-allowlist-visible-no-private-admin-data',
      polishDecision:
          'polish-executed-pwf-sis-public-interactive-tool-template-browser-uat-required',
      requiredChecks: [
        'scope banner',
        'official sources only',
        'no admin/private data',
        'console clean',
      ],
    ),
    PwfPublicMainPageInventoryItem(
      key: 'static_about_contact_policy_pages',
      canonicalRoute:
          '/home/{about,contact,privacy,terms,sitemap,structure,former-ministers}',
      pageFamily: 'static_public_pages',
      pwfSisStatus: 'inventory-required',
      officialDataContract:
          'public.v_platform_center_content or public site_pages/pages official content contract',
      officialOwner:
          'platform_content/site_content pending final source certification',
      dataReadiness:
          'official-data-incomplete-until-all-pages-map-to-official-content-records',
      polishDecision: 'polish-required-one-official-static-page-template',
      requiredChecks: [
        'no hardcoded stale text',
        'official content row exists',
        'same header/footer/card rhythm',
        'console clean',
      ],
    ),
    PwfPublicMainPageInventoryItem(
      key: 'religious_tools_quran_prayer_times',
      canonicalRoute: '/home/{quran,prayer-times}',
      pageFamily: 'religious_tools',
      pwfSisStatus: 'inventory-required',
      officialDataContract:
          'official religious tool data/source contract required',
      officialOwner: 'platform_services/religious_tools pending certification',
      dataReadiness: 'official-data-incomplete-until-source-contract-certified',
      polishDecision: 'polish-required-shared-public-tool-template',
      requiredChecks: [
        'official source label',
        'tool inputs',
        'accessibility',
        'console clean',
      ],
    ),
    PwfPublicMainPageInventoryItem(
      key: 'locations_mosques_projects_social_pages',
      canonicalRoute:
          '/home/{mosques,projects,social-services,legal-references,sanctities-observatory,awareness-campaigns,official-statements,social-posts,friday-sermons}',
      pageFamily: 'public_programs_and_references',
      pwfSisStatus: 'inventory-required',
      officialDataContract:
          'platform_content/media_center/gis/platform_services wrappers per page',
      officialOwner: 'mixed official owners requiring page-by-page mapping',
      dataReadiness: 'official-data-incomplete-until-page-source-matrix-passes',
      polishDecision: 'polish-required-use-one-public-list-detail-family',
      requiredChecks: [
        'official owner selected',
        'public wrapper exists',
        'list/detail policy',
        'console clean',
      ],
    ),
  ];

  static Iterable<PwfPublicMainPageInventoryItem> get canonicalHomePages =>
      pages.where((page) => page.isCanonicalHomeRoute);

  static Iterable<PwfPublicMainPageInventoryItem>
  get pagesNeedingOfficialData =>
      pages.where((page) => page.needsOfficialDataCompletion);

  static Iterable<PwfPublicMainPageInventoryItem>
  get pagesNeedingPwfSisPolish => pages.where((page) => page.needsPwfSisPolish);

  static const String finalDecision =
      'pwf-sis-polish-and-official-data-binding-executed-with-guards-browser-uat-required';
}

class PwfPublicMainPagesPolishExecutionDecision {
  const PwfPublicMainPagesPolishExecutionDecision._();

  static const String decision =
      'PWF_SIS_POLISH_EXECUTED_OFFICIAL_DATA_BINDING_WITH_GUARDS';
  static const String productionGate = 'browser-console-uat-required';
  static const String galleryDecision =
      'official-empty-state-only-gallery-wrapper-zero-not-certified-complete';
  static const String zakatDecision =
      'pwf-sis-tool-shell-applied-official-config-gap-visible-no-fake-data';
  static const String chatDecision =
      'pwf-sis-tool-shell-applied-official-source-allowlist-visible';
}

class PwfPublicMainPagesPwfSisEvidenceClosureContract {
  const PwfPublicMainPagesPwfSisEvidenceClosureContract._();

  static const String batch =
      'mega_batch_public_main_pages_pwf_sis_polish_browser_console_uat_evidence_closure_2026_05_22';
  static const String evidenceDecision =
      'browser-console-runtime-evidence-accepted-zakat-visual-gap-recorded';
  static const bool analyzerClean = true;
  static const bool chromeStartupPassed = true;
  static const bool consoleCleanForProvidedScreenshots = true;
  static const bool productionApproved = false;
  static const String remainingPwfSisGap =
      '/home/zakat requires visual harmonization with PWF-SIS interactive tool template';

  static const Map<String, String> routeEvidence = {
    '/home': 'browser-console-evidence-present',
    '/home/news': 'browser-console-evidence-present',
    '/home/news/:id': 'browser-console-evidence-present',
    '/home/services': 'browser-console-evidence-present',
    '/home/chat': 'browser-console-evidence-present',
    '/home/zakat': 'functional-console-clean-but-visual-different',
  };
}

class PwfPublicMainPagesZakatVisualHarmonizationUatEvidence {
  const PwfPublicMainPagesZakatVisualHarmonizationUatEvidence._();

  static const String decision =
      'zakat-pwf-sis-visual-gap-closed-for-runtime-config-wrapper-pending';
  static const String route = '/home/zakat';
  static const String previousGap =
      'zakat public page was visually different from PWF-SIS family';
  static const String currentGate =
      'official config wrapper pending before production content certification';
  static const bool browserConsoleEvidenceAccepted = true;
  static const bool fullProductionCertification = false;
}

class ZakatOfficialConfigWrapperProductionDecision {
  const ZakatOfficialConfigWrapperProductionDecision._();

  static const String decision =
      'zakat-official-config-wrapper-prepared-production-content-certification-pending-sql-browser-uat';
  static const String canonicalRoute = '/home/zakat';
  static const String officialSource = 'public.v_zakat_public_config_v1';
  static const String owner = 'platform_services';
  static const bool flutterRuntimeBindingPrepared = true;
  static const bool sqlApplyRequired = true;
  static const bool productionApprovalGranted = false;
  static const bool noWaqfAssetsMutation = true;
}
