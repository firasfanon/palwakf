-- Platform Database Dependency Wave A
-- 34: SQL29B safe execution preconditions gate (read-only)
-- Purpose: replace SQL 30 to keep the retry path independent from SQL 29.
-- No DDL/DML/GRANT/DROP/archive/delete/exact public replacement/auth migration/waqf mutation.

select 'wave_a_sql29b_safe_execution_preconditions'::text as section,
       'exact_body_review_complete'::text as gate_key,
       false as passed,
       'SQL 33 matrix can be reviewed, but approved replacement bodies are not authorized yet.'::text as note,
       false as execution_authorized,
       false as production_approved,
       false as destructive_sql_authorized,
       false as exact_public_table_replacement_authorized,
       true as no_auth_users_migration,
       true as no_flutter_elevated_secret,
       true as no_waqf_assets_mutation,
       true as read_only
union all
select 'wave_a_sql29b_safe_execution_preconditions','candidate_scope_limited_to_access_helpers',true,'Candidate scope is limited to assistant/platform/tasks access-helper families; operational import routines are excluded.',false,false,false,false,true,true,true,true
union all
select 'wave_a_sql29b_safe_execution_preconditions','rls_negative_uat_accepted',false,'Anonymous, unauthorized, wrong-unit, scoped, platform-admin, and superuser evidence is still required.',false,false,false,false,true,true,true,true
union all
select 'wave_a_sql29b_safe_execution_preconditions','browser_console_clean_accepted',false,'Admin/public/system route browser and network evidence is still required.',false,false,false,false,true,true,true,true
union all
select 'wave_a_sql29b_safe_execution_preconditions','backup_restore_point_supplied',false,'A real backup/restore point is required before any guarded execution.',false,false,false,false,true,true,true,true
union all
select 'wave_a_sql29b_safe_execution_preconditions','governance_token_supplied',false,'Explicit governance token is required before any guarded execution.',false,false,false,false,true,true,true,true
union all
select 'wave_a_sql29b_safe_execution_preconditions','execution_authorized',false,'Blocked.',false,false,false,false,true,true,true,true
union all
select 'wave_a_sql29b_safe_execution_preconditions','production_gate',false,'NOT_APPROVED.',false,false,false,false,true,true,true,true
order by gate_key;
