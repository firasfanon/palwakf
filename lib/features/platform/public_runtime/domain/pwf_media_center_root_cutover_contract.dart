/// Media Center Runtime Source Root Cutover contract.
///
/// This contract is intentionally declarative. It records that public runtime
/// media reads must bind directly to owner-schema surfaces. public.* wrappers
/// and legacy public media tables are preserved only for evidence/migration.
class PwfMediaCenterRootCutoverContract {
  const PwfMediaCenterRootCutoverContract._();

  static const String batchKey =
      'media_center_runtime_source_root_cutover_2026_05_30';
  static const String decision =
      'media-center-owner-schema-direct-runtime-public-dependency-zero';
  static const bool ownerReadDefault = true;
  static const bool legacyPublicFallbackOnly = false;
  static const bool publicRuntimeDependencyZero = true;
  static const bool productionApproved = false;
  static const bool destructiveSqlAuthorized = false;
  static const bool publicMediaArchiveDeleteAuthorized = false;
  static const bool waqfAwqafSystemGisMutationAllowed = false;

  static const List<String> ownerReadSurfaces = <String>[
    'media_center.v_unit_public_content_runtime_v1',
    'media_center.v_unit_public_news_runtime_v1',
    'media_center.v_unit_public_announcements_runtime_v1',
    'media_center.v_unit_public_activities_runtime_v1',
    'media_center.v_unit_public_gallery_runtime_v1',
    'core.v_unit_public_surface_profile_runtime_v1',
  ];

  static const List<String> forbiddenPublicRuntimeSurfaces = <String>[
    'public.v_media_news_compat_v1',
    'public.v_media_announcements_compat_v1',
    'public.v_media_activities_compat_v1',
    'public.v_unit_public_content_compat_v1',
    'public.v_unit_public_news_compat_v1',
    'public.v_unit_public_announcements_compat_v1',
    'public.v_unit_public_activities_compat_v1',
    'public.v_unit_public_gallery_compat_v1',
    'public.v_unit_public_surface_profile_v1',
  ];

  static const List<String> preservedLegacyFallbackSurfaces = <String>[
    'public.news_articles',
    'public.announcements',
    'public.activities',
  ];

  static const List<String> runtimeMarkers = <String>[
    'PWF_MEDIA_CENTER_ROOT_CUTOVER',
    'PWF_MEDIA_CENTER_LEGACY_FALLBACK_ONLY',
  ];

  static const List<String> editorialWorkflow = <String>[
    'draft',
    'review',
    'approved',
    'published',
    'archived',
  ];
}
