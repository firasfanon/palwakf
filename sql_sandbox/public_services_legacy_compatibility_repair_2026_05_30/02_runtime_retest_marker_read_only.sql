-- Public Services Legacy Compatibility Repair — runtime retest marker
-- This file records the expected Flutter marker only. It performs no mutation.

select
  'public_services_legacy_compatibility_repair_runtime_retest_marker' as section,
  'PWF_PUBLIC_SERVICES_LEGACY_COMPATIBILITY_REPAIR' as expected_console_marker,
  'public.v_services_catalog_compat_v1' as expected_default_surface,
  'projection=* / filtering=client-side / ordering=client-side' as expected_adapter_behavior,
  false as production_approved,
  false as default_owner_read_switch_authorized,
  false as archive_delete_authorized,
  false as destructive_sql_authorized,
  true as read_only;
