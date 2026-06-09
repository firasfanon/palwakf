-- Read-only preflight. This script does not assume registry table names.
select 'assistant_schema_present' as check_key,
       (to_regnamespace('assistant') is not null) as passed,
       'Checks whether assistant schema exists; no DDL/DML.' as note
union all
select 'platform_schema_present', (to_regnamespace('platform') is not null), 'Platform schema presence only.'
union all
select 'awqaf_system_schema_present', (to_regnamespace('awqaf_system') is not null), 'Awqaf System schema presence only.'
union all
select 'no_service_role_frontend_required', true, 'Contract check only; inspect Flutter separately.';
