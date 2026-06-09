-- PalWakf Platform — Mega Batch N2.35
-- 52_platform_system_operations_uat_READ_ONLY_N2_35.sql
-- Purpose: Single-result UAT for system operations console + awqaf_system staging registry + cache gate continuity.
-- Safety: SELECT-only. No DDL/DML. No waqf/waqf_assets/awqaf_system mutation.

with registry as (
  select
    count(*) filter (where lower(replace(system_key::text, '-', '_')) = 'awqaf_system')::bigint as awqaf_rows,
    count(*) filter (where lower(replace(system_key::text, '-', '_')) = 'awqaf_system' and is_active = true)::bigint as awqaf_active_rows,
    count(*) filter (where lower(replace(system_key::text, '-', '_')) = 'awqaf_system' and coalesce(public_route_path::text, '') = '/systems/awqaf-system')::bigint as awqaf_public_route_rows,
    count(*) filter (where lower(replace(system_key::text, '-', '_')) = 'awqaf_system' and coalesce(admin_route_path::text, '') = '/admin/systems/awqaf_system')::bigint as awqaf_admin_route_rows,
    count(*) filter (where lower(replace(system_key::text, '-', '_')) = 'awqaf_system' and coalesce(is_sovereign, false) = true)::bigint as awqaf_sovereign_rows,
    count(*) filter (where lower(replace(system_key::text, '-', '_')) = 'awqaf_system' and coalesce(metadata, '{}'::jsonb) ? 'integration_status')::bigint as awqaf_metadata_rows
  from platform.system_registry
),
sections as (
  select
    count(*) filter (where lower(replace(system_key::text, '-', '_')) = 'awqaf_system')::bigint as awqaf_sections,
    count(*) filter (where lower(replace(system_key::text, '-', '_')) = 'awqaf_system' and section_key in ('dashboard','waqf-assets-intake','cross-system-contracts'))::bigint as required_sections,
    count(*) filter (where lower(replace(system_key::text, '-', '_')) = 'awqaf_system' and coalesce(metadata, '{}'::jsonb) @> '{"runtime_pending": true}'::jsonb)::bigint as runtime_pending_sections
  from platform.system_sections
),
root_authority as (
  select
    count(*) filter (
      where coalesce(is_active, true) = true
        and (
          coalesce(is_superuser, false) = true
          or lower(replace(coalesce(role::text,''), '-', '_')) in ('superuser','super_user','super_admin','platform_super_admin','platform_root','root','owner')
        )
    )::bigint as active_root_candidates
  from public.admin_users
),
cache_candidates as (
  select
    to_regclass('public.org_units_cache') is not null as org_units_cache_exists,
    to_regclass('public.pwf_org_units_cache') is not null as pwf_org_units_cache_exists
),
checks as (
  select 'sovereign_boundary'::text as section, 'no_waq_assets_mutation_in_this_script'::text as check_key, true as passed,
         'Read-only operations UAT only; no DDL/DML; no waqf/waqf_assets/awqaf_system mutation.'::text as note
  union all select 'registry', 'awqaf_system_registered_once_or_more', awqaf_rows > 0, 'awqaf_registry_rows=' || awqaf_rows::text from registry
  union all select 'registry', 'awqaf_system_active', awqaf_active_rows > 0, 'awqaf_active_rows=' || awqaf_active_rows::text from registry
  union all select 'registry', 'awqaf_public_route_bound', awqaf_public_route_rows > 0, 'public_route_rows=' || awqaf_public_route_rows::text from registry
  union all select 'registry', 'awqaf_admin_route_bound', awqaf_admin_route_rows > 0, 'admin_route_rows=' || awqaf_admin_route_rows::text from registry
  union all select 'registry', 'awqaf_sovereign_flag_present', awqaf_sovereign_rows > 0, 'sovereign_rows=' || awqaf_sovereign_rows::text from registry
  union all select 'registry', 'awqaf_integration_metadata_present', awqaf_metadata_rows > 0, 'metadata_rows=' || awqaf_metadata_rows::text from registry
  union all select 'sections', 'awqaf_sections_exist', awqaf_sections >= 3, 'awqaf_sections=' || awqaf_sections::text from sections
  union all select 'sections', 'required_awqaf_sections_exist', required_sections = 3, 'required_sections=' || required_sections::text || '/3' from sections
  union all select 'sections', 'runtime_pending_sections_visible', runtime_pending_sections >= 1, 'runtime_pending_sections=' || runtime_pending_sections::text from sections
  union all select 'root_authority', 'active_root_candidate_exists', active_root_candidates > 0, 'active_root_candidates=' || active_root_candidates::text from root_authority
  union all select 'cache_gate_continuity', 'org_units_cache_presence_reported', true, 'exists=' || org_units_cache_exists::text from cache_candidates
  union all select 'cache_gate_continuity', 'pwf_org_units_cache_presence_reported', true, 'exists=' || pwf_org_units_cache_exists::text from cache_candidates
)
select section, check_key, passed, note
from checks
order by
  case section
    when 'sovereign_boundary' then 1
    when 'registry' then 2
    when 'sections' then 3
    when 'root_authority' then 4
    when 'cache_gate_continuity' then 5
    else 99
  end,
  check_key;
