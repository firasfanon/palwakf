# Decision Record

```json
{
  "batch": "Platform 11K — Core Location Underlying Table Read Grant Hotfix",
  "date": "2026-06-10",
  "base": "platform11k_core_location_read_surface_grant_blocker_closure_2026_06_10.zip",
  "trigger_error": "ERROR 42501: permission denied for table core_locations",
  "hint": "GRANT SELECT ON core.core_locations TO authenticated",
  "classification": "PLATFORM_CORE_LOCATION_UNDERLYING_TABLE_GRANT_BLOCKER",
  "reason": "Views/RPCs are being evaluated under authenticated/invoker permissions, so SELECT on the wrapper views alone did not cover underlying base table access.",
  "scope": "Platform-only read grants on exact underlying read surfaces used by core location RPCs/views.",
  "grants": [
    "GRANT USAGE ON SCHEMA core TO authenticated",
    "GRANT SELECT ON core.core_locations TO authenticated",
    "GRANT SELECT ON core.core_lgus TO authenticated",
    "GRANT SELECT ON core.core_location_lgu_bridge_candidates TO authenticated IF EXISTS",
    "GRANT SELECT ON core.core_location_backlog_review_decisions TO authenticated IF EXISTS",
    "GRANT SELECT ON core.v_core_location_backlog_review_v1 TO authenticated IF EXISTS",
    "Reconfirm SELECT on v_core_location_backlog_operational_queue_v1 and v_core_locations_with_lgus_v1",
    "Reconfirm EXECUTE on the 3 public RPCs"
  ],
  "forbidden": [
    "No DML",
    "No Flutter changes",
    "No Awqaf System files",
    "No public.locations recreate",
    "No gis.locations_boundary create",
    "No waqf.waqf_assets mutation",
    "No RPC wrapper switch",
    "No production approval"
  ],
  "status": "staging-apply-ready / platform-core-location-underlying-table-grant-blocker-intaken / core-core-locations-select-grant-prepared / core-core-lgus-select-grant-prepared / optional-existing-underlying-read-surface-grants-prepared / no-dml / no-flutter-changes / no-awqaf-system-files / no-public-locations-recreate / no-gis-locations-boundary-create / no-waqf-assets-mutation / production-release-not-approved-pending-smoke-and-browser-retest"
}
```
