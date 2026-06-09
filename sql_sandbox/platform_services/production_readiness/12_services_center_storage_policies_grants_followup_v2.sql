-- PalWakf Platform — Services Center
-- 12_services_center_storage_policies_grants_followup_v2.sql
-- Purpose: read-only follow-up for storage policies/grants/object counts after partial functions-only result.
-- Safety: READ ONLY. Does not create, alter, update, delete, grant, revoke, or drop anything.

-- 1) Storage buckets of interest
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
where b.id in ('document-intelligence', 'services-requests', 'service-requests', 'public', 'documents')
   or b.name ilike '%document%'
   or b.name ilike '%service%'
   or b.name ilike '%request%'
order by b.id;

-- 2) Storage table RLS flags
select
  'storage_rls_flags' as section,
  n.nspname as schema_name,
  c.relname as table_name,
  c.relrowsecurity as rls_enabled,
  c.relforcerowsecurity as force_rls
from pg_class c
join pg_namespace n on n.oid = c.relnamespace
where n.nspname = 'storage'
  and c.relkind in ('r','p')
order by c.relname;

-- 3) Storage policies
select
  'storage_policies' as section,
  schemaname,
  tablename,
  policyname,
  cmd,
  roles,
  qual,
  with_check
from pg_policies
where schemaname = 'storage'
order by tablename, policyname;

-- 4) Storage table grants
select
  'storage_table_grants' as section,
  table_schema,
  table_name,
  grantee,
  privilege_type,
  is_grantable
from information_schema.table_privileges
where table_schema = 'storage'
  and table_name in ('objects', 'buckets')
order by table_name, grantee, privilege_type;

-- 5) Object counts by bucket. This is aggregate-only.
select
  'storage_object_counts_by_bucket' as section,
  bucket_id,
  count(*) as objects_count,
  max(created_at) as latest_object_created_at
from storage.objects
group by bucket_id
order by bucket_id;

-- 6) Policies or functions mentioning document-intelligence by text definition where visible.
select
  'storage_policy_text_mentions' as section,
  p.schemaname,
  p.tablename,
  p.policyname,
  p.cmd,
  p.roles,
  p.qual,
  p.with_check
from pg_policies p
where p.schemaname = 'storage'
  and (
    coalesce(p.qual, '') ilike '%document-intelligence%'
    or coalesce(p.with_check, '') ilike '%document-intelligence%'
    or coalesce(p.qual, '') ilike '%service%'
    or coalesce(p.with_check, '') ilike '%service%'
    or coalesce(p.qual, '') ilike '%request%'
    or coalesce(p.with_check, '') ilike '%request%'
  )
order by p.tablename, p.policyname;

-- 7) Existing complaint attachment columns, to avoid duplication.
select
  'complaint_attachment_columns' as section,
  c.table_schema,
  c.table_name,
  c.ordinal_position,
  c.column_name,
  c.data_type,
  c.udt_name,
  c.is_nullable,
  c.column_default
from information_schema.columns c
where c.table_schema = 'public'
  and c.table_name in ('pwf_complaint_attachments', 'pwf_complaints', 'pwf_complaint_updates')
order by c.table_name, c.ordinal_position;

-- 8) Document Intelligence file tables/columns if visible through information_schema.
select
  'document_intelligence_file_columns' as section,
  c.table_schema,
  c.table_name,
  c.ordinal_position,
  c.column_name,
  c.data_type,
  c.udt_name,
  c.is_nullable,
  c.column_default
from information_schema.columns c
where c.table_schema in ('assistant', 'public')
  and (
    c.table_name ilike '%document_file%'
    or c.table_name ilike '%document_jobs%'
    or c.table_name ilike '%document_sources%'
  )
order by c.table_schema, c.table_name, c.ordinal_position;
