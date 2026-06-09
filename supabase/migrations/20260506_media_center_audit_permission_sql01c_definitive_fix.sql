-- PalWakf — Media Center SQL 01C Definitive Audit Permission Fix
-- Date: 2026-05-06
-- Scope:
--   1) Creates/fixes media-center audit permission shim functions.
--   2) Creates the missing diagnostics RPC if SQL 01B was not applied.
--   3) Replaces audit RPC with a SQL-Editor-safe and app-auth-safe implementation.
--   4) Keeps this as a temporary shim until sovereign RBAC is connected.
--
-- Important:
--   Apply this file after 20260506_media_center_consolidation_v1.sql.
--   It is idempotent and can be re-run safely.

create extension if not exists pgcrypto;

create table if not exists public.media_center_audit_events (
  id uuid primary key default gen_random_uuid(),
  event_key text not null,
  content_family text not null,
  action_key text not null,
  record_id uuid null,
  unit_slug text null,
  source_route text null,
  notes text null,
  metadata jsonb not null default '{}'::jsonb,
  actor_id uuid null default auth.uid(),
  created_at timestamptz not null default now()
);

comment on table public.media_center_audit_events is
  'Audit events for the consolidated PalWakf media center. SQL 01C fixes temporary audit permission shims until sovereign RBAC is connected.';

create index if not exists idx_media_center_audit_events_family_created
  on public.media_center_audit_events (content_family, created_at desc);

create index if not exists idx_media_center_audit_events_record
  on public.media_center_audit_events (record_id)
  where record_id is not null;

alter table public.media_center_audit_events enable row level security;

-- Read shim.
-- Allows authenticated app users, service role, and SQL Editor/admin migration execution.
create or replace function public.media_center_can_read_v1()
returns boolean
language sql
stable
security definer
set search_path = public, auth
as $$
  select
    auth.uid() is not null
    or coalesce(auth.role(), '') in ('authenticated', 'service_role')
    or session_user in ('postgres', 'supabase_admin', 'service_role')
    or coalesce(current_setting('request.jwt.claim.role', true), '') in ('authenticated', 'service_role');
$$;

-- Write shim.
-- Allows authenticated app users, service role, and SQL Editor/admin migration execution.
-- Uses session_user rather than current_user because this function may run under SECURITY DEFINER wrappers.
create or replace function public.media_center_can_write_v1()
returns boolean
language sql
stable
security definer
set search_path = public, auth
as $$
  select
    auth.uid() is not null
    or coalesce(auth.role(), '') = 'service_role'
    or session_user in ('postgres', 'supabase_admin', 'service_role')
    or coalesce(current_setting('request.jwt.claim.role', true), '') = 'service_role';
$$;

-- Diagnostic RPC. This is the missing function reported by Supabase SQL Editor.
create or replace function public.rpc_media_center_audit_permission_diagnostics_v1()
returns table (
  can_read boolean,
  can_write boolean,
  auth_role text,
  jwt_role text,
  has_auth_uid boolean,
  sql_session_user text,
  sql_current_user text,
  audit_table_exists boolean,
  audit_rpc_exists boolean
)
language sql
stable
security definer
set search_path = public, auth
as $$
  select
    public.media_center_can_read_v1() as can_read,
    public.media_center_can_write_v1() as can_write,
    coalesce(auth.role(), '')::text as auth_role,
    coalesce(current_setting('request.jwt.claim.role', true), '')::text as jwt_role,
    auth.uid() is not null as has_auth_uid,
    session_user::text as sql_session_user,
    current_user::text as sql_current_user,
    to_regclass('public.media_center_audit_events') is not null as audit_table_exists,
    exists (
      select 1
      from pg_proc p
      join pg_namespace n on n.oid = p.pronamespace
      where n.nspname = 'public'
        and p.proname = 'rpc_media_center_record_audit_event_v1'
    ) as audit_rpc_exists;
$$;

-- Recreate RLS policies using corrected shim functions.
drop policy if exists media_center_audit_events_select_v1 on public.media_center_audit_events;
create policy media_center_audit_events_select_v1
on public.media_center_audit_events
for select
to authenticated
using (public.media_center_can_read_v1());

drop policy if exists media_center_audit_events_insert_v1 on public.media_center_audit_events;
create policy media_center_audit_events_insert_v1
on public.media_center_audit_events
for insert
to authenticated
with check (public.media_center_can_write_v1());

-- Replace audit RPC with corrected permission behavior and clear validation.
create or replace function public.rpc_media_center_record_audit_event_v1(
  p_content_family text,
  p_action_key text,
  p_record_id uuid default null,
  p_unit_slug text default null,
  p_source_route text default null,
  p_notes text default null,
  p_metadata jsonb default '{}'::jsonb
)
returns uuid
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  v_id uuid;
  v_family text := nullif(trim(coalesce(p_content_family, '')), '');
  v_action text := nullif(trim(coalesce(p_action_key, '')), '');
  v_allowed_families constant text[] := array[
    'news',
    'announcements',
    'activities',
    'events',
    'photos',
    'videos',
    'breaking_news',
    'friday_sermons',
    'hero_slider',
    'media_center'
  ];
begin
  if not public.media_center_can_write_v1() then
    raise exception 'Not allowed to write media center audit events. auth_role=%, jwt_role=%, has_auth_uid=%, session_user=%',
      coalesce(auth.role(), ''),
      coalesce(current_setting('request.jwt.claim.role', true), ''),
      auth.uid() is not null,
      session_user;
  end if;

  if v_family is null then
    raise exception 'content_family is required';
  end if;

  if not (v_family = any(v_allowed_families)) then
    raise exception 'Unsupported media center content_family: %', v_family;
  end if;

  if v_action is null then
    raise exception 'action_key is required';
  end if;

  insert into public.media_center_audit_events (
    event_key,
    content_family,
    action_key,
    record_id,
    unit_slug,
    source_route,
    notes,
    metadata
  ) values (
    concat('media_center.', v_family, '.', v_action),
    v_family,
    v_action,
    p_record_id,
    nullif(trim(coalesce(p_unit_slug, '')), ''),
    nullif(trim(coalesce(p_source_route, '')), ''),
    nullif(trim(coalesce(p_notes, '')), ''),
    coalesce(p_metadata, '{}'::jsonb)
  ) returning id into v_id;

  return v_id;
end;
$$;

-- Grants are guarded so this file does not fail in environments where a role is absent.
do $do$
begin
  if exists (select 1 from pg_roles where rolname = 'authenticated') then
    grant execute on function public.media_center_can_read_v1() to authenticated;
    grant execute on function public.media_center_can_write_v1() to authenticated;
    grant execute on function public.rpc_media_center_audit_permission_diagnostics_v1() to authenticated;
    grant execute on function public.rpc_media_center_record_audit_event_v1(text, text, uuid, text, text, text, jsonb) to authenticated;
  end if;

  if exists (select 1 from pg_roles where rolname = 'service_role') then
    grant execute on function public.media_center_can_read_v1() to service_role;
    grant execute on function public.media_center_can_write_v1() to service_role;
    grant execute on function public.rpc_media_center_audit_permission_diagnostics_v1() to service_role;
    grant execute on function public.rpc_media_center_record_audit_event_v1(text, text, uuid, text, text, text, jsonb) to service_role;
  end if;
end
$do$;

-- Direct post-apply visibility. Supabase SQL Editor can show this immediately.
select * from public.rpc_media_center_audit_permission_diagnostics_v1();
