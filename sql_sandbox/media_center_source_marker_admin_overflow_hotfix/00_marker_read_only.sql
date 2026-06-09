-- Media Center Source Marker Visibility + Admin Overflow Hotfix
-- READ ONLY MARKER ONLY. No DDL/DML/GRANT/DROP.
select
  'media_center_source_marker_admin_overflow_hotfix_2026_05_31' as marker,
  true as read_only,
  true as no_sql_production_change,
  true as no_public_media_legacy_delete_or_archive,
  true as no_waqf_awqaf_system_gis_mutation;
