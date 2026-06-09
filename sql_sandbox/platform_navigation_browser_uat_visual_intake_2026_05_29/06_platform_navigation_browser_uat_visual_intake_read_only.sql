-- Platform Navigation Browser UAT Visual Intake Marker — Read Only
-- 2026-05-29
-- Purpose: records the expected certification posture only.
-- This file performs no DML, no DDL, no destructive action, and no mutation of
-- public.services, public.home_services, waqf, waqf_assets, awqaf_system, or GIS.

select
  'platform_navigation_browser_uat_visual_intake'::text as section,
  'PLATFORM_NAVIGATION_BROWSER_UAT_VISUAL_EVIDENCE_ACCEPTED_SOURCE_PROOF_PENDING'::text as decision,
  true::boolean as visual_browser_uat_evidence_accepted,
  false::boolean as owner_read_source_certified,
  false::boolean as runtime_switch_certified,
  false::boolean as production_approved,
  false::boolean as destructive_sql_authorized,
  false::boolean as archive_delete_authorized,
  false::boolean as public_services_delete_authorized,
  false::boolean as public_home_services_delete_authorized,
  true::boolean as no_waqf_assets_mutation_in_this_script,
  true::boolean as read_only;
