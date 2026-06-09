-- Platform Database Dependency Wave A
-- 33: SQL29B no-schema-token exact body review matrix (read-only)
-- Purpose: replace SQL 29 entirely after repeated SQL-runner ERROR 42P01 relation parser failures.
-- Design: no VALUES recordset, no CTE, no schema-qualified object tokens in the matrix body.
-- No DDL/DML/GRANT/DROP/archive/delete/exact public replacement/auth migration/waqf mutation.

select
  'wave_a_sql29b_no_schema_token_review_matrix'::text as section,
  'assistant_access'::text as owner_family,
  'admin_column_discovery_helper'::text as object_key,
  'function'::text as object_kind,
  'legacy_admin_profile_lookup'::text as observed_dependency,
  'REVIEW_FOR_ACCESS_HELPER_REPLACEMENT'::text as review_decision,
  true as wave_a_execution_candidate,
  false as excluded_from_execution,
  false as exact_body_review_complete,
  false as execution_authorized,
  false as production_approved,
  false as destructive_sql_authorized,
  false as exact_public_table_replacement_authorized,
  true as no_auth_users_migration,
  true as no_flutter_elevated_secret,
  true as no_waqf_assets_mutation,
  true as read_only,
  'Candidate may be rewritten only after exact body approval and actor evidence.'::text as note
union all
select 'wave_a_sql29b_no_schema_token_review_matrix','assistant_access','assistant_manage_access_helper','function','legacy_admin_profile_lookup','REVIEW_FOR_ACCESS_HELPER_REPLACEMENT',true,false,false,false,false,false,false,true,true,true,true,'High priority; negative UAT required before any guarded body.'
union all
select 'wave_a_sql29b_no_schema_token_review_matrix','assistant_access','assistant_authenticated_admin_helper','function','legacy_admin_profile_lookup','REVIEW_FOR_ACCESS_HELPER_REPLACEMENT',true,false,false,false,false,false,false,true,true,true,true,'High priority; negative UAT required before any guarded body.'
union all
select 'wave_a_sql29b_no_schema_token_review_matrix','assistant_access','assistant_child_helpers','function','depends_on_parent_access_helpers','DEPENDENCY_FOLLOWS_PARENT_HELPER',false,false,false,false,false,false,false,true,true,true,true,'No separate guarded body unless parent helper is approved.'
union all
select 'wave_a_sql29b_no_schema_token_review_matrix','platform_access_helpers','unit_edit_access_helper','function','legacy_admin_and_permission_lookup','REVIEW_FOR_PLATFORM_ACCESS_HELPER_REPLACEMENT',true,false,false,false,false,false,false,true,true,true,true,'Candidate only; no execution until token, backup, and UAT evidence are supplied.'
union all
select 'wave_a_sql29b_no_schema_token_review_matrix','platform_access_helpers','admin_user_boolean_helper','function','legacy_admin_profile_lookup','REVIEW_FOR_ACCESS_HELPER_REPLACEMENT',true,false,false,false,false,false,false,true,true,true,true,'Simple candidate but still blocked until exact approval.'
union all
select 'wave_a_sql29b_no_schema_token_review_matrix','platform_access_helpers','legacy_community_import_loader','function','contains_operational_import_dml','EXCLUDE_FROM_WAVE_A_EXECUTION_OPERATIONAL_DML',false,true,false,false,false,false,false,true,true,true,true,'Excluded from Wave A execution; not an owner-wrapper access remediation.'
union all
select 'wave_a_sql29b_no_schema_token_review_matrix','platform_access_helpers','legacy_excel_import_loader','function','contains_operational_import_dml','EXCLUDE_FROM_WAVE_A_EXECUTION_OPERATIONAL_DML',false,true,false,false,false,false,false,true,true,true,true,'Excluded from Wave A execution; not an owner-wrapper access remediation.'
union all
select 'wave_a_sql29b_no_schema_token_review_matrix','platform_access_helpers','lineage_refresh_routine','function','contains_operational_update_dml','EXCLUDE_FROM_WAVE_A_EXECUTION_OPERATIONAL_DML',false,true,false,false,false,false,false,true,true,true,true,'Excluded from Wave A execution; not an owner-wrapper access remediation.'
union all
select 'wave_a_sql29b_no_schema_token_review_matrix','tasks_access','audit_task_manage_helper','function','legacy_admin_role_permission_lookup','REVIEW_FOR_TASKS_ACCESS_HELPER_REPLACEMENT',true,false,false,false,false,false,false,true,true,true,true,'Main tasks candidate; downstream routines follow this helper.'
union all
select 'wave_a_sql29b_no_schema_token_review_matrix','tasks_access','audit_task_child_routines','function','depends_on_tasks_access_helper','DEPENDENCY_FOLLOWS_PARENT_HELPER',false,false,false,false,false,false,false,true,true,true,true,'No separate guarded body unless parent helper is approved.'
union all
select 'wave_a_sql29b_no_schema_token_review_matrix','media_public_read','published_content_public_view','view','owner_schema_public_view','ACCEPT_AS_OWNER_SCHEMA_PUBLIC_VIEW',false,false,false,false,false,false,false,true,true,true,true,'Accepted; no Wave A remediation required.'
order by owner_family, object_key;
