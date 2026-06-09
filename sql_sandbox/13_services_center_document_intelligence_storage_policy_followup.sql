-- PalWakf Platform — Services Center
-- Document Intelligence Storage Policy Follow-up
-- Date: 2026-05-08
-- Mode: READ ONLY / NO-OP
-- Purpose: collect policy/grant/storage evidence before any production migration for service request attachments.

-- 01) Storage buckets relevant to document intelligence / services
select
  'storage_buckets_relevant' as section,
  b.id,
  b.name,
  b.public,
  b.file_size_limit,
  b.allowed_mime_types,
  b.created_at,
  b.updated_at
from storage.buckets b
where b.id ilike '%document%'
   or b.name ilike '%document%'
   or b.id ilike '%service%'
   or b.name ilike '%service%'
order by b.id;

-- 02) Storage RLS policies for buckets and objects
select
  'storage_policies' as section,
  p.schemaname,
  p.tablename,
  p.policyname,
  p.cmd,
  p.roles,
  p.qual,
  p.with_check
from pg_policies p
where p.schemaname = 'storage'
  and p.tablename in ('objects', 'buckets')
order by p.tablename, p.policyname;

-- 03) Storage table grants
select
  'storage_table_grants' as section,
  table_schema,
  table_name,
  grantee,
  privilege_type,
  is_grantable
from information_schema.role_table_grants
where table_schema = 'storage'
  and table_name in ('objects', 'buckets')
order by table_name, grantee, privilege_type;

-- 04) Object counts by bucket
select
  'storage_object_counts_by_bucket' as section,
  o.bucket_id,
  count(*)::bigint as object_count,
  max(o.created_at) as latest_object_created_at,
  max(o.updated_at) as latest_object_updated_at
from storage.objects o
group by o.bucket_id
order by object_count desc, o.bucket_id;

-- 05) Object path sample for document-intelligence bucket only
select
  'document_intelligence_object_path_sample' as section,
  o.bucket_id,
  o.name,
  o.owner,
  o.metadata,
  o.created_at,
  o.updated_at
from storage.objects o
where o.bucket_id = 'document-intelligence'
order by o.created_at desc
limit 20;

-- 06) Assistant table RLS state for document jobs/files
select
  'assistant_document_tables_rls_state' as section,
  n.nspname as schema_name,
  c.relname as table_name,
  c.relrowsecurity as rls_enabled,
  c.relforcerowsecurity as rls_forced
from pg_class c
join pg_namespace n on n.oid = c.relnamespace
where n.nspname = 'assistant'
  and c.relkind in ('r','p')
  and c.relname in ('document_jobs', 'document_files', 'document_file_type_uat_evidence')
order by c.relname;

-- 07) Assistant RLS policies for document jobs/files
select
  'assistant_document_policies' as section,
  p.schemaname,
  p.tablename,
  p.policyname,
  p.cmd,
  p.roles,
  p.qual,
  p.with_check
from pg_policies p
where p.schemaname = 'assistant'
  and p.tablename in ('document_jobs', 'document_files', 'document_file_type_uat_evidence')
order by p.tablename, p.policyname;

-- 08) Assistant table grants for document jobs/files
select
  'assistant_document_table_grants' as section,
  table_schema,
  table_name,
  grantee,
  privilege_type,
  is_grantable
from information_schema.role_table_grants
where table_schema = 'assistant'
  and table_name in ('document_jobs', 'document_files', 'document_file_type_uat_evidence')
order by table_name, grantee, privilege_type;

-- 09) Public RPC grants for document upload/job functions
select
  'public_document_rpc_grants' as section,
  routine_schema,
  routine_name,
  grantee,
  privilege_type,
  is_grantable
from information_schema.routine_privileges
where routine_schema = 'public'
  and routine_name in (
    'rpc_document_job_create_v1',
    'rpc_document_source_file_register_v1',
    'rpc_document_job_get_v1',
    'rpc_document_job_list_v1',
    'rpc_document_job_result_v1'
  )
order by routine_name, grantee, privilege_type;

-- 10) Public RPC signatures for document upload/job functions
select
  'public_document_rpc_signatures' as section,
  n.nspname as schema_name,
  p.proname as function_name,
  pg_get_function_identity_arguments(p.oid) as arguments,
  pg_get_function_result(p.oid) as result_type,
  p.prosecdef as security_definer
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'public'
  and p.proname in (
    'rpc_document_job_create_v1',
    'rpc_document_source_file_register_v1',
    'rpc_document_job_get_v1',
    'rpc_document_job_list_v1',
    'rpc_document_job_result_v1'
  )
order by p.proname;

-- 11) Existing complaint attachment columns for integration comparison
select
  'complaint_attachment_columns' as section,
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
  and table_name in ('pwf_complaint_attachments', 'pwf_complaint_updates', 'pwf_complaints')
order by table_name, ordinal_position;

-- 12) Complaint attachment policies
select
  'complaint_attachment_policies' as section,
  p.schemaname,
  p.tablename,
  p.policyname,
  p.cmd,
  p.roles,
  p.qual,
  p.with_check
from pg_policies p
where p.schemaname = 'public'
  and p.tablename in ('pwf_complaint_attachments', 'pwf_complaint_updates', 'pwf_complaints')
order by p.tablename, p.policyname;
