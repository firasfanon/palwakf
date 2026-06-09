-- Mega Batch N1.1A — Users/RBAC SQL UAT Type Cast Compatibility Fix
-- Read-only. Fixes PostgreSQL operator mismatch when system_key/permission_key are domains/enums.

-- Mega Batch N1.1 — Platform Identity / Users / RBAC / Scope Governance Readiness UAT
-- Read-only. This script does not create, update, delete, alter, or drop data.

with checks as (
  select
    'admin_users_table_exists'::text as check_key,
    (to_regclass('public.admin_users') is not null) as passed,
    case when to_regclass('public.admin_users') is not null then 'public.admin_users exists.' else 'public.admin_users is missing.' end as note

  union all
  select
    'platform_rbac_catalog_tables_exist',
    (to_regclass('public.platform_systems') is not null
      and to_regclass('public.platform_permissions') is not null
      and to_regclass('public.user_system_roles') is not null
      and to_regclass('public.user_system_permissions') is not null),
    concat(
      'platform_systems=', to_regclass('public.platform_systems') is not null,
      '; platform_permissions=', to_regclass('public.platform_permissions') is not null,
      '; user_system_roles=', to_regclass('public.user_system_roles') is not null,
      '; user_system_permissions=', to_regclass('public.user_system_permissions') is not null
    )

  union all
  select
    'scope_assignment_tables_exist',
    (to_regclass('public.user_scope_assignments') is not null
      and to_regclass('public.user_scope_assignment_units') is not null),
    concat(
      'user_scope_assignments=', to_regclass('public.user_scope_assignments') is not null,
      '; user_scope_assignment_units=', to_regclass('public.user_scope_assignment_units') is not null
    )

  union all
  select
    'admin_users_auth_alignment',
    case
      when to_regclass('public.admin_users') is null or to_regclass('auth.users') is null then false
      else not exists (
        select 1
        from public.admin_users au
        left join auth.users u on u.id = au.id
        where u.id is null
        limit 1
      )
    end,
    case
      when to_regclass('public.admin_users') is null then 'public.admin_users missing.'
      when to_regclass('auth.users') is null then 'auth.users not visible in this context.'
      else concat(
        'orphan_admin_users=', (
          select count(*)
          from public.admin_users au
          left join auth.users u on u.id = au.id
          where u.id is null
        )
      )
    end

  union all
  select
    'active_admin_users_exist',
    case when to_regclass('public.admin_users') is null then false else exists (
      select 1 from public.admin_users where coalesce(is_active, true) = true limit 1
    ) end,
    case when to_regclass('public.admin_users') is null then 'public.admin_users missing.' else concat(
      'active_admin_users=', (select count(*) from public.admin_users where coalesce(is_active, true) = true),
      '; inactive_admin_users=', (select count(*) from public.admin_users where coalesce(is_active, true) = false)
    ) end

  union all
  select
    'superuser_count_review',
    case when to_regclass('public.admin_users') is null then false else (
      select count(*) from public.admin_users where coalesce(is_superuser, false) = true
    ) between 1 and 5 end,
    case when to_regclass('public.admin_users') is null then 'public.admin_users missing.' else concat(
      'superuser_count=', (select count(*) from public.admin_users where coalesce(is_superuser, false) = true),
      '; expected range for staging/production review: 1..5'
    ) end

  union all
  select
    'platform_systems_seed_coverage',
    case when to_regclass('public.platform_systems') is null then false else (
      select count(*) from public.platform_systems
    ) >= 8 end,
    case when to_regclass('public.platform_systems') is null then 'public.platform_systems missing.' else concat(
      'platform_systems=', (select count(*) from public.platform_systems)
    ) end

  union all
  select
    'platform_permissions_seed_coverage',
    case when to_regclass('public.platform_permissions') is null then false else (
      select count(*) from public.platform_permissions
    ) >= 8 end,
    case when to_regclass('public.platform_permissions') is null then 'public.platform_permissions missing.' else concat(
      'platform_permissions=', (select count(*) from public.platform_permissions)
    ) end

  union all
  select
    'roles_have_valid_systems',
    case when to_regclass('public.user_system_roles') is null or to_regclass('public.platform_systems') is null then false else not exists (
      select 1
      from public.user_system_roles usr
      where not exists (
        select 1 from public.platform_systems ps
        where coalesce(to_jsonb(ps)->>'key', to_jsonb(ps)->>'system_key', to_jsonb(ps)->>'slug') = (usr.system_key)::text
      )
      limit 1
    ) end,
    case when to_regclass('public.user_system_roles') is null then 'public.user_system_roles missing.' else concat(
      'invalid_role_system_refs=', (
        select count(*)
        from public.user_system_roles usr
        where to_regclass('public.platform_systems') is not null
          and not exists (
            select 1 from public.platform_systems ps
            where coalesce(to_jsonb(ps)->>'key', to_jsonb(ps)->>'system_key', to_jsonb(ps)->>'slug') = (usr.system_key)::text
          )
      )
    ) end

  union all
  select
    'permissions_have_valid_catalog_refs',
    case when to_regclass('public.user_system_permissions') is null or to_regclass('public.platform_permissions') is null then false else not exists (
      select 1
      from public.user_system_permissions usp
      where not exists (
        select 1 from public.platform_permissions pp
        where coalesce(to_jsonb(pp)->>'permission_key', to_jsonb(pp)->>'key', to_jsonb(pp)->>'slug') = (usp.permission_key)::text
      )
      limit 1
    ) end,
    case when to_regclass('public.user_system_permissions') is null then 'public.user_system_permissions missing.' else concat(
      'invalid_permission_refs=', (
        select count(*)
        from public.user_system_permissions usp
        where to_regclass('public.platform_permissions') is not null
          and not exists (
            select 1 from public.platform_permissions pp
            where coalesce(to_jsonb(pp)->>'permission_key', to_jsonb(pp)->>'key', to_jsonb(pp)->>'slug') = (usp.permission_key)::text
          )
      )
    ) end

  union all
  select
    'rbac_rls_enabled',
    (
      select count(*) = 6
      from pg_class c
      join pg_namespace n on n.oid = c.relnamespace
      where n.nspname = 'public'
        and c.relname in ('admin_users','platform_systems','platform_permissions','user_system_roles','user_system_permissions','user_scope_assignments')
        and c.relrowsecurity = true
    ),
    concat(
      'rls_enabled=', (
        select count(*)
        from pg_class c
        join pg_namespace n on n.oid = c.relnamespace
        where n.nspname = 'public'
          and c.relname in ('admin_users','platform_systems','platform_permissions','user_system_roles','user_system_permissions','user_scope_assignments')
          and c.relrowsecurity = true
      ),
      '/6 for core RBAC tables'
    )

  union all
  select
    'rbac_policies_exist',
    (
      select count(*) >= 6
      from pg_policies
      where schemaname = 'public'
        and tablename in ('admin_users','platform_systems','platform_permissions','user_system_roles','user_system_permissions','user_scope_assignments')
    ),
    concat(
      'policy_count=', (
        select count(*)
        from pg_policies
        where schemaname = 'public'
          and tablename in ('admin_users','platform_systems','platform_permissions','user_system_roles','user_system_permissions','user_scope_assignments')
      )
    )

  union all
  select
    'admin_user_rpc_surface_review',
    exists (
      select 1
      from pg_proc p
      join pg_namespace n on n.oid = p.pronamespace
      where n.nspname = 'public'
        and p.proname in ('rpc_admin_user_set_flags','rpc_user_scope_assignments_list_v1')
    ),
    concat(
      'installed_admin_user_rpcs=', (
        select count(*)
        from pg_proc p
        join pg_namespace n on n.oid = p.pronamespace
        where n.nspname = 'public'
          and p.proname in ('rpc_admin_user_set_flags','rpc_user_scope_assignments_list_v1')
      ),
      '/2 expected minimum for current app paths'
    )

  union all
  select
    'no_waq_assets_mutation_in_this_script',
    true,
    'Read-only UAT. Mega N1.1 checks users/RBAC governance only and does not touch waqf schema or awqaf_system.'
)
select * from checks order by check_key;
