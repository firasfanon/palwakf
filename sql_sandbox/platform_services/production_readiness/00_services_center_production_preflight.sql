-- PalWakf Platform Services Center
-- Production Data Layer Readiness Pack
-- 00 - Production Preflight / Read-only Inventory
-- Date: 2026-05-08
-- Status: READ-ONLY / SAFE TO RUN FOR INVENTORY
-- Purpose: Inspect production readiness before applying any DDL.

select
  current_database() as database_name,
  current_user as sql_user,
  now() as checked_at;

select
  exists(select 1 from information_schema.schemata where schema_name = 'platform_services') as has_platform_services_schema,
  exists(select 1 from information_schema.schemata where schema_name = 'core') as has_core_schema,
  exists(select 1 from information_schema.schemata where schema_name = 'public') as has_public_schema,
  exists(select 1 from information_schema.schemata where schema_name = 'storage') as has_storage_schema;

select
  to_regclass('core.org_units') as core_org_units,
  to_regclass('core.admin_users') as core_admin_users,
  to_regclass('waqf.waqf_assets') as waqf_assets_table,
  to_regclass('document_intelligence.document_jobs') as document_jobs_table,
  to_regclass('tasks.tasks') as tasks_table,
  to_regclass('cases.cases') as cases_table;

select
  n.nspname as schema_name,
  p.proname as function_name,
  pg_get_function_identity_arguments(p.oid) as args
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where p.proname ilike '%permission%'
   or p.proname ilike '%rbac%'
   or p.proname ilike '%access%'
order by n.nspname, p.proname;

select
  n.nspname as schema_name,
  c.relname as table_name,
  c.relrowsecurity as rls_enabled
from pg_class c
join pg_namespace n on n.oid = c.relnamespace
where n.nspname in ('platform_services', 'core', 'public', 'storage')
  and c.relkind in ('r', 'p')
order by n.nspname, c.relname;



-- Services Center existing schema integration inventory added after production preflight result intake.
-- This does not modify data. It highlights existing objects that must be integrated before DDL.
select
  to_regclass('public.services') as existing_public_services,
  to_regclass('public.servicetypes') as existing_public_servicetypes,
  to_regclass('public.serviceproviders') as existing_public_serviceproviders,
  to_regclass('public.servicepoints') as existing_public_servicepoints,
  to_regclass('public.pwf_complaints') as existing_public_pwf_complaints,
  to_regclass('public.pwf_complaint_attachments') as existing_public_pwf_complaint_attachments,
  to_regclass('public.pwf_complaint_updates') as existing_public_pwf_complaint_updates,
  to_regclass('public.platform_permissions') as existing_public_platform_permissions,
  to_regclass('public.user_system_permissions') as existing_public_user_system_permissions,
  to_regclass('public.user_system_roles') as existing_public_user_system_roles,
  to_regclass('public.user_scope_assignments') as existing_public_user_scope_assignments,
  to_regclass('core.org_units') as existing_core_org_units,
  to_regclass('storage.objects') as existing_storage_objects;

-- Result-intake continuation:
-- After saving this output, run 06 for detailed columns/policies and 08 to classify the uploaded result.
