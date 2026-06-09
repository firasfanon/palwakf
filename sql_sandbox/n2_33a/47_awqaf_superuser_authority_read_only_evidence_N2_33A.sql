-- PalWakf Platform — Mega Batch N2.33A
-- 47_awqaf_superuser_authority_read_only_evidence_N2_33A.sql
-- Purpose: Read-only evidence for the Awqaf System superuser/root-authority gate.
-- Safety: SELECT-only. No DDL/DML; no waqf/waqf_assets/awqaf_system mutation.
-- Note: This checks platform identity/registry signals. The Flutter route/access fix still must be tested in browser.

with admin_shape as (
  select
    exists (select 1 from information_schema.tables where table_schema='public' and table_name='admin_users') as admin_users_exists,
    exists (select 1 from information_schema.columns where table_schema='public' and table_name='admin_users' and column_name='is_superuser') as is_superuser_column_exists,
    exists (select 1 from information_schema.columns where table_schema='public' and table_name='admin_users' and column_name='role') as role_column_exists,
    exists (select 1 from information_schema.columns where table_schema='public' and table_name='admin_users' and column_name='is_active') as is_active_column_exists
),
superuser_count as (
  select
    count(*) filter (
      where coalesce(is_active, true) = true
        and (coalesce(is_superuser, false) = true or lower(coalesce(role::text,'')) in ('superuser','super_admin'))
    )::bigint as active_superusers
  from public.admin_users
),
registry_shape as (
  select
    exists (select 1 from information_schema.tables where table_schema='platform' and table_name='system_registry') as system_registry_exists,
    exists (select 1 from information_schema.tables where table_schema='platform' and table_name='system_sections') as system_sections_exists
),
awqaf_registry as (
  select
    count(*) filter (where system_key = 'awqaf_system')::bigint as awqaf_system_registry_rows
  from platform.system_registry
),
checks as (
  select 'sovereign_boundary'::text as section,
         'no_waq_assets_mutation_in_this_script'::text as check_key,
         true as passed,
         'Read-only access evidence only; no DDL/DML; no waqf/waqf_assets/awqaf_system mutation.'::text as note
  union all
  select 'identity_shape', 'admin_users_exists', admin_users_exists,
         'public.admin_users must remain the platform identity source.'
  from admin_shape
  union all
  select 'identity_shape', 'admin_users_superuser_column_exists', is_superuser_column_exists,
         'AccessRepository reads admin_users.is_superuser for root authority.'
  from admin_shape
  union all
  select 'identity_shape', 'admin_users_role_column_exists', role_column_exists,
         'AccessRepository also treats role=super_admin as root authority fallback.'
  from admin_shape
  union all
  select 'identity_data', 'active_superuser_exists', active_superusers > 0,
         'active_superusers=' || active_superusers::text
  from superuser_count
  union all
  select 'dynamic_registry_shape', 'system_registry_exists', system_registry_exists,
         'platform.system_registry is required for first-class system visibility.'
  from registry_shape
  union all
  select 'dynamic_registry_shape', 'system_sections_exists', system_sections_exists,
         'platform.system_sections is required for section visibility.'
  from registry_shape
  union all
  select 'awqaf_registry', 'awqaf_system_registered', awqaf_system_registry_rows > 0,
         'awqaf_system_registry_rows=' || awqaf_system_registry_rows::text
  from awqaf_registry
  union all
  select 'flutter_contract', 'superuser_bypass_required', true,
         'If active_superuser_exists=true, Flutter Awqaf gates must allow profile.isSuperuser before scoped role checks, except explicit maintenance/disabled lock.'
)
select section, check_key, passed, note
from checks
order by
  case section
    when 'sovereign_boundary' then 1
    when 'identity_shape' then 2
    when 'identity_data' then 3
    when 'dynamic_registry_shape' then 4
    when 'awqaf_registry' then 5
    when 'flutter_contract' then 6
    else 99
  end,
  check_key;
