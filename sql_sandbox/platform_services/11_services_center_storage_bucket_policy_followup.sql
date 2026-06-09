-- Services Center — Storage Bucket Policy Follow-up Intake
-- Date: 2026-05-08
-- Mode: READ-ONLY / NO-OP
-- Purpose: inspect existing storage buckets, policies, grants, and related functions before deciding
-- whether Services Center request attachments should use document-intelligence, a dedicated bucket,
-- or a Document Intelligence mediated workflow.

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
where b.id ilike any (array[
  '%document%',
  '%intelligence%',
  '%service%',
  '%request%',
  '%attachment%',
  '%complaint%'
])
   or b.name ilike any (array[
  '%document%',
  '%intelligence%',
  '%service%',
  '%request%',
  '%attachment%',
  '%complaint%'
])
order by b.id;

select
  'storage_object_counts_by_bucket' as section,
  o.bucket_id,
  count(*)::bigint as object_count,
  max(o.created_at) as latest_created_at,
  max(o.updated_at) as latest_updated_at
from storage.objects o
where o.bucket_id ilike any (array[
  '%document%',
  '%intelligence%',
  '%service%',
  '%request%',
  '%attachment%',
  '%complaint%'
])
group by o.bucket_id
order by o.bucket_id;

select
  'storage_policies' as section,
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
from pg_policies
where schemaname = 'storage'
  and tablename in ('objects', 'buckets')
order by tablename, policyname;

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

select
  'functions_related_to_storage_or_services' as section,
  n.nspname as schema_name,
  p.proname as function_name,
  pg_get_function_arguments(p.oid) as arguments,
  pg_get_function_result(p.oid) as result_type
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname in ('public', 'storage', 'assistant', 'platform_services')
  and (
    p.proname ilike '%storage%'
    or p.proname ilike '%document%'
    or p.proname ilike '%service%'
    or p.proname ilike '%request%'
    or p.proname ilike '%attachment%'
    or p.proname ilike '%complaint%'
  )
order by n.nspname, p.proname;
