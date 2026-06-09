-- PalWakf Platform — Services Center Public Services Catalog Follow-up
-- Date: 2026-05-08
-- Safety: READ ONLY. This script does not create, alter, insert, update, or delete.
-- Purpose: inspect existing public service catalog tables before any production integration migration.

-- 01. Table existence + RLS status
select
  'service_catalog_tables_rls' as section,
  n.nspname as schema_name,
  c.relname as table_name,
  c.relrowsecurity as rls_enabled,
  c.relforcerowsecurity as force_rls
from pg_class c
join pg_namespace n on n.oid = c.relnamespace
where n.nspname = 'public'
  and c.relkind = 'r'
  and c.relname in ('services', 'servicepoints', 'serviceproviders', 'servicetypes')
order by c.relname;

-- 02. Columns
select
  'service_catalog_columns' as section,
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
  and table_name in ('services', 'servicepoints', 'serviceproviders', 'servicetypes')
order by table_name, ordinal_position;

-- 03. Constraints / keys
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
  and tc.table_name in ('services', 'servicepoints', 'serviceproviders', 'servicetypes')
order by tc.table_name, tc.constraint_type, tc.constraint_name, kcu.ordinal_position;

-- 04. Indexes
select
  'service_catalog_indexes' as section,
  schemaname,
  tablename,
  indexname,
  indexdef
from pg_indexes
where schemaname = 'public'
  and tablename in ('services', 'servicepoints', 'serviceproviders', 'servicetypes')
order by tablename, indexname;

-- 05. Policies
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
  and tablename in ('services', 'servicepoints', 'serviceproviders', 'servicetypes')
order by tablename, policyname;

-- 06. Grants
select
  'service_catalog_grants' as section,
  table_schema,
  table_name,
  grantee,
  privilege_type,
  is_grantable
from information_schema.table_privileges
where table_schema = 'public'
  and table_name in ('services', 'servicepoints', 'serviceproviders', 'servicetypes')
order by table_name, grantee, privilege_type;

-- 07. Triggers
select
  'service_catalog_triggers' as section,
  event_object_schema,
  event_object_table,
  trigger_name,
  event_manipulation,
  action_timing,
  action_statement
from information_schema.triggers
where event_object_schema = 'public'
  and event_object_table in ('services', 'servicepoints', 'serviceproviders', 'servicetypes')
order by event_object_table, trigger_name;

-- 08. Safe row counts
select 'service_catalog_row_counts' as section, 'public' as schema_name, 'services' as table_name, count(*)::bigint as row_count from public.services
union all
select 'service_catalog_row_counts', 'public', 'servicepoints', count(*)::bigint from public.servicepoints
union all
select 'service_catalog_row_counts', 'public', 'serviceproviders', count(*)::bigint from public.serviceproviders
union all
select 'service_catalog_row_counts', 'public', 'servicetypes', count(*)::bigint from public.servicetypes
order by table_name;

-- 09. Safe service samples
select
  'services_sample' as section,
  id,
  title,
  icon,
  link,
  is_active,
  order_index
from public.services
order by coalesce(order_index, 0), title
limit 20;

-- 10. Safe service type samples
select
  'servicetypes_sample' as section,
  id,
  name,
  unit
from public.servicetypes
order by id
limit 20;

-- 11. Safe providers sample
select
  'serviceproviders_sample' as section,
  id,
  name,
  service_type_id,
  website,
  support_phone
from public.serviceproviders
order by id
limit 20;

-- 12. Safe service points sample
select
  'servicepoints_sample' as section,
  id,
  asset_id,
  service_type_id,
  provider_id,
  service_identifier,
  description,
  is_active
from public.servicepoints
order by id
limit 20;

-- 13. Candidate route analysis from public.services.link
select
  'services_route_analysis' as section,
  case
    when link is null or trim(link) = '' then 'missing_link'
    when link like '/services/request%' then 'request_entry'
    when link like '/services/track%' then 'tracking_entry'
    when link like '/%' then 'internal_route'
    when link like 'http%' then 'external_url'
    else 'other'
  end as link_kind,
  count(*)::bigint as count
from public.services
group by 1, 2
order by link_kind;
