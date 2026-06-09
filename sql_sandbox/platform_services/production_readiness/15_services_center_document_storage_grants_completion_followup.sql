-- 15_services_center_document_storage_grants_completion_followup.sql
-- PalWakf / Services Center
-- Purpose: read-only completion intake for Document Intelligence policies, grants, and storage paths.
-- Safe to run in production: YES, read-only only.
-- Do not run any production migration files based on this file alone.

-- 01) Assistant document table policies.
select
  'assistant_document_policies' as section,
  schemaname,
  tablename,
  policyname,
  cmd,
  roles,
  qual,
  with_check
from pg_policies
where schemaname = 'assistant'
  and tablename in (
    'document_jobs',
    'document_files',
    'document_reviews',
    'document_operational_actions',
    'document_file_type_uat_evidence'
  )
order by tablename, policyname;

-- 02) Assistant document table grants.
select
  'assistant_document_table_grants' as section,
  table_schema,
  table_name,
  grantee,
  privilege_type,
  is_grantable
from information_schema.table_privileges
where table_schema = 'assistant'
  and table_name in (
    'document_jobs',
    'document_files',
    'document_reviews',
    'document_operational_actions',
    'document_file_type_uat_evidence'
  )
order by table_name, grantee, privilege_type;

-- 03) Public RPC grants for document/service/complaint wrappers.
select
  'public_rpc_grants_document_services_complaints' as section,
  n.nspname as schema_name,
  p.proname as function_name,
  pg_get_function_identity_arguments(p.oid) as arguments,
  r.rolname as grantee,
  has_function_privilege(r.oid, p.oid, 'EXECUTE') as can_execute
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
cross join pg_roles r
where n.nspname = 'public'
  and (
    p.proname like 'rpc_document_%'
    or p.proname like 'pwf_%complaint%'
    or p.proname like 'rpc_services_%'
  )
  and r.rolname in ('anon','authenticated','service_role')
order by p.proname, r.rolname;

-- 04) Storage bucket metadata for document-intelligence and possible services buckets.
select
  'storage_bucket_metadata' as section,
  id,
  name,
  public,
  file_size_limit,
  allowed_mime_types,
  created_at,
  updated_at
from storage.buckets
where id in ('document-intelligence','services-requests','service-requests','complaint-attachments')
   or name in ('document-intelligence','services-requests','service-requests','complaint-attachments')
order by name;

-- 05) Storage objects policies.
select
  'storage_object_policies' as section,
  schemaname,
  tablename,
  policyname,
  cmd,
  roles,
  qual,
  with_check
from pg_policies
where schemaname = 'storage'
  and tablename in ('objects','buckets')
order by tablename, policyname;

-- 06) Storage table grants.
select
  'storage_table_grants' as section,
  table_schema,
  table_name,
  grantee,
  privilege_type,
  is_grantable
from information_schema.table_privileges
where table_schema = 'storage'
  and table_name in ('objects','buckets')
order by table_name, grantee, privilege_type;

-- 07) Object counts by bucket.
select
  'storage_object_counts_by_bucket' as section,
  bucket_id,
  count(*) as objects_count,
  min(created_at) as first_object_at,
  max(created_at) as latest_object_at
from storage.objects
where bucket_id in ('document-intelligence','services-requests','service-requests','complaint-attachments')
group by bucket_id
order by bucket_id;

-- 08) Sample object paths for document-intelligence only. Limited and metadata-only.
select
  'document_intelligence_object_path_sample' as section,
  bucket_id,
  name,
  owner,
  created_at,
  updated_at,
  last_accessed_at,
  metadata
from storage.objects
where bucket_id = 'document-intelligence'
order by created_at desc
limit 20;

-- 09) Existing complaint attachment path sample. Limited and metadata-only.
select
  'complaint_attachment_path_sample' as section,
  complaint_reference_code,
  file_name,
  storage_path,
  mime_type,
  size_bytes,
  created_at,
  unit_id
from public.pwf_complaint_attachments
order by created_at desc
limit 20;

-- 10) Existing services catalog columns needed before linking requests.
select
  'public_services_columns' as section,
  table_schema,
  table_name,
  ordinal_position,
  column_name,
  data_type,
  udt_name,
  is_nullable,
  column_default
from information_schema.columns
where table_schema = 'public'
  and table_name in ('services','servicetypes','serviceproviders','servicepoints')
order by table_name, ordinal_position;
