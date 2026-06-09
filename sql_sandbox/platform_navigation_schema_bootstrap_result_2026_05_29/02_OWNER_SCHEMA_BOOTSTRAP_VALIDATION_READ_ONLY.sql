-- Platform Navigation Owner Schema Bootstrap Validation — READ ONLY
-- Run this before any seed authorization.
-- Expected before seed: all three owner tables exist and counts are 0.

with table_checks as (
  select
    'route_entries' as table_name,
    to_regclass('platform_navigation.route_entries') is not null as table_present,
    (select count(*) from information_schema.columns where table_schema='platform_navigation' and table_name='route_entries') as column_count,
    exists (select 1 from information_schema.columns where table_schema='platform_navigation' and table_name='route_entries' and column_name='entry_key') as entry_key_present,
    exists (select 1 from information_schema.columns where table_schema='platform_navigation' and table_name='route_entries' and column_name='route_path') as route_path_present,
    exists (select 1 from information_schema.columns where table_schema='platform_navigation' and table_name='route_entries' and column_name='sort_order') as sort_order_present,
    (select count(*) from platform_navigation.route_entries) as row_count
  union all
  select
    'service_entries',
    to_regclass('platform_navigation.service_entries') is not null,
    (select count(*) from information_schema.columns where table_schema='platform_navigation' and table_name='service_entries'),
    exists (select 1 from information_schema.columns where table_schema='platform_navigation' and table_name='service_entries' and column_name='entry_key'),
    exists (select 1 from information_schema.columns where table_schema='platform_navigation' and table_name='service_entries' and column_name='route_path'),
    exists (select 1 from information_schema.columns where table_schema='platform_navigation' and table_name='service_entries' and column_name='sort_order'),
    (select count(*) from platform_navigation.service_entries)
  union all
  select
    'home_entries',
    to_regclass('platform_navigation.home_entries') is not null,
    (select count(*) from information_schema.columns where table_schema='platform_navigation' and table_name='home_entries'),
    exists (select 1 from information_schema.columns where table_schema='platform_navigation' and table_name='home_entries' and column_name='entry_key'),
    exists (select 1 from information_schema.columns where table_schema='platform_navigation' and table_name='home_entries' and column_name='route_path'),
    exists (select 1 from information_schema.columns where table_schema='platform_navigation' and table_name='home_entries' and column_name='sort_order'),
    (select count(*) from platform_navigation.home_entries)
), rls_checks as (
  select
    c.relname as table_name,
    c.relrowsecurity as rls_enabled
  from pg_class c
  join pg_namespace n on n.oid = c.relnamespace
  where n.nspname = 'platform_navigation'
    and c.relname in ('route_entries','service_entries','home_entries')
)
select
  'platform_navigation_owner_schema_bootstrap_validation_read_only' as section,
  tc.table_name,
  tc.table_present,
  tc.column_count,
  tc.entry_key_present,
  tc.route_path_present,
  tc.sort_order_present,
  tc.row_count,
  coalesce(rc.rls_enabled, false) as rls_enabled,
  false as public_services_mutated_by_this_script,
  false as public_home_services_mutated_by_this_script,
  false as destructive_sql_authorized,
  false as delete_authorized_by_this_script,
  false as production_approved,
  true as read_only
from table_checks tc
left join rls_checks rc using (table_name)
order by tc.table_name;
