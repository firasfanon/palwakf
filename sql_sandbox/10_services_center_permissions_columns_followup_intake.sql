-- Platform Development — Services Center Permissions/Columns Follow-up Intake
-- Date: 2026-05-08
-- Mode: READ-ONLY / NO-OP
-- Purpose: collect missing metadata before adapting Services Center production migration.
-- This file must not create, alter, insert, update, or delete anything.


-- 00. Existing system_key enum values (helps avoid invalid enum literal assumptions)
select
  'system_key_enum_values' as section,
  e.enumlabel as system_key_value
from pg_type t
join pg_enum e on e.enumtypid = t.oid
where t.typname = 'system_key'
order by e.enumsortorder;

-- 01. Service/platform permissions relevant to Services Center
select
  'platform_permissions_service_related' as section,
  p.key,
  p.system_key,
  p.name_ar,
  p.description_ar,
  p.created_at
from public.platform_permissions p
where
  p.system_key::text in ('platform', 'services', 'service_center', 'media_center')
  or p.key ilike any (array[
    '%service%', '%services%', '%request%', '%requests%', '%form%', '%forms%',
    '%complaint%', '%complaints%', '%surfaces%', '%platform%'
  ])
  or p.name_ar ilike any (array[
    '%خدمة%', '%خدمات%', '%طلب%', '%طلبات%', '%نموذج%', '%نماذج%',
    '%شكوى%', '%شكاوى%', '%منصة%'
  ])
order by p.system_key::text, p.key;

-- 02. Core table existence and RLS state
select
  'table_rls_state' as section,
  n.nspname as schema_name,
  c.relname as table_name,
  c.relrowsecurity as rls_enabled,
  c.relforcerowsecurity as force_rls
from pg_class c
join pg_namespace n on n.oid = c.relnamespace
where n.nspname in ('public', 'core', 'storage')
  and c.relkind in ('r','p')
  and c.relname in (
    'services',
    'pwf_complaints',
    'pwf_complaint_attachments',
    'pwf_complaint_updates',
    'platform_permissions',
    'user_system_permissions',
    'user_system_roles',
    'user_scope_assignments',
    'user_scope_assignment_units',
    'org_units',
    'objects',
    'buckets'
  )
order by schema_name, table_name;

-- 03. Columns for key integration tables
select
  'columns' as section,
  table_schema,
  table_name,
  ordinal_position,
  column_name,
  data_type,
  udt_name,
  is_nullable,
  column_default
from information_schema.columns
where table_schema in ('public', 'core', 'storage')
  and table_name in (
    'services',
    'pwf_complaints',
    'pwf_complaint_attachments',
    'pwf_complaint_updates',
    'platform_permissions',
    'user_system_permissions',
    'user_system_roles',
    'user_scope_assignments',
    'user_scope_assignment_units',
    'org_units',
    'objects',
    'buckets'
  )
order by table_schema, table_name, ordinal_position;

-- 04. RLS policies on key integration tables
select
  'policies' as section,
  schemaname,
  tablename,
  policyname,
  cmd,
  roles,
  qual,
  with_check
from pg_policies
where schemaname in ('public', 'core', 'storage')
  and tablename in (
    'services',
    'pwf_complaints',
    'pwf_complaint_attachments',
    'pwf_complaint_updates',
    'platform_permissions',
    'user_system_permissions',
    'user_system_roles',
    'user_scope_assignments',
    'user_scope_assignment_units',
    'org_units',
    'objects',
    'buckets'
  )
order by schemaname, tablename, policyname;

-- 05. Grants on key tables
select
  'table_privileges' as section,
  table_schema,
  table_name,
  grantee,
  privilege_type,
  is_grantable
from information_schema.table_privileges
where table_schema in ('public', 'core', 'storage')
  and table_name in (
    'services',
    'pwf_complaints',
    'pwf_complaint_attachments',
    'pwf_complaint_updates',
    'platform_permissions',
    'user_system_permissions',
    'user_system_roles',
    'user_scope_assignments',
    'user_scope_assignment_units',
    'org_units',
    'objects',
    'buckets'
  )
order by table_schema, table_name, grantee, privilege_type;

-- 06. Functions/RPC related to services, requests, complaints, forms, permissions
select
  'functions' as section,
  n.nspname as schema_name,
  p.proname as function_name,
  pg_get_function_identity_arguments(p.oid) as arguments,
  pg_get_function_result(p.oid) as result_type,
  p.prosecdef as security_definer
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname in ('public', 'core')
  and (
    p.proname ilike '%service%'
    or p.proname ilike '%request%'
    or p.proname ilike '%complaint%'
    or p.proname ilike '%form%'
    or p.proname ilike '%permission%'
    or p.proname ilike '%rbac%'
  )
order by schema_name, function_name;

-- 07. Storage buckets relevant to services/complaints/documents
select
  'storage_buckets' as section,
  b.id,
  b.name,
  b.public,
  b.file_size_limit,
  b.allowed_mime_types,
  b.created_at,
  b.updated_at
from storage.buckets b
where b.name ilike any (array[
  '%service%', '%services%', '%request%', '%requests%', '%complaint%',
  '%complaints%', '%document%', '%documents%', '%attachment%', '%attachments%'
])
order by b.name;

-- 08. Limited service catalog sample
select
  'services_sample' as section,
  s.*
from public.services s
limit 5;

-- 09. Limited complaints sample - verify columns and status values only
select
  'complaints_sample' as section,
  c.*
from public.pwf_complaints c
limit 5;
