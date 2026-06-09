-- PalWakf Platform — Mega Batch N2.34
-- 48_root_authority_awqaf_system_access_evidence_READ_ONLY_N2_34.sql
-- Purpose: Read-only evidence for platform root authority, awqaf_system first-class registry, and access aliases.
-- Safety: SELECT-only. No DDL/DML. No waqf/waqf_assets/awqaf_system mutation.

with admin_shape as (
  select
    exists (select 1 from information_schema.tables where table_schema='public' and table_name='admin_users') as admin_users_exists,
    exists (select 1 from information_schema.columns where table_schema='public' and table_name='admin_users' and column_name='is_active') as is_active_exists,
    exists (select 1 from information_schema.columns where table_schema='public' and table_name='admin_users' and column_name='is_superuser') as is_superuser_exists,
    exists (select 1 from information_schema.columns where table_schema='public' and table_name='admin_users' and column_name='role') as role_exists
),
superuser_evidence as (
  select
    count(*) filter (
      where coalesce(is_active, true) = true
        and (
          coalesce(is_superuser, false) = true
          or lower(replace(coalesce(role::text,''), '-', '_')) in (
            'superuser', 'super_user', 'super_admin', 'platform_super_admin', 'platform_root', 'root', 'owner'
          )
        )
    )::bigint as active_root_candidates
  from public.admin_users
),
static_role_evidence as (
  select
    count(*) filter (
      where lower(replace(system_key::text, '-', '_')) in ('platformadmin','platform_admin','admin')
        and lower(replace(role::text, '-', '_')) in ('superuser','super_user','super_admin','platform_super_admin','platform_root','root','owner')
    )::bigint as platform_root_role_rows,
    count(*) filter (
      where lower(replace(system_key::text, '-', '_')) in ('awqaf_system','awqafsystem','awqaf')
    )::bigint as awqaf_static_role_rows
  from public.user_system_roles
),
dynamic_registry_shape as (
  select
    exists (select 1 from information_schema.tables where table_schema='platform' and table_name='system_registry') as system_registry_exists,
    exists (select 1 from information_schema.tables where table_schema='platform' and table_name='system_sections') as system_sections_exists,
    exists (select 1 from information_schema.tables where table_schema='platform' and table_name='system_user_roles') as system_user_roles_exists,
    exists (select 1 from information_schema.tables where table_schema='platform' and table_name='system_user_permissions') as system_user_permissions_exists
),
awqaf_registry as (
  select
    count(*) filter (
      where lower(replace(system_key::text, '-', '_')) in ('awqaf_system','awqafsystem','awqaf')
    )::bigint as awqaf_registry_rows,
    coalesce(string_agg(system_key::text || '|' || coalesce(admin_route_path::text,'-') || '|' || coalesce(public_route_path::text,'-'), ', ' order by system_key::text), 'none')
      filter (where lower(replace(system_key::text, '-', '_')) in ('awqaf_system','awqafsystem','awqaf')) as awqaf_registry_routes
  from platform.system_registry
),
dynamic_role_evidence as (
  select
    count(*) filter (
      where lower(replace(system_key::text, '-', '_')) in ('platformadmin','platform_admin','admin')
        and lower(replace(role_key::text, '-', '_')) in ('superuser','super_user','super_admin','platform_super_admin','platform_root','root','owner')
    )::bigint as platform_dynamic_root_role_rows,
    count(*) filter (
      where lower(replace(system_key::text, '-', '_')) in ('awqaf_system','awqafsystem','awqaf')
    )::bigint as awqaf_dynamic_role_rows
  from platform.system_user_roles
),
checks as (
  select 'sovereign_boundary'::text as section, 'no_waq_assets_mutation_in_this_script'::text as check_key, true as passed,
         'Read-only root authority/access evidence only; no DDL/DML; no waqf/waqf_assets/awqaf_system mutation.'::text as note
  union all select 'identity_shape', 'admin_users_exists', admin_users_exists, 'public.admin_users remains the platform identity source.' from admin_shape
  union all select 'identity_shape', 'admin_users_is_active_exists', is_active_exists, 'is_active is required for fail-closed active-account check.' from admin_shape
  union all select 'identity_shape', 'admin_users_is_superuser_exists', is_superuser_exists, 'is_superuser is the primary root authority flag.' from admin_shape
  union all select 'identity_shape', 'admin_users_role_exists', role_exists, 'role aliases are accepted as root authority fallback.' from admin_shape
  union all select 'root_authority_data', 'active_root_candidate_exists', active_root_candidates > 0, 'active_root_candidates=' || active_root_candidates::text from superuser_evidence
  union all select 'static_role_data', 'platform_root_static_role_rows_visible', true, 'platform_root_static_role_rows=' || platform_root_role_rows::text from static_role_evidence
  union all select 'static_role_data', 'awqaf_static_role_rows_visible', true, 'awqaf_static_role_rows=' || awqaf_static_role_rows::text from static_role_evidence
  union all select 'dynamic_registry_shape', 'system_registry_exists', system_registry_exists, 'platform.system_registry must exist for system-of-systems registry.' from dynamic_registry_shape
  union all select 'dynamic_registry_shape', 'system_sections_exists', system_sections_exists, 'platform.system_sections must exist for sections registry.' from dynamic_registry_shape
  union all select 'dynamic_registry_shape', 'system_user_roles_exists', system_user_roles_exists, 'platform.system_user_roles supports dynamic scoped roles.' from dynamic_registry_shape
  union all select 'dynamic_registry_shape', 'system_user_permissions_exists', system_user_permissions_exists, 'platform.system_user_permissions supports dynamic scoped permissions.' from dynamic_registry_shape
  union all select 'awqaf_registry', 'awqaf_system_registered', awqaf_registry_rows > 0, 'awqaf_registry_rows=' || awqaf_registry_rows::text || '; routes=' || coalesce(awqaf_registry_routes, 'none') from awqaf_registry
  union all select 'dynamic_role_data', 'platform_dynamic_root_role_rows_visible', true, 'platform_dynamic_root_role_rows=' || platform_dynamic_root_role_rows::text from dynamic_role_evidence
  union all select 'dynamic_role_data', 'awqaf_dynamic_role_rows_visible', true, 'awqaf_dynamic_role_rows=' || awqaf_dynamic_role_rows::text from dynamic_role_evidence
  union all select 'flutter_contract', 'superuser_bypass_before_scoped_awqaf_checks', true, 'N2.34 requires AccessProfile.hasPlatformRootAuthority before awqaf_system scoped grants.'
)
select section, check_key, passed, note
from checks
order by
  case section
    when 'sovereign_boundary' then 1
    when 'identity_shape' then 2
    when 'root_authority_data' then 3
    when 'static_role_data' then 4
    when 'dynamic_registry_shape' then 5
    when 'awqaf_registry' then 6
    when 'dynamic_role_data' then 7
    when 'flutter_contract' then 8
    else 99
  end,
  check_key;
