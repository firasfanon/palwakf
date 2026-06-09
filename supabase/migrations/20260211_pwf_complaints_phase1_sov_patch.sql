-- PalWakf | Complaints Feature — Phase 1 Sovereign Patch
-- Date: 2026-02-11
--
-- Adds:
-- - unit_id sovereignty (FK -> core.org_units)
-- - unit-scoped public RPCs (track + suggestions)
-- - sovereign submit RPC (unit_slug -> unit_id resolution inside DB)
-- - retention policies + manual purge (no pg_cron required)

begin;

-- 0) Resolve unit_id by slug (security definer; used internally by other functions)
create or replace function public.pwf_resolve_unit_id(p_unit_slug text)
returns uuid
language plpgsql
stable
security definer
set search_path = public, core
as $$
declare
  v_slug text;
  v_id uuid;
begin
  v_slug := lower(trim(coalesce(p_unit_slug, '')));
  if v_slug = '' then
    v_slug := 'home';
  end if;

  select id into v_id
  from core.org_units
  where slug = v_slug
  limit 1;

  if v_id is null then
    select id into v_id
    from core.org_units
    where slug = 'home'
    limit 1;
  end if;

  if v_id is null then
    raise exception 'core.org_units is missing required slug=home';
  end if;

  return v_id;
end;
$$;

-- 1) Add unit_id columns
alter table public.pwf_complaints
  add column if not exists unit_id uuid;

alter table public.pwf_complaint_updates
  add column if not exists unit_id uuid;

alter table public.pwf_complaint_attachments
  add column if not exists unit_id uuid;

-- 2) Backfill existing rows to HOME (safe fallback)
update public.pwf_complaints c
set unit_id = public.pwf_resolve_unit_id('home')
where c.unit_id is null;

update public.pwf_complaint_updates u
set unit_id = c.unit_id
from public.pwf_complaints c
where u.complaint_reference_code = c.reference_code
  and u.unit_id is null;

update public.pwf_complaint_attachments a
set unit_id = c.unit_id
from public.pwf_complaints c
where a.complaint_reference_code = c.reference_code
  and a.unit_id is null;

-- 3) Enforce non-null + default HOME on main table
alter table public.pwf_complaints
  alter column unit_id set default public.pwf_resolve_unit_id('home');

alter table public.pwf_complaints
  alter column unit_id set not null;

alter table public.pwf_complaint_updates
  alter column unit_id set not null;

alter table public.pwf_complaint_attachments
  alter column unit_id set not null;

-- 4) FK constraints to core.org_units (id)
do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'pwf_complaints_unit_fk'
      and conrelid = 'public.pwf_complaints'::regclass
  ) then
    alter table public.pwf_complaints
      add constraint pwf_complaints_unit_fk
      foreign key (unit_id) references core.org_units(id);
  end if;

  if not exists (
    select 1 from pg_constraint
    where conname = 'pwf_complaint_updates_unit_fk'
      and conrelid = 'public.pwf_complaint_updates'::regclass
  ) then
    alter table public.pwf_complaint_updates
      add constraint pwf_complaint_updates_unit_fk
      foreign key (unit_id) references core.org_units(id);
  end if;

  if not exists (
    select 1 from pg_constraint
    where conname = 'pwf_complaint_attachments_unit_fk'
      and conrelid = 'public.pwf_complaint_attachments'::regclass
  ) then
    alter table public.pwf_complaint_attachments
      add constraint pwf_complaint_attachments_unit_fk
      foreign key (unit_id) references core.org_units(id);
  end if;
end $$;

-- 5) Inherit unit_id for child tables (updates/attachments) from parent complaint
create or replace function public.pwf_complaints_inherit_unit_id()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_unit uuid;
begin
  select c.unit_id into v_unit
  from public.pwf_complaints c
  where c.reference_code = new.complaint_reference_code
  limit 1;

  if v_unit is null then
    raise exception 'Invalid complaint_reference_code (missing parent complaint)';
  end if;

  new.unit_id := v_unit;
  return new;
end;
$$;

drop trigger if exists pwf_updates_inherit_unit_id_trg on public.pwf_complaint_updates;
create trigger pwf_updates_inherit_unit_id_trg
before insert on public.pwf_complaint_updates
for each row execute function public.pwf_complaints_inherit_unit_id();

drop trigger if exists pwf_attachments_inherit_unit_id_trg on public.pwf_complaint_attachments;
create trigger pwf_attachments_inherit_unit_id_trg
before insert on public.pwf_complaint_attachments
for each row execute function public.pwf_complaints_inherit_unit_id();

-- 6) Indices
create index if not exists pwf_complaints_unit_created_at_idx
  on public.pwf_complaints (unit_id, created_at desc);

create index if not exists pwf_updates_unit_created_at_idx
  on public.pwf_complaint_updates (unit_id, created_at asc);

create index if not exists pwf_attachments_unit_created_at_idx
  on public.pwf_complaint_attachments (unit_id, created_at asc);

-- 7) Sovereign public submit RPC (unit slug -> unit_id resolution in DB)
-- NOTE: Keeps public insert possible without exposing core schema to anon.
create or replace function public.pwf_submit_complaint(
  p_unit_slug text,
  p_type text,
  p_department text,
  p_subject text,
  p_description text,
  p_email text,
  p_name text default null,
  p_phone text default null,
  p_attachments_count int default 0
)
returns text
language plpgsql
security definer
set search_path = public, core
as $$
declare
  v_unit_id uuid;
  v_ref text;
  v_attachments int;
begin
  v_unit_id := public.pwf_resolve_unit_id(p_unit_slug);
  v_attachments := greatest(coalesce(p_attachments_count, 0), 0);

  insert into public.pwf_complaints (
    unit_id,
    type,
    department,
    subject,
    description,
    email,
    name,
    phone,
    attachments_count
  ) values (
    v_unit_id,
    p_type,
    p_department,
    p_subject,
    p_description,
    p_email,
    nullif(trim(p_name), ''),
    nullif(trim(p_phone), ''),
    v_attachments
  )
  returning reference_code into v_ref;

  return v_ref;
end;
$$;

grant execute on function public.pwf_submit_complaint(text, text, text, text, text, text, text, text, int)
  to anon, authenticated;

-- 8) Unit-scoped public track RPC (prevents cross-unit tracking leakage)
create or replace function public.pwf_track_complaint(p_unit_slug text, p_reference_code text)
returns jsonb
language plpgsql
security definer
set search_path = public, core
as $$
declare
  ref_code text := upper(trim(p_reference_code));
  v_unit_id uuid;
  result jsonb;
begin
  if ref_code is null or ref_code = '' then
    return null;
  end if;

  v_unit_id := public.pwf_resolve_unit_id(p_unit_slug);

  select jsonb_build_object(
    'complaint', to_jsonb(c),
    'updates', coalesce(
      (select jsonb_agg(to_jsonb(u) order by u.created_at asc)
       from public.pwf_complaint_updates u
       where u.complaint_reference_code = c.reference_code),
      '[]'::jsonb
    ),
    'attachments', coalesce(
      (select jsonb_agg(to_jsonb(a) order by a.created_at asc)
       from public.pwf_complaint_attachments a
       where a.complaint_reference_code = c.reference_code),
      '[]'::jsonb
    )
  )
  into result
  from public.pwf_complaints c
  where c.reference_code = ref_code
    and c.unit_id = v_unit_id
  limit 1;

  return result;
end;
$$;

-- Backward-compatible wrapper: defaults to HOME (keeps older clients working)
create or replace function public.pwf_track_complaint(p_reference_code text)
returns jsonb
language plpgsql
security definer
set search_path = public, core
as $$
begin
  return public.pwf_track_complaint('home', p_reference_code);
end;
$$;

grant execute on function public.pwf_track_complaint(text, text) to anon, authenticated;
grant execute on function public.pwf_track_complaint(text) to anon, authenticated;

-- 9) Unit-scoped public suggestions list
create or replace function public.pwf_list_public_suggestions(p_unit_slug text, p_limit int default 50)
returns jsonb
language plpgsql
security definer
set search_path = public, core
as $$
declare
  lim int := greatest(1, least(coalesce(p_limit, 50), 200));
  v_unit_id uuid;
begin
  v_unit_id := public.pwf_resolve_unit_id(p_unit_slug);

  return coalesce(
    (
      select jsonb_agg(
        jsonb_build_object(
          'reference_code', c.reference_code,
          'subject', c.subject,
          'description_preview', left(c.description, 200),
          'status', c.status,
          'created_at', c.created_at
        )
        order by c.created_at desc
      )
      from public.pwf_complaints c
      where c.type = 'suggestion'
        and c.unit_id = v_unit_id
    ),
    '[]'::jsonb
  );
end;
$$;

-- Backward-compatible wrapper: defaults to HOME
create or replace function public.pwf_list_public_suggestions(p_limit int default 50)
returns jsonb
language plpgsql
security definer
set search_path = public, core
as $$
begin
  return public.pwf_list_public_suggestions('home', p_limit);
end;
$$;

grant execute on function public.pwf_list_public_suggestions(text, int) to anon, authenticated;
grant execute on function public.pwf_list_public_suggestions(int) to anon, authenticated;

-- 10) Retention policies + purge (manual invocation; admin-only via pwf_is_admin_user)
create table if not exists public.pwf_complaints_retention_policies (
  unit_id uuid primary key references core.org_units(id),
  retention_days int not null default 90,
  is_active boolean not null default true,
  updated_at timestamptz not null default now(),
  constraint pwf_complaints_retention_days_chk check (retention_days >= 1)
);

-- Ensure HOME policy exists
insert into public.pwf_complaints_retention_policies (unit_id, retention_days, is_active)
select public.pwf_resolve_unit_id('home'), 90, true
where not exists (
  select 1
  from public.pwf_complaints_retention_policies p
  where p.unit_id = public.pwf_resolve_unit_id('home')
);

create or replace function public.pwf_purge_old_complaints(p_unit_id uuid default null)
returns int
language plpgsql
security definer
set search_path = public, core
as $$
declare
  v_total int := 0;
  v_days int;
  v_deleted int;
  r record;
begin
  -- MVP security gate: admin_users only (Phase 2 will move to PermissionKey)
  if not public.pwf_is_admin_user() then
    raise exception 'Not allowed';
  end if;

  if p_unit_id is not null then
    select retention_days into v_days
    from public.pwf_complaints_retention_policies
    where unit_id = p_unit_id and is_active = true
    limit 1;

    if v_days is null then
      v_days := 90;
    end if;

    delete from public.pwf_complaints
    where unit_id = p_unit_id
      and created_at < now() - make_interval(days => v_days);

    get diagnostics v_total = row_count;
    return v_total;
  end if;

  for r in
    select unit_id, retention_days
    from public.pwf_complaints_retention_policies
    where is_active = true
  loop
    delete from public.pwf_complaints
    where unit_id = r.unit_id
      and created_at < now() - make_interval(days => r.retention_days);

    get diagnostics v_deleted = row_count;
    v_total := v_total + v_deleted;
  end loop;

  return v_total;
end;
$$;

grant execute on function public.pwf_purge_old_complaints(uuid) to authenticated;

commit;
