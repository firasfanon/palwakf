/// Official data binding contract for the public main pages.
///
/// This file is declarative and side-effect free. It records the official
/// table/view/RPC surface each public route is allowed to read from after the
/// Public Main Pages PWF-SIS polish execution. It deliberately distinguishes
/// between:
/// - certified official data,
/// - official empty state,
/// - official-source gap that must remain visible and not be faked.
class PwfPublicOfficialDataBinding {
  final String key;
  final String canonicalRoute;
  final String officialSource;
  final String owner;
  final String rowEvidence;
  final String readiness;
  final bool canBeCertifiedComplete;

  const PwfPublicOfficialDataBinding({
    required this.key,
    required this.canonicalRoute,
    required this.officialSource,
    required this.owner,
    required this.rowEvidence,
    required this.readiness,
    required this.canBeCertifiedComplete,
  });

  bool matches(String route) {
    final normalized = route.trim().isEmpty ? '/home' : route.trim();
    if (canonicalRoute.endsWith('/:id')) {
      final prefix = canonicalRoute.substring(0, canonicalRoute.length - 4);
      return normalized.startsWith(prefix) && normalized.length > prefix.length;
    }
    return normalized == canonicalRoute;
  }
}

class PwfPublicOfficialDataBindingContract {
  const PwfPublicOfficialDataBindingContract._();

  static const String batch =
      'mega_batch_public_main_pages_pwf_sis_polish_official_data_binding_execution_2026_05_22';

  static const String rule =
      'no-public-page-is-certified-complete-without-canonical-route-official-source-pwf-sis-template-browser-console-clean';

  static const List<PwfPublicOfficialDataBinding> bindings = [
    PwfPublicOfficialDataBinding(
      key: 'home',
      canonicalRoute: '/home',
      officialSource: 'public.homepage_sections',
      owner: 'site_content/public homepage compatibility',
      rowEvidence: '137 rows',
      readiness: 'official-data-ready',
      canBeCertifiedComplete: true,
    ),
    PwfPublicOfficialDataBinding(
      key: 'news_list',
      canonicalRoute: '/home/news',
      officialSource: 'public.v_media_news_compat_v1',
      owner: 'media_center via public wrapper',
      rowEvidence: '93 rows',
      readiness: 'official-data-ready',
      canBeCertifiedComplete: true,
    ),
    PwfPublicOfficialDataBinding(
      key: 'news_detail',
      canonicalRoute: '/home/news/:id',
      officialSource: 'public.v_media_news_compat_v1 stable id resolver',
      owner: 'media_center via public wrapper',
      rowEvidence: '93 rows',
      readiness: 'official-data-ready',
      canBeCertifiedComplete: true,
    ),
    PwfPublicOfficialDataBinding(
      key: 'announcements_list',
      canonicalRoute: '/home/announcements',
      officialSource: 'public.v_media_announcements_compat_v1',
      owner: 'media_center via public wrapper',
      rowEvidence: '90 rows',
      readiness: 'official-data-ready',
      canBeCertifiedComplete: true,
    ),
    PwfPublicOfficialDataBinding(
      key: 'announcements_detail',
      canonicalRoute: '/home/announcements/:id',
      officialSource:
          'public.v_media_announcements_compat_v1 stable id resolver',
      owner: 'media_center via public wrapper',
      rowEvidence: '90 rows',
      readiness: 'official-data-ready',
      canBeCertifiedComplete: true,
    ),
    PwfPublicOfficialDataBinding(
      key: 'activities',
      canonicalRoute: '/home/activities',
      officialSource: 'public.v_media_activities_compat_v1',
      owner: 'media_center via public wrapper',
      rowEvidence: '93 rows after controlled execution',
      readiness: 'official-data-ready-browser-uat-required',
      canBeCertifiedComplete: true,
    ),
    PwfPublicOfficialDataBinding(
      key: 'gallery',
      canonicalRoute: '/home/gallery',
      officialSource: 'public.v_media_gallery_compat_v1',
      owner: 'media_center/content_assets via public wrapper',
      rowEvidence: '0 rows',
      readiness: 'official-empty-state-not-complete-gallery-wrapper-zero',
      canBeCertifiedComplete: false,
    ),
    PwfPublicOfficialDataBinding(
      key: 'services',
      canonicalRoute: '/home/services',
      officialSource: 'public.v_services_catalog_compat_v1',
      owner: 'platform_services',
      rowEvidence: '9 rows',
      readiness: 'official-data-ready',
      canBeCertifiedComplete: true,
    ),
    PwfPublicOfficialDataBinding(
      key: 'press_releases',
      canonicalRoute: '/home/press-releases',
      officialSource: 'public.v_platform_center_content',
      owner: 'platform_content/platform_center',
      rowEvidence: '10 published rows across center families',
      readiness: 'official-data-ready-family-count-uat-required',
      canBeCertifiedComplete: true,
    ),
    PwfPublicOfficialDataBinding(
      key: 'zakat',
      canonicalRoute: '/home/zakat',
      officialSource:
          'public.v_zakat_public_config_v1 backed by zakat.public_config + declared fallback',
      owner:
          'zakat operational owner; billing_system financial owner; public wrapper only',
      rowEvidence: 'zakat.public_config wrapper pack prepared; SQL/UAT pending',
      readiness:
          'pwf-sis-visual-harmonized-zakat-domain-owner-wrapper-pending-sql-uat',
      canBeCertifiedComplete: false,
    ),
    PwfPublicOfficialDataBinding(
      key: 'chat',
      canonicalRoute: '/home/chat',
      officialSource: 'assistant public source allowlist + public wrappers',
      owner: 'assistant/platform public knowledge scope',
      rowEvidence: 'allowlist displayed; source rows resolved at answer time',
      readiness: 'pwf-sis-tool-shell-applied-official-source-allowlist-visible',
      canBeCertifiedComplete: false,
    ),
  ];

  static PwfPublicOfficialDataBinding? byRoute(String route) {
    final normalized = route.trim().isEmpty ? '/home' : route.trim();
    for (final binding in bindings) {
      if (binding.matches(normalized)) return binding;
    }
    return null;
  }

  static bool canCertifyRoute(String route) =>
      byRoute(route)?.canBeCertifiedComplete == true;
}

class PwfZakatOfficialDataBindingUatGate {
  const PwfZakatOfficialDataBindingUatGate._();

  static const String route = '/home/zakat';
  static const String decision =
      'official-config-contract-declared-dedicated-wrapper-pending';
  static const String requiredProductionSurface =
      'platform_services.v_zakat_public_config_v1 or equivalent governed RPC/view';
  static const bool currentStaticContractVisible = true;
  static const bool dedicatedDbWrapperCertified = false;
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
