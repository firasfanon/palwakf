/*
Platform Public Schema V4 — SQL Result Intake Marker
READ ONLY. No DDL/DML/GRANT/REVOKE.
*/
select
  'platform_public_schema_v4_sql_result_intake_read_me_first' as section,
  'READ_ONLY_RESULT_INTAKE_ONLY' as execution_mode,
  false as ddl_dml_authorized,
  false as grant_revoke_authorized,
  false as archive_drop_rename_authorized,
  false as production_approved,
  true as read_only,
  'This folder records result intake only. Do not run mutation SQL.' as instruction;
