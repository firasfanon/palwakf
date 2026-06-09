-- 17_services_center_public_services_catalog_completion_followup.sql
-- Purpose: Complete read-only intake for the existing public service catalog tables.
-- Safety: READ ONLY. Does not create, alter, insert, update, or delete.

-- 1) RLS state for service catalog tables
select
  'service_catalog_tables_rls' as section,
  n.nspname as schema_name,
  c.relname as table_name,
  c.relrowsecurity as rls_enabled,
  c.relforcerowsecurity as force_rls
from pg_class c
join pg_namespace n on n.oid = c.relnamespace
where n.nspname = 'public'
  and c.relkind in ('r','p')
  and c.relname in ('services','servicetypes','serviceproviders','servicepoints')
order by c.relname;

-- 2) Constraints
select
  'service_catalog_constraints' as section,
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
where tc.table_schema = 'public'
  and tc.table_name in ('services','servicetypes','serviceproviders','servicepoints')
order by tc.table_name, tc.constraint_type, tc.constraint_name, kcu.ordinal_position;

-- 3) Indexes
select
  'service_catalog_indexes' as section,
  schemaname,
  tablename,
  indexname,
  indexdef
from pg_indexes
where schemaname = 'public'
  and tablename in ('services','servicetypes','serviceproviders','servicepoints')
order by tablename, indexname;

-- 4) Policies
select
  'service_catalog_policies' as section,
  schemaname,
  tablename,
  policyname,
  cmd,
  roles,
  qual,
  with_check
from pg_policies
where schemaname = 'public'
  and tablename in ('services','servicetypes','serviceproviders','servicepoints')
order by tablename, policyname;

-- 5) Grants
select
  'service_catalog_grants' as section,
  table_schema,
  table_name,
  grantee,
  privilege_type,
  is_grantable
from information_schema.table_privileges
where table_schema = 'public'
  and table_name in ('services','servicetypes','serviceproviders','servicepoints')
order by table_name, grantee, privilege_type;

-- 6) Row counts
select 'service_catalog_row_counts' as section, 'public' as schema_name, 'services' as table_name, count(*)::bigint as row_count from public.services
union all
select 'service_catalog_row_counts', 'public', 'servicetypes', count(*)::bigint from public.servicetypes
union all
select 'service_catalog_row_counts', 'public', 'serviceproviders', count(*)::bigint from public.serviceproviders
union all
select 'service_catalog_row_counts', 'public', 'servicepoints', count(*)::bigint from public.servicepoints
order by table_name;

-- 7) services sample
select
  'services_sample' as section,
  id::text,
  title,
  icon,
  link,
  is_active::text,
  order_index::text
from public.services
order by coalesce(order_index, 0), title
limit 50;

-- 8) serviceproviders sample
select
  'serviceproviders_sample' as section,
  id::text,
  name,
  service_type_id::text,
  website,
  support_phone
from public.serviceproviders
order by id
limit 50;

-- 9) servicepoints sample
select
  'servicepoints_sample' as section,
  id::text,
  asset_id::text,
  service_type_id::text,
  provider_id::text,
  service_identifier,
  description,
  is_active::text
from public.servicepoints
order by id
limit 50;

-- 10) service route/link analysis
select
  'services_route_analysis' as section,
  id::text,
  title,
  link,
  case
    when link is null or trim(link) = '' then 'no_link'
    when link like '/%' then 'internal_route'
    when link ilike 'http%' then 'external_url'
    else 'unknown_or_relative'
  end as link_kind,
  case
    when link ilike '%complaint%' or title ilike '%شكوى%' then 'complaints_related'
    when link ilike '%request%' or title ilike '%طلب%' then 'request_related'
    when link ilike '%form%' or title ilike '%نموذج%' then 'forms_related'
    when link ilike '%pay%' or title ilike '%دفع%' then 'billing_related'
    else 'general_service'
  end as inferred_service_family
from public.services
order by coalesce(order_index, 0), title
limit 100;
