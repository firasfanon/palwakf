-- 98_ROLLBACK_restore_unqualified_postgis_optional.sql
-- OPTIONAL ONLY.
-- Not included as executable rollback because restoring the unqualified function would
-- reintroduce the confirmed PostGIS function resolution blocker.
select
  'awqaf_asset_detail_postgis_geojson_qualification_rollback_not_provided' as section,
  'Rollback should be created from previous database function backup only if explicitly required.' as instruction,
  false as production_approved;
