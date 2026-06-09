-- Mega Batch N2.4 — Role Browser UAT Read-Only Evidence Query
-- Scope: evidence-only. Do not mutate waqf, waqf_assets, awqaf_system or platform data.
-- Run in Supabase SQL Editor after applying the N2.4 code baseline.

with expected_roles(role_key, expected_surface) as (
  values
    ('public_visitor', 'public routes / home / public service catalog / tracking privacy'),
    ('superuser', 'all platform admin routes and system launchers'),
    ('platform_admin', 'platform admin routes except superuser-only gates'),
    ('unit_admin', 'unit-scoped public/admin routes only'),
    ('media_actor', 'media/platform content routes'),
    ('service_center_actor', 'service request queue and service center routes'),
    ('governance_viewer', 'read-only governance/audit surfaces'),
    ('restricted_viewer', 'safe deny / restricted dashboard only')
), catalog_checks as (
  select 'admin_users_table' as check_key, to_regclass('public.admin_users') is not null as passed
  union all select 'user_system_roles_table', to_regclass('public.user_system_roles') is not null
  union all select 'user_system_permissions_table', to_regclass('public.user_system_permissions') is not null
  union all select 'platform_systems_table', to_regclass('public.platform_systems') is not null
  union all select 'platform_permissions_table', to_regclass('public.platform_permissions') is not null
  union all select 'no_waqf_assets_direct_check_required', true
), role_matrix as (
  select
    'role_browser_uat_matrix' as section,
    role_key,
    expected_surface,
    'manual_browser_evidence_required' as evidence_status
  from expected_roles
), readiness as (
  select
    'catalog_presence' as section,
    check_key,
    passed::text as status,
    case when passed then 'present_or_not_required' else 'missing_contract_surface' end as note
  from catalog_checks
)
select * from role_matrix
union all
select section, check_key as role_key, status as expected_surface, note as evidence_status from readiness
order by section, role_key;
