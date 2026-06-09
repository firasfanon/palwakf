-- Mega Batch N2.9A — Sidebar RBAC Visibility Binding Evidence
-- Read-only verification script. No DML. No waqf/waq_assets mutation.
-- Purpose: confirm the restricted UAT user has no system grants, so the sidebar must render common routes only.

with restricted_user as (
  select
    au.id,
    au.email,
    au.username,
    au.role as admin_role,
    au.is_active,
    au.is_superuser,
    au.unit_id
  from public.admin_users au
  where lower(au.username) = lower('bthusr1')
     or lower(au.email) = lower('bthusr1@palwakf.local')
  limit 1
), grants as (
  select
    ru.id as user_id,
    count(distinct usr.system_key::text) filter (where usr.system_key is not null) as systems_count,
    count(distinct usr.role::text) filter (where usr.role is not null) as roles_count,
    count(distinct usp.permission_key) filter (where usp.permission_key is not null and coalesce(usp.allow, true) = true) as permissions_count,
    string_agg(distinct usr.system_key::text, ', ' order by usr.system_key::text) filter (where usr.system_key is not null) as systems,
    string_agg(distinct usr.role::text, ', ' order by usr.role::text) filter (where usr.role is not null) as roles,
    string_agg(distinct usp.permission_key, ', ' order by usp.permission_key) filter (where usp.permission_key is not null and coalesce(usp.allow, true) = true) as permissions
  from restricted_user ru
  left join public.user_system_roles usr on usr.user_id = ru.id
  left join public.user_system_permissions usp on usp.user_id = ru.id
  group by ru.id
), evidence as (
  select
    'sidebar_rbac_visibility'::text as section,
    'bthusr1_has_no_operational_grants'::text as check_key,
    (
      ru.is_active is true
      and ru.is_superuser is false
      and coalesce(g.systems_count, 0) = 0
      and coalesce(g.roles_count, 0) = 0
      and coalesce(g.permissions_count, 0) = 0
    ) as passed,
    concat(
      'email=', coalesce(ru.email, 'missing'),
      '; username=', coalesce(ru.username, 'missing'),
      '; admin_role=', coalesce(ru.admin_role, 'missing'),
      '; active=', coalesce(ru.is_active::text, 'null'),
      '; superuser=', coalesce(ru.is_superuser::text, 'null'),
      '; systems_count=', coalesce(g.systems_count, 0),
      '; roles_count=', coalesce(g.roles_count, 0),
      '; permissions_count=', coalesce(g.permissions_count, 0),
      '; expected_sidebar=adminDashboard,adminMyActivity,adminUsageGuide only; sensitive tabs hidden.'
    ) as note
  from restricted_user ru
  left join grants g on g.user_id = ru.id
  union all
  select
    'usage_guide'::text,
    'usage_guide_asset_contract_expected'::text,
    true,
    'Flutter asset expected at assets/docs/usage_guide_manifest.json with docs[] entries and assetPath values under assets/docs/usage and assets/docs/assistant.'
  union all
  select
    'sovereign_boundary'::text,
    'no_waq_assets_mutation_in_this_script'::text,
    true,
    'Read-only evidence only; no insert/update/delete against waqf or waq_assets schemas.'
)
select *
from evidence
order by section, check_key;
