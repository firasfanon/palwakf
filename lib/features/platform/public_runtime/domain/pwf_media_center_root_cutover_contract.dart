/// Media Center Runtime Source Root Cutover contract.
///
/// This contract is intentionally declarative. It records that public runtime
/// media reads default to public compatibility facades backed by
/// media_center.content_items, while legacy public media tables remain
/// preserved as emergency fallback only.
class PwfMediaCenterRootCutoverContract {
  const PwfMediaCenterRootCutoverContract._();

  static const String batchKey =
      'media_center_runtime_source_root_cutover_2026_05_30';
  static const String decision =
      'media-center-owner-read-default-legacy-public-fallback-only';
  static const bool ownerReadDefault = true;
  static const bool legacyPublicFallbackOnly = true;
  static const bool productionApproved = false;
  static const bool destructiveSqlAuthorized = false;
  static const bool publicMediaArchiveDeleteAuthorized = false;
  static const bool waqfAwqafSystemGisMutationAllowed = false;

  static const List<String> ownerReadSurfaces = <String>[
    'public.v_media_news_compat_v1',
    'public.v_media_announcements_compat_v1',
    'public.v_media_activities_compat_v1',
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
