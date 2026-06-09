-- 07_sql_result_intake_marker_read_only.sql
-- Purpose: marker only. This script performs no migration, no DDL, and no DML.
select
  'public_schema_sovereignty_sql_result_intake' as section,
  'CONTROLLED_MIGRATION_GATE_APPROVED_WITH_GUARDS_NOT_EXECUTED' as decision,
  false as production_sql_executed,
  false as public_schema_migration_executed,
  false as legacy_delete_archive_executed,
  true as no_waq_assets_mutation_in_this_script;
