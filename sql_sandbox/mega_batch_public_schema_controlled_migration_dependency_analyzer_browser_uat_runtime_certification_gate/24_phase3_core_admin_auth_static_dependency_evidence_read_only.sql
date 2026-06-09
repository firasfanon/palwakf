-- Public Schema Phase 3 — Core/Admin/Auth Static Dependency Evidence
-- Date: 2026-05-23
-- Hotfix: 2026-05-23 Development 9A — fixes VALUES arity for owner_write_blocker rows.
-- Mode: READ ONLY evidence marker based on source scan in the baseline pack.
-- This does not inspect live DB data and does not mutate anything.

with evidence as (
  select * from (values
    ('core_linkage_direct_pairs', 'expected_count', '5', 'Five Flutter repository/profile linkage pairs still reference public.admin_users directly.'),
    ('core_linkage_direct_pairs', 'table', 'public.admin_users', 'Primary remaining core/admin linkage blocker.'),
    ('core_linkage_direct_pairs', 'auth_boundary', 'auth.users', 'Auth remains Supabase-owned and must not be migrated into core/platform/public.'),
    ('owner_write_blocker', 'public.admin_users', 'pending', 'Write paths still need core owner-write RPCs before reroute.'),
    ('owner_write_blocker', 'public.platform_systems', 'pending', 'RBAC registration write path still legacy until platform owner-write RPC exists.'),
    ('owner_write_blocker', 'public.user_system_roles', 'pending', 'RBAC role write path still legacy until platform owner-write RPC exists.'),
    ('owner_write_blocker', 'public.user_system_permissions', 'pending', 'RBAC permission write path still legacy until platform owner-write RPC exists.')
  ) as t(section, check_key, observed_value, note)
), blockers as (
  select * from (values
    ('route_console_clean_evidence', false, 'No fresh route console evidence was supplied with this batch.'),
    ('role_uat_evidence', false, 'No superuser/platform admin/unit admin/scoped user/unauthorized/anonymous screenshots or logs supplied.'),
    ('rls_evidence', false, 'No RLS leak/non-leak evidence supplied for core/admin/RBAC wrappers.'),
    ('owner_write_rpc_execution', false, 'Owner-write RPCs are design-only in this batch and are not created.'),
    ('production_approval', false, 'Production remains blocked.')
  ) as t(check_key, passed, note)
)
select 'static_evidence' as section, check_key, observed_value, note
from evidence
union all
select 'blocker_gate', check_key, passed::text, note
from blockers
order by section, check_key;
