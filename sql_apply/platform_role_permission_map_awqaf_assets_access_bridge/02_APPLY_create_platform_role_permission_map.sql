begin;

create schema if not exists platform_access;

create table if not exists platform_access.platform_role_permission_map (
  id uuid primary key default gen_random_uuid(),
  platform_role text not null,
  system_key text not null,
  permission_code text not null,
  permission_group text,
  scope_policy text not null default 'inherit_assignment_scope',
  is_active boolean not null default true,
  valid_from timestamptz not null default now(),
  valid_until timestamptz,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint platform_role_permission_map_role_check
    check (platform_role in ('super_admin','admin','manager','employee','viewer')),
  constraint platform_role_permission_map_scope_policy_check
    check (scope_policy in ('global','inherit_assignment_scope','deny')),
  constraint platform_role_permission_map_unique_contract
    unique (platform_role, system_key, permission_code, scope_policy)
);

comment on table platform_access.platform_role_permission_map is
  'Canonical bridge between global platform roles and system permission codes. It does not grant data access unless consumed by system RBAC logic.';

commit;

select
  'platform_role_permission_map_table_created' as section,
  to_regclass('platform_access.platform_role_permission_map') is not null as table_present,
  false as production_approved;
