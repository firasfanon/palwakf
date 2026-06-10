# Decision Record

```json
{
  "batch": "Platform 11K — Core Location Read Surface Grant Blocker Closure",
  "date": "2026-06-10",
  "base": "platform11k_final_browser_runtime_evidence_intake_2026_06_09.zip",
  "classification": "PLATFORM_CORE_READ_SURFACE_GRANT_BLOCKER",
  "reported_error": "permission denied for view v_core_location_backlog_operational_queue_v1",
  "blocked_rpcs": [
    "public.rpc_core_location_runtime_certification_v1",
    "public.rpc_core_location_backlog_summary_v1",
    "public.rpc_core_location_backlog_operational_queue_v1"
  ],
  "target_surfaces": [
    "core.v_core_location_backlog_operational_queue_v1",
    "core.v_core_locations_with_lgus_v1",
    "public.rpc_core_location_runtime_certification_v1",
    "public.rpc_core_location_backlog_summary_v1",
    "public.rpc_core_location_backlog_operational_queue_v1"
  ],
  "scope": "platform-only read grants/security correction",
  "status": "staging-apply-ready / platform-core-read-surface-grant-blocker-intaken / awqaf-routes-working-platform-grant-blocker-confirmed / least-privilege-authenticated-read-grants-prepared / no-dml / no-awqaf-system-files / no-flutter-changes / no-public-locations-recreate / no-gis-locations-boundary-create / no-waqf-assets-mutation / production-release-not-approved-pending-browser-retest",
  "run_order": [
    "00_READ_ME_FIRST.sql",
    "01_PREFLIGHT_surface_presence_and_acl_read_only.sql",
    "02_APPLY_authenticated_read_surface_grants.sql",
    "03_VERIFY_acl_and_function_security_read_only.sql",
    "04_VERIFY_authenticated_role_rpc_smoke_read_only.sql",
    "05_BROWSER_RETEST_MATRIX_read_only.sql",
    "06_FINAL_GATE_read_only.sql",
    "99_OPTIONAL_SECURITY_DEFINER_FALLBACK_NOT_DEFAULT.sql"
  ]
}
```
