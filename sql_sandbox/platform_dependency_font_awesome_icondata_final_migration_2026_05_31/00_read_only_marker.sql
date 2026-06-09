-- Platform Dependency Compatibility Repair marker only.
-- Read-only / no DDL / no DML / no GRANT / no DROP.
select
  'platform_dependency_font_awesome_icondata_final_migration_2026_05_31' as patch_key,
  'read_only_marker_no_database_mutation' as decision,
  true as no_sql_production_change,
  true as no_waqf_awqaf_system_gis_mutation;
