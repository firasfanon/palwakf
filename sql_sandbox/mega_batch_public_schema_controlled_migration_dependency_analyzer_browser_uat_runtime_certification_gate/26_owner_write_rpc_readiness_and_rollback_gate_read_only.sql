-- Public Schema Phase 3 — Owner-Write RPC Readiness + Rollback Gate
-- Date: 2026-05-23
-- Hotfix: 2026-05-23 Development 9B — core/platform schema-safe catalog probe.
-- Mode: READ ONLY catalog probe. No DDL/DML.
-- Purpose: avoid parser/runtime errors such as ERROR 42P01 relation "core" does not exist
-- by probing pg_namespace/pg_class/pg_proc instead of resolving owner surfaces as relations.

with expected_owner_surfaces as (
  select * from (values
    ('core', 'admin_users'),
    ('platform', 'platform_systems'),
    ('platform', 'user_system_roles'),
    ('platform', 'user_system_permissions'),
    ('platform', 'platform_permissions')
  ) as t(schema_name, object_name)
), owner_surface_probe as (
  select
    'owner_surface_probe' as section,
    e.schema_name || '.' || e.object_name as check_key,
    (c.oid is not null) as passed,
    case
      when ns.oid is null then 'owner schema missing or not visible in catalog; implementation must not proceed'
      when c.oid is null then 'owner target missing or not visible in catalog; implementation must not proceed'
      else 'owner target visible in catalog via schema-safe pg_namespace/pg_class probe'
    end as note
  from expected_owner_surfaces e
  left join pg_namespace ns
    on ns.nspname = e.schema_name
  left join pg_class c
    on c.relnamespace = ns.oid
   and c.relname = e.object_name
   and c.relkind in ('r','p','v','m','f')
), expected_public_wrappers as (
  select * from (values
    ('public', 'v_core_admin_users_compat_v1'),
    ('public', 'v_platform_systems_compat_v1'),
    ('public', 'v_platform_permissions_compat_v1'),
    ('public', 'v_platform_user_system_roles_compat_v1'),
    ('public', 'v_platform_user_system_permissions_compat_v1')
  ) as t(schema_name, object_name)
), wrapper_probe as (
  select
    'public_wrapper_probe' as section,
    e.schema_name || '.' || e.object_name as check_key,
    (c.oid is not null) as passed,
    case
      when ns.oid is null then 'public schema missing or not visible; runtime must not reroute'
      when c.oid is null then 'compatibility wrapper missing or not visible; runtime must not reroute'
      else 'compatibility wrapper visible in catalog via schema-safe pg_namespace/pg_class probe'
    end as note
  from expected_public_wrappers e
  left join pg_namespace ns
    on ns.nspname = e.schema_name
  left join pg_class c
    on c.relnamespace = ns.oid
   and c.relname = e.object_name
   and c.relkind in ('v','m','r','p','f')
), proposed_rpc_expected as (
  select * from (values
    ('public', 'rpc_platform_system_register_v1', 'text,jsonb'),
    ('public', 'rpc_platform_user_role_upsert_v1', 'uuid,text,text,jsonb'),
    ('public', 'rpc_platform_user_role_delete_v1', 'uuid,text,jsonb'),
    ('public', 'rpc_platform_user_permission_grant_v1', 'uuid,text,text,jsonb'),
    ('public', 'rpc_platform_user_permission_revoke_v1', 'uuid,text,text,jsonb'),
    ('public', 'rpc_core_admin_user_profile_update_v1', 'uuid,jsonb'),
    ('public', 'rpc_core_admin_user_link_v1', 'uuid,jsonb'),
    ('public', 'rpc_core_admin_user_deactivate_v1', 'uuid,jsonb')
  ) as t(schema_name, rpc_name, expected_args_compact)
), proposed_rpc_matches as (
  select
    e.schema_name,
    e.rpc_name,
    e.expected_args_compact,
    bool_or(
      regexp_replace(pg_get_function_arguments(p.oid), '\s+', '', 'g') = e.expected_args_compact
    ) filter (where p.oid is not null) as signature_found,
    count(p.oid) filter (where p.oid is not null) as same_name_count
  from proposed_rpc_expected e
  left join pg_namespace ns
    on ns.nspname = e.schema_name
  left join pg_proc p
    on p.pronamespace = ns.oid
   and p.proname = e.rpc_name
  group by e.schema_name, e.rpc_name, e.expected_args_compact
), rpc_probe as (
  select
    'proposed_rpc_probe' as section,
    schema_name || '.' || rpc_name || '(' || expected_args_compact || ')' as check_key,
    coalesce(signature_found, false) as passed,
    case
      when coalesce(signature_found, false) then 'RPC exists with expected signature; verify implementation, RLS, audit, rollback before Flutter reroute'
      when same_name_count > 0 then 'RPC name exists but expected signature was not found; runtime must not reroute'
      else 'RPC not installed; expected for this design-only batch'
    end as note
  from proposed_rpc_matches
), decision as (
  select
    'owner_write_rpc_gate_decision' as section,
    'decision' as check_key,
    false as passed,
    'DESIGN_ONLY_NOT_READY_FOR_RUNTIME_REROUTE_OR_PRODUCTION' as note
), sovereign_boundary as (
  select
    'sovereign_boundary' as section,
    'no_waqf_assets_mutation' as check_key,
    true as passed,
    'Read-only catalog probe only; no waqf_assets/waqf/awqaf_system DDL or DML.' as note
)
select * from owner_surface_probe
union all select * from wrapper_probe
union all select * from rpc_probe
union all select * from decision
union all select * from sovereign_boundary
order by section, check_key;
