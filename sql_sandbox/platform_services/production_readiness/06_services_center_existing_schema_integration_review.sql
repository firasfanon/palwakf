-- PalWakf Platform Services Center
-- Existing Schema Integration Review
-- 06 - Read-only integration inventory
-- Date: 2026-05-08
-- Status: READ-ONLY / SAFE TO RUN FOR INVENTORY
-- Purpose:
--   Inspect existing service, complaint, permission, unit, and storage structures before
--   approving Services Center production DDL.
--   This file must be run before files 01-05 are considered for production.

select
  current_database() as database_name,
  current_user as sql_user,
  now() as checked_at;

-- 1) Confirm presence of existing Services Center adjacent tables.
select
  to_regclass('public.services') as public_services,
  to_regclass('public.servicetypes') as public_servicetypes,
  to_regclass('public.serviceproviders') as public_serviceproviders,
  to_regclass('public.servicepoints') as public_servicepoints,
  to_regclass('public.pwf_complaints') as public_pwf_complaints,
  to_regclass('public.pwf_complaint_attachments') as public_pwf_complaint_attachments,
  to_regclass('public.pwf_complaint_updates') as public_pwf_complaint_updates,
  to_regclass('public.platform_permissions') as public_platform_permissions,
  to_regclass('public.user_permissions') as public_user_permissions,
  to_regclass('public.user_system_permissions') as public_user_system_permissions,
  to_regclass('public.user_system_roles') as public_user_system_roles,
  to_regclass('public.user_scope_assignments') as public_user_scope_assignments,
  to_regclass('public.user_scope_assignment_units') as public_user_scope_assignment_units,
  to_regclass('core.org_units') as core_org_units,
  to_regclass('core.org_unit_profiles') as core_org_unit_profiles,
  to_regclass('storage.objects') as storage_objects,
  to_regclass('storage.buckets') as storage_buckets,
  to_regnamespace('platform_services') as platform_services_schema;

-- 2) Inspect columns of existing service/complaint/permission/unit tables.
select
  c.table_schema,
  c.table_name,
  c.ordinal_position,
  c.column_name,
  c.data_type,
  c.udt_name,
  c.is_nullable,
  c.column_default
from information_schema.columns c
where (c.table_schema, c.table_name) in (
  ('public', 'services'),
  ('public', 'servicetypes'),
  ('public', 'serviceproviders'),
  ('public', 'servicepoints'),
  ('public', 'pwf_complaints'),
  ('public', 'pwf_complaint_attachments'),
  ('public', 'pwf_complaint_updates'),
  ('public', 'platform_permissions'),
  ('public', 'user_permissions'),
  ('public', 'user_system_permissions'),
  ('public', 'user_system_roles'),
  ('public', 'user_scope_assignments'),
  ('public', 'user_scope_assignment_units'),
  ('core', 'org_units'),
  ('core', 'org_unit_profiles')
)
order by c.table_schema, c.table_name, c.ordinal_position;

-- 3) Inspect primary keys and foreign keys for the same tables.
select
  tc.table_schema,
  tc.table_name,
  tc.constraint_name,
  tc.constraint_type,
  kcu.column_name,
  ccu.table_schema as foreign_table_schema,
  ccu.table_name as foreign_table_name,
  ccu.column_name as foreign_column_name
from information_schema.table_constraints tc
left join information_schema.key_column_usage kcu
  on tc.constraint_name = kcu.constraint_name
 and tc.table_schema = kcu.table_schema
 and tc.table_name = kcu.table_name
left join information_schema.constraint_column_usage ccu
  on tc.constraint_name = ccu.constraint_name
 and tc.table_schema = ccu.table_schema
where (tc.table_schema, tc.table_name) in (
  ('public', 'services'),
  ('public', 'servicetypes'),
  ('public', 'serviceproviders'),
  ('public', 'servicepoints'),
  ('public', 'pwf_complaints'),
  ('public', 'pwf_complaint_attachments'),
  ('public', 'pwf_complaint_updates'),
  ('public', 'platform_permissions'),
  ('public', 'user_permissions'),
  ('public', 'user_system_permissions'),
  ('public', 'user_system_roles'),
  ('public', 'user_scope_assignments'),
  ('public', 'user_scope_assignment_units'),
  ('core', 'org_units'),
  ('core', 'org_unit_profiles')
)
order by tc.table_schema, tc.table_name, tc.constraint_type, tc.constraint_name;

-- 4) Inspect RLS policies on related tables.
select
  schemaname,
  tablename,
  policyname,
  cmd,
  roles,
  qual,
  with_check
from pg_policies
where (schemaname, tablename) in (
  ('public', 'services'),
  ('public', 'servicetypes'),
  ('public', 'serviceproviders'),
  ('public', 'servicepoints'),
  ('public', 'pwf_complaints'),
  ('public', 'pwf_complaint_attachments'),
  ('public', 'pwf_complaint_updates'),
  ('public', 'platform_permissions'),
  ('public', 'user_permissions'),
  ('public', 'user_system_permissions'),
  ('public', 'user_system_roles'),
  ('public', 'user_scope_assignments'),
  ('public', 'user_scope_assignment_units'),
  ('core', 'org_units'),
  ('core', 'org_unit_profiles')
)
order by schemaname, tablename, policyname;

-- 5) Inspect helper functions likely relevant to service requests/RBAC.
select
  n.nspname as schema_name,
  p.proname as function_name,
  pg_get_function_identity_arguments(p.oid) as args,
  p.prosecdef as security_definer
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where p.proname ilike '%service%'
   or p.proname ilike '%permission%'
   or p.proname ilike '%rbac%'
   or p.proname ilike '%access%'
   or p.proname ilike '%complaint%'
order by n.nspname, p.proname;

-- 6) Inspect existing rpc_services_* functions, if any.
select
  n.nspname as schema_name,
  p.proname as function_name,
  pg_get_function_identity_arguments(p.oid) as args,
  pg_get_function_result(p.oid) as result_type,
  p.prosecdef as security_definer
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where p.proname like 'rpc_services_%'
order by n.nspname, p.proname;

-- 7) Identify potential service key/code/title columns in public.services without assuming final contract.
select
  c.column_name,
  c.data_type,
  c.udt_name,
  c.is_nullable
from information_schema.columns c
where c.table_schema = 'public'
  and c.table_name = 'services'
  and (
    c.column_name ilike '%key%'
    or c.column_name ilike '%code%'
    or c.column_name ilike '%slug%'
    or c.column_name ilike '%title%'
    or c.column_name ilike '%name%'
    or c.column_name ilike '%status%'
    or c.column_name ilike '%type%'
  )
order by c.ordinal_position;

-- 8) Check storage buckets relevant to service attachments.
select
  id,
  name,
  public,
  file_size_limit,
  allowed_mime_types
from storage.buckets
where id ilike '%service%'
   or id ilike '%complaint%'
   or id ilike '%request%'
order by id;
