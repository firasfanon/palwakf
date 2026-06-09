-- Platform Development 10C
-- Owner-Write RPC SQL Apply Result Intake + Anonymous Execute Grant Hotfix
-- Purpose: fix SQL02 blocker where anon had execute privilege on owner-write RPCs.
-- Scope: function privileges only. No table data mutation, no auth.users migration,
-- no destructive SQL, no waqf_assets/waqf/awqaf_system changes.

begin;

-- Ensure the implementation-installed flag remains visible after the privilege hotfix.
insert into platform.owner_write_rpc_runtime_flags(flag_key, is_enabled, metadata)
values (
  'owner_write_rpc_anon_execute_revoked_v1',
  true,
  jsonb_build_object(
    'batch', 'platform_development_10c',
    'reason', 'SQL02 detected anon execute privilege on owner-write RPCs; explicit revoke required',
    'applied_at', now()
  )
)
on conflict (flag_key) do update
set is_enabled = excluded.is_enabled,
    metadata = platform.owner_write_rpc_runtime_flags.metadata || excluded.metadata,
    updated_at = now();

do $$
begin
  execute 'revoke all on function public.rpc_core_admin_user_profile_update_v1(uuid,jsonb) from public';
  if exists (select 1 from pg_catalog.pg_roles where rolname = 'anon') then
    execute 'revoke all on function public.rpc_core_admin_user_profile_update_v1(uuid,jsonb) from anon';
  end if;
  if exists (select 1 from pg_catalog.pg_roles where rolname = 'authenticated') then
    execute 'grant execute on function public.rpc_core_admin_user_profile_update_v1(uuid,jsonb) to authenticated';
  end if;
  execute 'revoke all on function public.rpc_core_admin_user_link_v1(uuid,jsonb) from public';
  if exists (select 1 from pg_catalog.pg_roles where rolname = 'anon') then
    execute 'revoke all on function public.rpc_core_admin_user_link_v1(uuid,jsonb) from anon';
  end if;
  if exists (select 1 from pg_catalog.pg_roles where rolname = 'authenticated') then
    execute 'grant execute on function public.rpc_core_admin_user_link_v1(uuid,jsonb) to authenticated';
  end if;
  execute 'revoke all on function public.rpc_core_admin_user_deactivate_v1(uuid,jsonb) from public';
  if exists (select 1 from pg_catalog.pg_roles where rolname = 'anon') then
    execute 'revoke all on function public.rpc_core_admin_user_deactivate_v1(uuid,jsonb) from anon';
  end if;
  if exists (select 1 from pg_catalog.pg_roles where rolname = 'authenticated') then
    execute 'grant execute on function public.rpc_core_admin_user_deactivate_v1(uuid,jsonb) to authenticated';
  end if;
  execute 'revoke all on function public.rpc_platform_system_register_v1(text,jsonb) from public';
  if exists (select 1 from pg_catalog.pg_roles where rolname = 'anon') then
    execute 'revoke all on function public.rpc_platform_system_register_v1(text,jsonb) from anon';
  end if;
  if exists (select 1 from pg_catalog.pg_roles where rolname = 'authenticated') then
    execute 'grant execute on function public.rpc_platform_system_register_v1(text,jsonb) to authenticated';
  end if;
  execute 'revoke all on function public.rpc_platform_user_role_upsert_v1(uuid,text,text,jsonb) from public';
  if exists (select 1 from pg_catalog.pg_roles where rolname = 'anon') then
    execute 'revoke all on function public.rpc_platform_user_role_upsert_v1(uuid,text,text,jsonb) from anon';
  end if;
  if exists (select 1 from pg_catalog.pg_roles where rolname = 'authenticated') then
    execute 'grant execute on function public.rpc_platform_user_role_upsert_v1(uuid,text,text,jsonb) to authenticated';
  end if;
  execute 'revoke all on function public.rpc_platform_user_role_delete_v1(uuid,text,jsonb) from public';
  if exists (select 1 from pg_catalog.pg_roles where rolname = 'anon') then
    execute 'revoke all on function public.rpc_platform_user_role_delete_v1(uuid,text,jsonb) from anon';
  end if;
  if exists (select 1 from pg_catalog.pg_roles where rolname = 'authenticated') then
    execute 'grant execute on function public.rpc_platform_user_role_delete_v1(uuid,text,jsonb) to authenticated';
  end if;
  execute 'revoke all on function public.rpc_platform_user_permission_grant_v1(uuid,text,text,jsonb) from public';
  if exists (select 1 from pg_catalog.pg_roles where rolname = 'anon') then
    execute 'revoke all on function public.rpc_platform_user_permission_grant_v1(uuid,text,text,jsonb) from anon';
  end if;
  if exists (select 1 from pg_catalog.pg_roles where rolname = 'authenticated') then
    execute 'grant execute on function public.rpc_platform_user_permission_grant_v1(uuid,text,text,jsonb) to authenticated';
  end if;
  execute 'revoke all on function public.rpc_platform_user_permission_revoke_v1(uuid,text,text,jsonb) from public';
  if exists (select 1 from pg_catalog.pg_roles where rolname = 'anon') then
    execute 'revoke all on function public.rpc_platform_user_permission_revoke_v1(uuid,text,text,jsonb) from anon';
  end if;
  if exists (select 1 from pg_catalog.pg_roles where rolname = 'authenticated') then
    execute 'grant execute on function public.rpc_platform_user_permission_revoke_v1(uuid,text,text,jsonb) to authenticated';
  end if;
end $$;

notify pgrst, 'reload schema';

commit;
