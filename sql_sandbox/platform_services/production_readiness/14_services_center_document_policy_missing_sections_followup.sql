-- PalWakf Platform — Services Center
-- 14_services_center_document_policy_missing_sections_followup.sql
-- Purpose: Read-only follow-up for missing Document Intelligence and storage policy/grant evidence.
-- Safe mode: READ ONLY. No DDL, no DML, no grants, no policy changes.

-- 1) Assistant document table RLS policies.
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
    'document_file_type_uat_evidence',
    'document_reviews',
    'document_operational_actions'
  )
order by schemaname, tablename, policyname;

-- 2) Assistant document table grants.
select
  'assistant_document_table_grants' as section,
  table_schema,
  table_name,
  grantee,
  privilege_type,
  is_grantable
from information_schema.role_table_grants
where table_schema = 'assistant'
  and table_name in (
    'document_jobs',
    'document_files',
    'document_file_type_uat_evidence',
    'document_reviews',
    'document_operational_actions'
  )
order by table_schema, table_name, grantee, privilege_type;

-- 3) Public RPC grants for document job/file registration.
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
    'rpc_document_job_list_v1'
  )
order by routine_schema, routine_name, grantee, privilege_type;

-- 4) Storage object policies focused on document-intelligence paths where visible.
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
  and tablename = 'objects'
order by policyname;

-- 5) Storage table grants for buckets and objects.
select
  'storage_table_grants' as section,
  table_schema,
  table_name,
  grantee,
  privilege_type,
  is_grantable
from information_schema.role_table_grants
where table_schema = 'storage'
  and table_name in ('buckets', 'objects')
order by table_schema, table_name, grantee, privilege_type;

-- 6) Existing document-intelligence bucket metadata.
select
  'document_intelligence_bucket' as section,
  id,
  name,
  public,
  file_size_limit,
  allowed_mime_types,
  created_at,
  updated_at
from storage.buckets
where id = 'document-intelligence'
   or name = 'document-intelligence';

-- 7) Object count in document-intelligence bucket.
select
  'document_intelligence_object_count' as section,
  bucket_id,
  count(*) as object_count,
  min(created_at) as oldest_object_at,
  max(created_at) as newest_object_at
from storage.objects
where bucket_id = 'document-intelligence'
group by bucket_id;

-- 8) Complaint attachment columns for final separation decision.
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
order by table_schema, table_name, ordinal_position;
