-- Platform Navigation Schema Bootstrap Apply Result Intake — READ ONLY
-- Purpose: record and re-check the accepted development/staging owner-schema bootstrap result.

select
  'platform_navigation_schema_bootstrap_result_intake_read_only' as section,
  exists (select 1 from pg_namespace where nspname = 'platform_navigation') as platform_navigation_schema_present,
  to_regclass('platform_navigation.route_entries') is not null as route_entries_present,
  to_regclass('platform_navigation.service_entries') is not null as service_entries_present,
  to_regclass('platform_navigation.home_entries') is not null as home_entries_present,
  exists (
    select 1 from information_schema.columns
    where table_schema = 'platform_navigation'
      and table_name = 'route_entries'
      and column_name = 'sort_order'
  ) as route_entries_sort_order_present,
  exists (
    select 1 from information_schema.columns
    where table_schema = 'platform_navigation'
      and table_name = 'service_entries'
      and column_name = 'sort_order'
  ) as service_entries_sort_order_present,
  exists (
    select 1 from information_schema.columns
    where table_schema = 'platform_navigation'
      and table_name = 'home_entries'
      and column_name = 'sort_order'
  ) as home_entries_sort_order_present,
  false as public_services_mutated_by_this_script,
  false as public_home_services_mutated_by_this_script,
  false as destructive_sql_authorized,
  false as delete_authorized_by_this_script,
  false as production_approved,
  true as read_only;
