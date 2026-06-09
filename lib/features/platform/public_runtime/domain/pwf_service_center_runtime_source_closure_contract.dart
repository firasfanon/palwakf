/// Service Center runtime source closure contract.
///
/// This contract documents that Service Center public/admin runtime reads and
/// actions must use `platform_services` through public RPC wrappers by default.
/// Legacy/local fallback remains diagnostic-only when the RPC surface is absent
/// or a development environment has not applied the backend schema yet.
class PwfServiceCenterRuntimeSourceClosureContract {
  const PwfServiceCenterRuntimeSourceClosureContract._();

  static const patchKey =
      'service-center-ownership-verification-runtime-source-closure-2026-05-31';

  static const ownerSchema = 'platform_services';
  static const publicSchema = 'public';

  static const formsSurface = 'public.rpc_services_forms_public_v1';
  static const submitSurface = 'public.rpc_services_submit_request_v1';
  static const trackingSurface = 'public.rpc_services_track_request_public_v1';
  static const adminQueueSurface = 'public.rpc_services_admin_request_queue_v1';
  static const adminTransitionSurface =
      'public.rpc_services_admin_transition_request_v1';

  static const sourceMarker = 'PWF_SERVICE_CENTER_RUNTIME_SOURCE';
  static const fallbackMarker = 'PWF_SERVICE_CENTER_LEGACY_FALLBACK_ONLY';

  static const ownerReadDecision =
      'platform-services-rpc-default-runtime-source';
  static const fallbackDecision =
      'fallback-only-when-platform-services-rpc-missing-or-development-preview';

  static const protectedTables = <String>[
    'platform_services.service_forms_registry',
    'platform_services.service_requests',
    'platform_services.service_request_status_events',
    'platform_services.service_request_attachments',
  ];

  static const rpcSurfaces = <String>[
    formsSurface,
    submitSurface,
    trackingSurface,
    adminQueueSurface,
    adminTransitionSurface,
  ];

  static const boundaries = <String>[
    'public RPC wrappers only for external access',
    'no service_role in Flutter',
    'no direct writes from Flutter into platform_services tables',
    'no waqf/waqf_assets/awqaf_system/GIS mutation',
    'production gate remains deferred',
  ];
}
