-- PalWakf Platform Navigation Controlled Seed Validation
-- READ ONLY. Do not mutate public, platform_navigation, or any sovereign schema.

select
  'platform_navigation_controlled_seed_validation_read_only' as section,
  (select count(*) from public.services) as public_services_source_count,
  (select count(*) from platform_navigation.service_entries) as service_entries_total_count,
  (select count(*) from platform_navigation.service_entries where source_public_table = 'public.services') as service_entries_from_public_services_count,
  (select count(*) from public.home_services) as public_home_services_source_count,
  (select count(*) from platform_navigation.home_entries) as home_entries_total_count,
  (select count(*) from platform_navigation.home_entries where source_public_table = 'public.home_services') as home_entries_from_public_home_services_count,
  false as public_services_mutated_by_this_script,
  false as public_home_services_mutated_by_this_script,
  false as wrappers_created_by_this_script,
  false as runtime_switch_executed_by_this_script,
  false as destructive_sql_authorized,
  false as delete_authorized_by_this_script,
  false as production_approved,
  true as read_only;
