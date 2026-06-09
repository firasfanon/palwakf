-- PalWakf Platform — Services Center Existing Columns/Policies Intake
-- Date: 2026-05-08
-- Mode: READ-ONLY / NO DDL / NO DML
-- Purpose:
--   Collect exact column, key, policy, grant, RPC/function, trigger, and storage metadata
--   for integrating the Services Center request layer with existing production schema.
-- Safety:
--   This file must not create, alter, drop, insert, update, or delete anything.
--   It is safe to run on production for inspection because it only reads catalog metadata.

begin;
set local statement_timeout = '30s';
set local lock_timeout = '5s';

-- 01. Target table existence and RLS state.
select
  n.nspname as schema_name,
  c.relname as table_name,
  c.relrowsecurity as rls_enabled,
  c.relforcerowsecurity as force_rls,
  c.relkind as relkind
from pg_class c
join pg_namespace n on n.oid = c.relnamespace
where (n.nspname, c.relname) in (
  ('public', 'services'),
  ('public', 'servicetypes'),
  ('public', 'serviceproviders'),
  ('public', 'servicepoints'),
  ('public', 'pwf_complaints'),
  ('public', 'pwf_complaint_attachments'),
  ('public', 'pwf_complaint_updates'),
  ('public', 'platform_permissions'),
  ('public', 'user_system_permissions'),
  ('public', 'user_system_roles'),
  ('public', 'user_scope_assignments'),
  ('public', 'user_scope_assignment_units'),
  ('public', 'admin_users'),
  ('core', 'org_units'),
  ('core', 'org_unit_profiles'),
  ('storage', 'buckets'),
  ('storage', 'objects'),
  ('platform_services', 'service_forms_registry'),
  ('platform_services', 'service_requests'),
  ('platform_services', 'service_request_status_events'),
  ('platform_services', 'service_request_attachments')
)
order by schema_name, table_name;

-- 02. Exact column inventory for existing and prospective related tables.
select
  c.table_schema,
  c.table_name,
  c.ordinal_position,
  c.column_name,
  c.data_type,
  c.udt_name,
  c.is_nullable,
  c.column_default,
  c.character_maximum_length,
  c.numeric_precision,
  c.numeric_scale
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
  ('public', 'user_system_permissions'),
  ('public', 'user_system_roles'),
  ('public', 'user_scope_assignments'),
  ('public', 'user_scope_assignment_units'),
  ('public', 'admin_users'),
  ('core', 'org_units'),
  ('core', 'org_unit_profiles'),
  ('storage', 'buckets'),
  ('storage', 'objects'),
  ('platform_services', 'service_forms_registry'),
  ('platform_services', 'service_requests'),
  ('platform_services', 'service_request_status_events'),
  ('platform_services', 'service_request_attachments')
)
order by c.table_schema, c.table_name, c.ordinal_position;

-- 03. Primary keys, unique constraints, and foreign keys.
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
 and tc.table_schema = ccu.constraint_schema
where (tc.table_schema, tc.table_name) in (
  ('public', 'services'),
  ('public', 'servicetypes'),
  ('public', 'serviceproviders'),
  ('public', 'servicepoints'),
  ('public', 'pwf_complaints'),
  ('public', 'pwf_complaint_attachments'),
  ('public', 'pwf_complaint_updates'),
  ('public', 'platform_permissions'),
  ('public', 'user_system_permissions'),
  ('public', 'user_system_roles'),
  ('public', 'user_scope_assignments'),
  ('public', 'user_scope_assignment_units'),
  ('public', 'admin_users'),
  ('core', 'org_units'),
  ('core', 'org_unit_profiles'),
  ('platform_services', 'service_forms_registry'),
  ('platform_services', 'service_requests'),
  ('platform_services', 'service_request_status_events'),
  ('platform_services', 'service_request_attachments')
)
order by tc.table_schema, tc.table_name, tc.constraint_type, tc.constraint_name, kcu.ordinal_position;

-- 04. Index inventory for relevant tables.
select
  schemaname as schema_name,
  tablename as table_name,
  indexname,
  indexdef
from pg_indexes
where (schemaname, tablename) in (
  ('public', 'services'),
  ('public', 'pwf_complaints'),
  ('public', 'pwf_complaint_attachments'),
  ('public', 'pwf_complaint_updates'),
  ('public', 'platform_permissions'),
  ('public', 'user_system_permissions'),
  ('public', 'user_system_roles'),
  ('public', 'user_scope_assignments'),
  ('core', 'org_units'),
  ('storage', 'objects'),
  ('platform_services', 'service_forms_registry'),
  ('platform_services', 'service_requests'),
  ('platform_services', 'service_request_status_events'),
  ('platform_services', 'service_request_attachments')
)
order by schema_name, table_name, indexname;

-- 05. Existing RLS policies for relevant tables.
select
  schemaname as schema_name,
  tablename as table_name,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
from pg_policies
where (schemaname, tablename) in (
  ('public', 'services'),
  ('public', 'pwf_complaints'),
  ('public', 'pwf_complaint_attachments'),
  ('public', 'pwf_complaint_updates'),
  ('public', 'platform_permissions'),
  ('public', 'user_system_permissions'),
  ('public', 'user_system_roles'),
  ('public', 'user_scope_assignments'),
  ('core', 'org_units'),
  ('storage', 'objects'),
  ('platform_services', 'service_forms_registry'),
  ('platform_services', 'service_requests'),
  ('platform_services', 'service_request_status_events'),
  ('platform_services', 'service_request_attachments')
)
order by schema_name, table_name, policyname;

-- 06. Existing grants for relevant tables.
select
  table_schema,
  table_name,
  grantee,
  privilege_type,
  is_grantable
from information_schema.role_table_grants
where (table_schema, table_name) in (
  ('public', 'services'),
  ('public', 'pwf_complaints'),
  ('public', 'pwf_complaint_attachments'),
  ('public', 'pwf_complaint_updates'),
  ('public', 'platform_permissions'),
  ('public', 'user_system_permissions'),
  ('public', 'user_system_roles'),
  ('public', 'user_scope_assignments'),
  ('core', 'org_units'),
  ('storage', 'objects'),
  ('platform_services', 'service_forms_registry'),
  ('platform_services', 'service_requests'),
  ('platform_services', 'service_request_status_events'),
  ('platform_services', 'service_request_attachments')
)
order by table_schema, table_name, grantee, privilege_type;

-- 07. Existing service / complaint / platform permission functions and RPC wrappers.
select
  n.nspname as schema_name,
  p.proname as function_name,
  pg_get_function_arguments(p.oid) as arguments,
  pg_get_function_result(p.oid) as result_type,
  l.lanname as language,
  p.prosecdef as security_definer,
  p.provolatile as volatility
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
join pg_language l on l.oid = p.prolang
where n.nspname in ('public', 'core', 'platform_services')
  and (
    p.proname ilike '%service%'
    or p.proname ilike '%request%'
    or p.proname ilike '%complaint%'
    or p.proname ilike '%permission%'
    or p.proname ilike '%rbac%'
    or p.proname ilike '%scope%'
  )
order by schema_name, function_name;

-- 08. Trigger inventory for relevant tables.
select
  event_object_schema as table_schema,
  event_object_table as table_name,
  trigger_name,
  event_manipulation,
  action_timing,
  action_statement
from information_schema.triggers
where (event_object_schema, event_object_table) in (
  ('public', 'services'),
  ('public', 'pwf_complaints'),
  ('public', 'pwf_complaint_attachments'),
  ('public', 'pwf_complaint_updates'),
  ('public', 'platform_permissions'),
  ('public', 'user_system_permissions'),
  ('public', 'user_system_roles'),
  ('public', 'user_scope_assignments'),
  ('core', 'org_units'),
  ('platform_services', 'service_forms_registry'),
  ('platform_services', 'service_requests'),
  ('platform_services', 'service_request_status_events'),
  ('platform_services', 'service_request_attachments')
)
order by table_schema, table_name, trigger_name, event_manipulation;

-- 09. Storage buckets relevant to service request attachments.
select
  id,
  name,
  owner,
  public,
  file_size_limit,
  allowed_mime_types,
  created_at,
  updated_at
from storage.buckets
where name in (
  'service-request-attachments',
  'services-request-attachments',
  'complaint-attachments',
  'pwf-complaint-attachments',
  'documents',
  'document-intelligence',
  'public'
)
order by name;

-- 10. Existing storage object prefix scan for complaint/service/document related folders.
select
  bucket_id,
  split_part(name, '/', 1) as top_level_prefix,
  count(*) as object_count,
  max(created_at) as latest_object_created_at
from storage.objects
where name ilike 'service%/%'
   or name ilike 'request%/%'
   or name ilike 'complaint%/%'
   or name ilike 'documents/%'
   or name ilike 'document_intelligence/%'
group by bucket_id, split_part(name, '/', 1)
order by bucket_id, top_level_prefix;

-- 11. Current platform service permissions related to services/requests/complaints.
-- Uses to_jsonb to avoid assuming exact permission column names.
select *
from public.platform_permissions p
where to_jsonb(p)::text ilike '%service%'
   or to_jsonb(p)::text ilike '%request%'
   or to_jsonb(p)::text ilike '%complaint%'
   or to_jsonb(p)::text ilike '%خدم%'
   or to_jsonb(p)::text ilike '%طلب%'
   or to_jsonb(p)::text ilike '%شكوى%'
limit 100;

-- 12. Existing service catalog sample structure, limited to avoid exposing large data.
select *
from public.services
order by 1
limit 20;

-- 13. Existing complaint table sample shape, limited and intentionally not joined.
-- Review in trusted admin context only; do not share personal data in public channels.
select *
from public.pwf_complaints
order by 1 desc
limit 10;

rollback;
