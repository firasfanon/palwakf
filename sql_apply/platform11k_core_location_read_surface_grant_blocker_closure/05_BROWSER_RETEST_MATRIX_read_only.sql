select
  'platform11k_core_location_grant_browser_retest_matrix_read_only' as section,
  route_or_rpc,
  expected_result,
  evidence_required,
  certification_status,
  false as production_approved
from (
  values
    ('/systems/awqaf-system/locations', 'Page loads; no platform core read 403.', 'screenshot + console clean + network', 'pending_browser_retest'),
    ('/systems/awqaf-system/waqf-assets/location-selector', 'Selector loads; no 403 on core location RPCs.', 'screenshot + console clean + network', 'pending_browser_retest'),
    ('public.rpc_core_location_runtime_certification_v1', 'Network 200 as authenticated.', 'Network 200', 'pending_browser_retest'),
    ('public.rpc_core_location_backlog_summary_v1', 'Network 200 as authenticated.', 'Network 200', 'pending_browser_retest'),
    ('public.rpc_core_location_backlog_operational_queue_v1', 'Network 200 as authenticated.', 'Network 200', 'pending_browser_retest'),
    ('public.locations', 'Not recreated or used as source.', 'SQL/object check + network absence', 'preserve_closed'),
    ('gis.locations_boundary', 'Not created.', 'SQL/object check', 'preserve_closed'),
    ('waqf.waqf_assets', 'No mutation from this correction.', 'evidence statement', 'preserve_no_mutation')
) as v(route_or_rpc, expected_result, evidence_required, certification_status);
