-- Media Center Runtime Source Root Cutover Browser UAT Result Intake
-- Date: 2026-05-31
-- Purpose: read-only marker for evidence intake.
-- This script performs no DDL/DML/GRANT/DROP and does not mutate any table.

select
  'media_center_runtime_source_root_cutover_browser_uat_result_intake'::text as section,
  'visual_uat_accepted_source_marker_pending'::text as decision,
  true as read_only,
  false as production_approved,
  false as ddl_dml_grant_drop_executed,
  false as legacy_public_media_deleted_or_archived,
  false as waqf_awqaf_system_gis_mutation,
  'staging-stable / media-center-root-cutover-browser-visual-uat-accepted / public-news-announcements-activities-rendered / admin-media-center-route-rendered / media-owner-read-source-marker-not-visible-in-supplied-screenshots / source-certification-pending / analyzer-local-retest-required / production-not-approved / public-legacy-media-preserved / no-waqf-awqaf-system-gis-mutation'::text as current_state;
