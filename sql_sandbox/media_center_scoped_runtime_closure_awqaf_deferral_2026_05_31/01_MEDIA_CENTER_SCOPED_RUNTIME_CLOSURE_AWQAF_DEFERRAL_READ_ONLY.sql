-- Media Center Scoped Runtime Closure + Awqaf System Integration Blocker Deferral
-- Date: 2026-05-31
-- Read-only marker only. No DDL/DML/GRANT/DROP.

select
  'media_center_scoped_runtime_closure_awqaf_deferral' as section,
  'MEDIA_CENTER_SCOPED_RUNTIME_CLOSURE_ACCEPTED_AWQAF_SYSTEM_INTEGRATION_BLOCKER_DEFERRED_PRODUCTION_NOT_APPROVED' as decision,
  true as media_center_scoped_runtime_closed,
  true as awqaf_assist_blocker_deferred_to_awqaf_system,
  false as production_approved,
  false as destructive_sql_authorized,
  true as public_legacy_media_preserved,
  true as no_waqf_assets_mutation;
