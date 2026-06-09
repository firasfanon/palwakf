-- Platform Public Runtime Consolidation surface census — READ ONLY.
-- Run in Supabase SQL editor if exact DB-side confirmation is needed.

with surfaces(surface_name, expected_status) as (
  values
    ('public.v_platform_navigation_services_catalog_from_owner_v1', 'owner_read_certified_by_console_marker'),
    ('public.v_platform_navigation_home_services_from_owner_v1', 'owner_read_certified_by_console_marker'),
    ('public.v_services_catalog_compat_v1', 'legacy_compat_surface_remaining_400_candidate'),
    ('public.services', 'legacy_public_table_preserved_do_not_delete'),
    ('public.home_services', 'legacy_public_table_preserved_do_not_delete'),
    ('public.v_media_news_compat_v1', 'media_runtime_not_navigation_source_proof')
)
select
  'platform_public_runtime_surface_census_read_only' as section,
  s.surface_name,
  to_regclass(s.surface_name) is not null as object_present,
  s.expected_status,
  true as read_only,
  false as production_approved,
  false as destructive_sql_authorized
from surfaces s
order by s.surface_name;
