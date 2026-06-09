-- Platform Database Dependency Wave A — Access Helpers Actual Remediation Pack
-- SQL 37: guarded replacement bodies, DRAFT / FAIL-CLOSED.
--
-- DO NOT RUN AS-IS.
-- This file contains actual CREATE OR REPLACE FUNCTION bodies for the limited
-- Wave A access-helper scope only. It intentionally fails unless the approval
-- token is replaced after exact body approval + backup/restore point + RLS
-- negative UAT + browser/network clean evidence + governance authorization.
--
-- Scope:
--   assistant._find_admin_users_column(text[])
--   assistant.is_authenticated_admin_user()
--   assistant.can_manage_assistant()
--   core.pwf_is_admin_user()
--   core.fn_can_edit_unit(uuid)
--   tasks._can_manage_audit_tasks()
--
-- Excluded:
--   operational import loaders, waqf/awqaf/gis mutation, public table renames,
--   archive/delete/drop, GRANT changes, auth.users migration, service_role.

begin;

do $$
declare
  v_authorization_token text := 'REPLACE_WITH_PWF_WAVE_A_ACCESS_HELPERS_APPROVAL_TOKEN';
begin
  if v_authorization_token <> 'PWF-WAVE-A-ACCESS-HELPERS-ACTUAL-REMEDIATION-2026-05-26-APPROVED' then
    raise exception 'Wave A access-helper replacement is blocked: replace approval token only after exact body approval, backup/restore point, RLS negative UAT, and browser/network clean evidence.';
  end if;
end $$;

do $$
begin
  if to_regclass('public.v_core_admin_users_compat_v1') is null then
    raise exception 'Missing required compatibility surface: public.v_core_admin_users_compat_v1';
  end if;
end $$;

create or replace function assistant._find_admin_users_column(candidates text[])
returns text
language sql
stable
as $function$
  with wanted as (
    select candidate, ordinality
    from unnest(candidates) with ordinality as t(candidate, ordinality)
  )
  select c.column_name
  from information_schema.columns c
  join wanted w on w.candidate = c.column_name
  where c.table_schema = 'public'
    and c.table_name = 'v_core_admin_users_compat_v1'
  order by w.ordinality
  limit 1
$function$;

create or replace function assistant.is_authenticated_admin_user()
returns boolean
language plpgsql
stable
security definer
set search_path to 'assistant', 'public', 'auth', 'pg_catalog'
as $function$
declare
  ident_col text;
  active_col text;
  active_sql text := '';
  q text;
  result boolean := false;
begin
  if auth.uid() is null then
    return false;
  end if;

  if to_regclass('public.v_core_admin_users_compat_v1') is null then
    return false;
  end if;

  ident_col := assistant._find_admin_users_column(array['auth_user_id', 'user_id', 'open_id', 'id']);
  active_col := assistant._find_admin_users_column(array['is_active', 'active', 'enabled']);

  if ident_col is null then
    return false;
  end if;

  if active_col is not null then
    active_sql := format(
      ' and (u.%1$I is null or lower(u.%1$I::text) in (''1'',''true'',''t'',''yes'',''y'',''on'',''active'',''enabled''))',
      active_col
    );
  end if;

  q := format(
    'select exists (select 1 from public.v_core_admin_users_compat_v1 u where u.%1$I::text = auth.uid()::text %2$s)',
    ident_col,
    active_sql
  );

  execute q into result;
  return coalesce(result, false);
end;
$function$;

create or replace function assistant.can_manage_assistant()
returns boolean
language plpgsql
stable
security definer
set search_path to 'assistant', 'public', 'auth', 'pg_catalog'
as $function$
declare
  ident_col text;
  active_col text;
  role_col text;
  platform_role_col text;
  super_col text;
  perm_col text;
  active_sql text := '';
  predicates text[] := array[]::text[];
  q text;
  result boolean := false;
begin
  if auth.uid() is null then
    return false;
  end if;

  if to_regclass('public.v_core_admin_users_compat_v1') is null then
    return false;
  end if;

  ident_col := assistant._find_admin_users_column(array['auth_user_id', 'user_id', 'open_id', 'id']);
  active_col := assistant._find_admin_users_column(array['is_active', 'active', 'enabled']);
  role_col := assistant._find_admin_users_column(array['role']);
  platform_role_col := assistant._find_admin_users_column(array['platform_role']);
  super_col := assistant._find_admin_users_column(array['is_superuser', 'superuser']);
  perm_col := assistant._find_admin_users_column(array['permission_keys', 'permissions_json', 'permissions', 'permissions_text']);

  if ident_col is null then
    return false;
  end if;

  if active_col is not null then
    active_sql := format(
      ' and (u.%1$I is null or lower(u.%1$I::text) in (''1'',''true'',''t'',''yes'',''y'',''on'',''active'',''enabled''))',
      active_col
    );
  end if;

  if super_col is not null then
    predicates := predicates || format('lower(coalesce(u.%1$I::text, '''')) in (''1'',''true'',''t'',''yes'',''y'',''on'')', super_col);
  end if;
  if role_col is not null then
    predicates := predicates || format('lower(coalesce(u.%1$I::text, '''')) in (''admin'',''superuser'',''super_user'',''owner'',''platform_admin'',''platformadmin'')', role_col);
  end if;
  if platform_role_col is not null then
    predicates := predicates || format('lower(coalesce(u.%1$I::text, '''')) in (''platformadmin'',''platform_admin'',''superuser'',''super_user'')', platform_role_col);
  end if;
  if perm_col is not null then
    predicates := predicates || format(
      '(u.%1$I::text ilike ''%%manageUsers%%'' or u.%1$I::text ilike ''%%manage_users%%'' or u.%1$I::text ilike ''%%manageKnowledge%%'' or u.%1$I::text ilike ''%%manage_knowledge%%'' or u.%1$I::text ilike ''%%manageAssistant%%'' or u.%1$I::text ilike ''%%manage_assistant%%'')',
      perm_col
    );
  end if;

  if array_length(predicates, 1) is null then
    return false;
  end if;

  q := format(
    'select exists (select 1 from public.v_core_admin_users_compat_v1 u where u.%1$I::text = auth.uid()::text %2$s and (%3$s))',
    ident_col,
    active_sql,
    array_to_string(predicates, ' or ')
  );

  execute q into result;
  return coalesce(result, false);
end;
$function$;

create or replace function core.pwf_is_admin_user()
returns boolean
language plpgsql
stable
security definer
set search_path to 'core', 'public', 'auth', 'pg_catalog'
as $function$
declare
  ident_col text;
  active_col text;
  active_sql text := '';
  q text;
  result boolean := false;
begin
  if auth.uid() is null then
    return false;
  end if;

  if to_regclass('public.v_core_admin_users_compat_v1') is null then
    return false;
  end if;

  select c.column_name into ident_col
  from information_schema.columns c
  where c.table_schema = 'public'
    and c.table_name = 'v_core_admin_users_compat_v1'
    and c.column_name in ('auth_user_id', 'user_id', 'open_id', 'id')
  order by array_position(array['auth_user_id', 'user_id', 'open_id', 'id'], c.column_name)
  limit 1;

  select c.column_name into active_col
  from information_schema.columns c
  where c.table_schema = 'public'
    and c.table_name = 'v_core_admin_users_compat_v1'
    and c.column_name in ('is_active', 'active', 'enabled')
  order by array_position(array['is_active', 'active', 'enabled'], c.column_name)
  limit 1;

  if ident_col is null then
    return false;
  end if;

  if active_col is not null then
    active_sql := format(' and (u.%1$I is null or lower(u.%1$I::text) in (''1'',''true'',''t'',''yes'',''y'',''on'',''active'',''enabled''))', active_col);
  end if;

  q := format('select exists (select 1 from public.v_core_admin_users_compat_v1 u where u.%1$I::text = auth.uid()::text %2$s)', ident_col, active_sql);
  execute q into result;
  return coalesce(result, false);
end;
$function$;

create or replace function core.fn_can_edit_unit(p_unit_id uuid)
returns boolean
language plpgsql
stable
security definer
set search_path to 'core', 'public', 'auth', 'pg_catalog'
as $function$
declare
  ident_col text;
  active_col text;
  role_col text;
  platform_role_col text;
  super_col text;
  unit_col text;
  active_sql text := '';
  predicates text[] := array[]::text[];
  q text;
  result boolean := false;
  permission_has_allow boolean := false;
begin
  if auth.uid() is null then
    return false;
  end if;

  if to_regclass('public.v_core_admin_users_compat_v1') is not null then
    select c.column_name into ident_col from information_schema.columns c where c.table_schema = 'public' and c.table_name = 'v_core_admin_users_compat_v1' and c.column_name in ('auth_user_id', 'user_id', 'open_id', 'id') order by array_position(array['auth_user_id', 'user_id', 'open_id', 'id'], c.column_name) limit 1;
    select c.column_name into active_col from information_schema.columns c where c.table_schema = 'public' and c.table_name = 'v_core_admin_users_compat_v1' and c.column_name in ('is_active', 'active', 'enabled') order by array_position(array['is_active', 'active', 'enabled'], c.column_name) limit 1;
    select c.column_name into role_col from information_schema.columns c where c.table_schema = 'public' and c.table_name = 'v_core_admin_users_compat_v1' and c.column_name in ('role') limit 1;
    select c.column_name into platform_role_col from information_schema.columns c where c.table_schema = 'public' and c.table_name = 'v_core_admin_users_compat_v1' and c.column_name in ('platform_role') limit 1;
    select c.column_name into super_col from information_schema.columns c where c.table_schema = 'public' and c.table_name = 'v_core_admin_users_compat_v1' and c.column_name in ('is_superuser', 'superuser') order by array_position(array['is_superuser', 'superuser'], c.column_name) limit 1;
    select c.column_name into unit_col from information_schema.columns c where c.table_schema = 'public' and c.table_name = 'v_core_admin_users_compat_v1' and c.column_name in ('unit_id', 'org_unit_id') order by array_position(array['unit_id', 'org_unit_id'], c.column_name) limit 1;

    if ident_col is not null then
      if active_col is not null then active_sql := format(' and (u.%1$I is null or lower(u.%1$I::text) in (''1'',''true'',''t'',''yes'',''y'',''on'',''active'',''enabled''))', active_col); end if;
      if super_col is not null then predicates := predicates || format('lower(coalesce(u.%1$I::text, '''')) in (''1'',''true'',''t'',''yes'',''y'',''on'')', super_col); end if;
      if role_col is not null then predicates := predicates || format('lower(coalesce(u.%1$I::text, '''')) in (''super_admin'',''superuser'',''platformadmin'',''platform_admin'',''admin'')', role_col); end if;
      if platform_role_col is not null then predicates := predicates || format('lower(coalesce(u.%1$I::text, '''')) in (''platformadmin'',''platform_admin'',''superuser'',''super_user'')', platform_role_col); end if;
      if unit_col is not null then predicates := predicates || format('(p_unit_id is not null and u.%1$I::text = p_unit_id::text)', unit_col); end if;

      if array_length(predicates, 1) is not null then
        q := format('select exists (select 1 from public.v_core_admin_users_compat_v1 u where u.%1$I::text = auth.uid()::text %2$s and (%3$s))', ident_col, active_sql, array_to_string(predicates, ' or '));
        execute q into result;
        if coalesce(result, false) then return true; end if;
      end if;
    end if;
  end if;

  if to_regclass('public.v_platform_user_system_permissions_compat_v1') is not null then
    select exists (select 1 from information_schema.columns where table_schema = 'public' and table_name = 'v_platform_user_system_permissions_compat_v1' and column_name = 'allow') into permission_has_allow;
    q := 'select exists (select 1 from public.v_platform_user_system_permissions_compat_v1 p where p.user_id::text = auth.uid()::text and p.system_key::text in (''platformAdmin'', ''core'', ''admin'') and p.permission_key::text in (''manageUsers'', ''manage_users'', ''manageSite'', ''manage_site'', ''admin'')';
    if permission_has_allow then q := q || ' and coalesce(p.allow, true) = true'; end if;
    q := q || ')';
    execute q into result;
    if coalesce(result, false) then return true; end if;
  end if;

  if to_regclass('public.v_platform_user_system_roles_compat_v1') is not null then
    execute $sql$ select exists(select 1 from public.v_platform_user_system_roles_compat_v1 r where r.user_id::text = auth.uid()::text and r.system_key::text in ('platformAdmin', 'core', 'admin') and r.role::text in ('admin', 'superuser', 'super_admin', 'platform_admin', 'platformadmin')) $sql$ into result;
    if coalesce(result, false) then return true; end if;
  end if;

  return false;
end;
$function$;

create or replace function tasks._can_manage_audit_tasks()
returns boolean
language plpgsql
security definer
set search_path to 'tasks', 'public', 'auth', 'pg_catalog'
as $function$
declare
  ident_col text;
  active_col text;
  role_col text;
  super_col text;
  active_sql text := '';
  predicates text[] := array[]::text[];
  q text;
  v_allowed boolean := false;
  permission_has_allow boolean := false;
begin
  if auth.uid() is null then
    return false;
  end if;

  if to_regclass('public.v_core_admin_users_compat_v1') is not null then
    select c.column_name into ident_col from information_schema.columns c where c.table_schema = 'public' and c.table_name = 'v_core_admin_users_compat_v1' and c.column_name in ('auth_user_id', 'user_id', 'open_id', 'id') order by array_position(array['auth_user_id', 'user_id', 'open_id', 'id'], c.column_name) limit 1;
    select c.column_name into active_col from information_schema.columns c where c.table_schema = 'public' and c.table_name = 'v_core_admin_users_compat_v1' and c.column_name in ('is_active', 'active', 'enabled') order by array_position(array['is_active', 'active', 'enabled'], c.column_name) limit 1;
    select c.column_name into role_col from information_schema.columns c where c.table_schema = 'public' and c.table_name = 'v_core_admin_users_compat_v1' and c.column_name in ('role', 'platform_role') order by array_position(array['role', 'platform_role'], c.column_name) limit 1;
    select c.column_name into super_col from information_schema.columns c where c.table_schema = 'public' and c.table_name = 'v_core_admin_users_compat_v1' and c.column_name in ('is_superuser', 'superuser') order by array_position(array['is_superuser', 'superuser'], c.column_name) limit 1;

    if ident_col is not null then
      if active_col is not null then active_sql := format(' and (u.%1$I is null or lower(u.%1$I::text) in (''1'',''true'',''t'',''yes'',''y'',''on'',''active'',''enabled''))', active_col); end if;
      if super_col is not null then predicates := predicates || format('lower(coalesce(u.%1$I::text, '''')) in (''1'',''true'',''t'',''yes'',''y'',''on'')', super_col); end if;
      if role_col is not null then predicates := predicates || format('lower(coalesce(u.%1$I::text, '''')) in (''super_admin'',''superuser'',''admin'',''manager'',''power_admin'',''system_super_user'',''platform_admin'',''platformadmin'')', role_col); end if;
      if array_length(predicates, 1) is not null then
        q := format('select exists (select 1 from public.v_core_admin_users_compat_v1 u where u.%1$I::text = auth.uid()::text %2$s and (%3$s))', ident_col, active_sql, array_to_string(predicates, ' or '));
        execute q into v_allowed;
      end if;
    end if;
  end if;

  if coalesce(v_allowed, false) then return true; end if;

  if to_regclass('public.v_platform_user_system_permissions_compat_v1') is not null then
    select exists (select 1 from information_schema.columns where table_schema = 'public' and table_name = 'v_platform_user_system_permissions_compat_v1' and column_name = 'allow') into permission_has_allow;
    q := 'select exists(select 1 from public.v_platform_user_system_permissions_compat_v1 p where p.user_id::text = auth.uid()::text and p.system_key::text in (''tasks'', ''tasks_system'', ''mustakshif'', ''platformAdmin'') and p.permission_key::text in (''manageTasks'', ''manage_tasks'', ''manageMapLayers'', ''viewReports'', ''read'', ''admin'')';
    if permission_has_allow then q := q || ' and coalesce(p.allow, true) = true'; end if;
    q := q || ')';
    execute q into v_allowed;
  end if;

  if coalesce(v_allowed, false) then return true; end if;

  if to_regclass('public.v_platform_user_system_roles_compat_v1') is not null then
    execute $sql$ select exists(select 1 from public.v_platform_user_system_roles_compat_v1 r where r.user_id::text = auth.uid()::text and r.system_key::text in ('tasks', 'tasks_system', 'mustakshif', 'platformAdmin') and r.role::text in ('admin', 'superuser', 'manager', 'power_admin', 'system_super_user')) $sql$ into v_allowed;
  end if;

  return coalesce(v_allowed, false);
end;
$function$;

commit;
