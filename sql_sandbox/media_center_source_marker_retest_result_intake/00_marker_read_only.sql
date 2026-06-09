-- Media Center Source Marker Retest Result Intake — read-only marker
-- This file intentionally performs no DDL/DML/GRANT/DROP.
select
  'media_center_source_marker_retest_result_intake' as section,
  'MEDIA_CENTER_SOURCE_MARKER_RETEST_ACCEPTED_SOURCE_CERTIFIED_PRODUCTION_DEFERRED' as decision,
  false as sql_production_executed,
  false as destructive_sql_executed,
  false as public_media_legacy_deleted_or_archived,
  false as production_approved,
  true as no_waqf_awqaf_system_gis_mutation,
  true as read_only;
