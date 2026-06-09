-- DRAFT ONLY. Do not run before schema bootstrap + seed validation.
-- These wrappers are additive v2 surfaces. They do not replace current v1 wrappers.

create or replace view public.v_services_catalog_compat_v2 as
select
  service_entry_key as service_key,
  title_ar,
  title_en,
  description_ar,
  description_en,
  category_key,
  route_path,
  is_active,
  display_order,
  legacy_source,
  'platform_navigation'::text as target_owner_schema,
  'platform_navigation'::text as owner_system,
  raw_payload
from platform_navigation.service_entries
where is_active = true;

create or replace view public.v_home_services_compat_v2 as
select
  home_entry_key as home_service_key,
  title_ar,
  title_en,
  description_ar,
  route_path,
  is_active,
  display_order,
  legacy_source,
  'platform_navigation'::text as target_owner_schema,
  'platform_navigation'::text as owner_system,
  raw_payload
from platform_navigation.home_entries
where is_active = true;

select
  'platform_navigation_compatibility_wrappers_v2_draft'::text as section,
  'DRAFT_ONLY_NO_RUNTIME_SWITCH_BY_THIS_SCRIPT'::text as decision,
  false as destructive_sql_authorized,
  false as delete_authorized_by_this_script,
  false as production_approved;
