with counts as (
  select 'public.services'::text as key, case when to_regclass('public.services') is not null then (select count(*)::bigint from public.services) else 0 end as legacy_count
  union all
  select 'public.home_services', case when to_regclass('public.home_services') is not null then (select count(*)::bigint from public.home_services) else 0 end
), target_counts as (
  select 'public.services'::text as key, case when to_regclass('platform_navigation.service_entries') is not null then (select count(*)::bigint from platform_navigation.service_entries where legacy_source = 'public.services') else 0 end as target_count
  union all
  select 'public.home_services', case when to_regclass('platform_navigation.home_entries') is not null then (select count(*)::bigint from platform_navigation.home_entries where legacy_source = 'public.home_services') else 0 end
)
select
  'platform_navigation_migration_validation'::text as section,
  c.key as legacy_source,
  c.legacy_count,
  t.target_count,
  (c.legacy_count = t.target_count and c.legacy_count > 0) as count_parity_passed,
  case
    when t.target_count = 0 then 'TARGET_NOT_SEEDED_OR_SCHEMA_NOT_APPLIED'
    when c.legacy_count = t.target_count then 'COUNT_PARITY_PASSED_BROWSER_UAT_REQUIRED'
    else 'COUNT_MISMATCH_DO_NOT_SWITCH_RUNTIME'
  end as validation_decision,
  false as delete_authorized_by_this_script,
  false as runtime_switch_authorized_by_this_script,
  false as destructive_sql_authorized,
  false as production_approved,
  true as read_only
from counts c
join target_counts t on t.key = c.key
order by c.key;
