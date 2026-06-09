-- 01_runtime_source_certification_evidence_marker_read_only.sql
-- Batch: platform_navigation_runtime_source_certification_evidence_intake_2026_05_30
-- Purpose: Read-only marker documenting accepted browser/console evidence.
-- This script performs no DDL, no DML, no GRANT, no DROP, no archive/delete.

select
  'platform_navigation_runtime_source_certification_evidence_intake'::text as section,
  'PLATFORM_NAVIGATION_OWNER_READ_SOURCE_CERTIFIED_BY_CONSOLE_MARKER_STRICT_CONSOLE_REMAINS_OPEN'::text as decision,
  true as owner_read_source_certified_by_console_marker,
  false as production_approved,
  false as runtime_switch_default_enabled,
  false as public_services_deleted_or_archived,
  false as public_home_services_deleted_or_archived,
  false as waqf_assets_mutated,
  'public.v_platform_navigation_home_services_from_owner_v1; public.v_platform_navigation_services_catalog_from_owner_v1'::text as certified_surfaces,
  'Strict console still has non-navigation red errors requiring separate classification.'::text as note;
