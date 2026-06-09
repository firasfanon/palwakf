-- PalWakf | Complaints Feature (pwf_complaints) - Phase 1 Sovereignty Patch
-- Date: 2026-02-12
-- Apply AFTER: supabase/migrations/20260211_pwf_complaints.sql

begin;

-- Guard: base tables must exist
do $$
begin
  if to_regclass('public.pwf_complaints') is null then
    raise exception 'Missing base tables. Run 20260211_pwf_complaints.sql first.';
  end if;

  if to_regclass('core.org_units') is null then
    raise exception 'Missing core.org_units (required for unit sovereignty).';
  end if;
end $$;

-- 1) Unit resolution helpers
create or replace function public.pwf_require_home_unit_id()
returns uuid
language plpgsql
stable
as $$
declare
  v uuid;
begin
  select id into v from core.org_units where slug = 'home' limit 1;
  if v is null then
    raise exception 'core.org_units must contain slug=home';
  end if;
  return v;
end;
$$;

create or replace function public.pwf_resolve_unit_id(p_unit_slug text)
returns uuid
language plpgsql
stable
as $$
declare
  v uuid;
  s text := lower(trim(coalesce(p_unit_slug, '')));
begin
  if s = '' then
    return public.pwf_require_home_unit_id();
  end if;

  select id into v from core.org_units where slug = s limit 1;
  if v is null then
    v := public.pwf_require_home_unit_id();
  end if;
  return v;
end;
$$;

-- 2) Add unit_id columns (nullable first)
alter table public.pwf_complaints add column if not exists unit_id uuid;
alter table public.pwf_complaint_updates add column if not exists unit_id uuid;
alter table public.pwf_complaint_attachments add column if not exists unit_id uuid;

-- 3) Backfill existing rows to HOME
update public.pwf_complaints
set unit_id = public.pwf_require_home_unit_id()
where unit_id is null;

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

-- 4) Add FK constraints (idempotent)
do $$
begin
  if not exists (select 1 from pg_constraint where conname = 'pwf_complaints_unit_fk') then
    alter table public.pwf_complaints
      add constraint pwf_complaints_unit_fk
      foreign key (unit_id) references core.org_units(id);
  end if;

  if not exists (select 1 from pg_constraint where conname = 'pwf_complaint_updates_unit_fk') then
    alter table public.pwf_complaint_updates
      add constraint pwf_complaint_updates_unit_fk
      foreign key (unit_id) references core.org_units(id);
  end if;

  if not exists (select 1 from pg_constraint where conname = 'pwf_complaint_attachments_unit_fk') then
    alter table public.pwf_complaint_attachments
      add constraint pwf_complaint_attachments_unit_fk
      foreign key (unit_id) references core.org_units(id);
  end if;
end $$;

-- 5) Defaults + NOT NULL
alter table public.pwf_complaints
  alter column unit_id set default public.pwf_require_home_unit_id();

alter table public.pwf_complaint_updates
  alter column unit_id set default public.pwf_require_home_unit_id();

alter table public.pwf_complaint_attachments
  alter column unit_id set default public.pwf_require_home_unit_id();

alter table public.pwf_complaints
  alter column unit_id set not null;

alter table public.pwf_complaint_updates
  alter column unit_id set not null;

alter table public.pwf_complaint_attachments
  alter column unit_id set not null;

-- 6) Inheritance triggers for child tables
create or replace function public.pwf_complaints_set_unit_id()
returns trigger
language plpgsql
as $$
begin
  if new.unit_id is null then
    new.unit_id := public.pwf_require_home_unit_id();
  end if;
  return new;
end;
$$;

drop trigger if exists pwf_complaints_set_unit_id_trg on public.pwf_complaints;
create trigger pwf_complaints_set_unit_id_trg
before insert on public.pwf_complaints
for each row execute function public.pwf_complaints_set_unit_id();

create or replace function public.pwf_complaints_inherit_unit_id()
returns trigger
language plpgsql
as $$
declare
  v uuid;
begin
  select unit_id into v
  from public.pwf_complaints
  where reference_code = new.complaint_reference_code
  limit 1;

  if v is null then
    raise exception 'Invalid complaint_reference_code (no parent): %', new.complaint_reference_code;
  end if;

  new.unit_id := v;
  return new;
end;
$$;

drop trigger if exists pwf_updates_inherit_unit_id_trg on public.pwf_complaint_updates;
create trigger pwf_updates_inherit_unit_id_trg
before insert on public.pwf_complaint_updates
for each row execute function public.pwf_complaints_inherit_unit_id();

drop trigger if exists pwf_attach_inherit_unit_id_trg on public.pwf_complaint_attachments;
create trigger pwf_attach_inherit_unit_id_trg
before insert on public.pwf_complaint_attachments
for each row execute function public.pwf_complaints_inherit_unit_id();

-- 7) Helpful indices
create index if not exists pwf_complaints_unit_created_idx on public.pwf_complaints (unit_id, created_at desc);
create index if not exists pwf_updates_unit_created_idx on public.pwf_complaint_updates (unit_id, created_at asc);
create index if not exists pwf_attach_unit_created_idx on public.pwf_complaint_attachments (unit_id, created_at asc);

-- 8) Retention policies (per-unit)
create table if not exists public.pwf_complaints_retention_policies (
  unit_id uuid primary key references core.org_units(id) on delete cascade,
  retention_days int not null default 90,
  is_active boolean not null default true,
  updated_at timestamptz not null default now()
);

-- Default policy for HOME if missing
insert into public.pwf_complaints_retention_policies (unit_id, retention_days, is_active)
values (public.pwf_require_home_unit_id(), 90, true)
on conflict (unit_id) do nothing;

create or replace function public.pwf_set_retention_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

drop trigger if exists pwf_retention_set_updated_at_trg on public.pwf_complaints_retention_policies;
create trigger pwf_retention_set_updated_at_trg
before update on public.pwf_complaints_retention_policies
for each row execute function public.pwf_set_retention_updated_at();

-- Purge old complaints (manual call; no pg_cron assumed)
create or replace function public.pwf_purge_old_complaints(p_unit_slug text default null)
returns int
language plpgsql
security definer
set search_path = public
as $$
declare
  total_deleted int := 0;
  v_deleted int := 0;
  v_unit uuid;
  r record;
begin
  if not public.pwf_is_admin_user() then
    raise exception 'Not authorized';
  end if;

  if p_unit_slug is not null and trim(p_unit_slug) <> '' then
    v_unit := public.pwf_resolve_unit_id(p_unit_slug);

    select retention_days into r
    from public.pwf_complaints_retention_policies
    where unit_id = v_unit and is_active = true
    limit 1;

    if r is null then
      -- fallback
      r := 90;
    end if;

    delete from public.pwf_complaints
    where unit_id = v_unit
      and created_at < now() - make_interval(days => r);

    get diagnostics total_deleted = row_count;
    return total_deleted;
  end if;

  -- All active units
  for r in
    select unit_id, retention_days
    from public.pwf_complaints_retention_policies
    where is_active = true
  loop
    delete from public.pwf_complaints
    where unit_id = r.unit_id
      and created_at < now() - make_interval(days => r.retention_days);

    get diagnostics v_deleted = row_count;
    total_deleted := total_deleted + v_deleted;
  end loop;

  return total_deleted;
end;
$$;

grant execute on function public.pwf_purge_old_complaints(text) to authenticated;

-- 9) Unit-scoped public RPCs (keep existing ones for HOME)
create or replace function public.pwf_track_complaint_scoped(p_unit_slug text, p_reference_code text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  ref_code text := upper(trim(p_reference_code));
  u_id uuid := public.pwf_resolve_unit_id(p_unit_slug);
  result jsonb;
begin
  if ref_code is null or ref_code = '' then
    return null;
  end if;

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
    and c.unit_id = u_id
  limit 1;

  return result;
end;
$$;

create or replace function public.pwf_list_public_suggestions_scoped(p_unit_slug text, p_limit int default 50)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  lim int := greatest(1, least(coalesce(p_limit, 50), 200));
  u_id uuid := public.pwf_resolve_unit_id(p_unit_slug);
begin
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
        and c.unit_id = u_id
    ),
    '[]'::jsonb
  );
end;
$$;

grant execute on function public.pwf_track_complaint_scoped(text, text) to anon, authenticated;
grant execute on function public.pwf_list_public_suggestions_scoped(text, int) to anon, authenticated;

-- 10) Public submit RPC (unit-scoped, minimal validation)
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
set search_path = public
as $$
declare
  v_ref text;
  v_unit uuid := public.pwf_resolve_unit_id(p_unit_slug);
  v_type text := trim(coalesce(p_type, ''));
  v_dept text := trim(coalesce(p_department, ''));
  v_subject text := trim(coalesce(p_subject, ''));
  v_desc text := trim(coalesce(p_description, ''));
  v_email text := lower(trim(coalesce(p_email, '')));
  v_name text := nullif(trim(coalesce(p_name, '')), '');
  v_phone text := nullif(trim(coalesce(p_phone, '')), '');
  v_attach int := coalesce(p_attachments_count, 0);
begin
  -- Minimal validation (aligns with table checks/policy)
  if v_type not in ('complaint','suggestion','inquiry','praise','report') then
    raise exception 'Invalid type';
  end if;
  if v_dept not in ('mosques','education','waqf','hajj','fatwa','general') then
    raise exception 'Invalid department';
  end if;
  if v_subject = '' or v_desc = '' or v_email = '' then
    raise exception 'Missing required fields';
  end if;
  if v_attach < 0 then
    v_attach := 0;
  end if;

  insert into public.pwf_complaints (
    unit_id,
    type,
    department,
    subject,
    description,
    name,
    email,
    phone,
    attachments_count
  ) values (
    v_unit,
    v_type,
    v_dept,
    v_subject,
    v_desc,
    v_name,
    v_email,
    v_phone,
    v_attach
  )
  returning reference_code into v_ref;

  return v_ref;
end;
$$;

grant execute on function public.pwf_submit_complaint(text, text, text, text, text, text, text, text, int) to anon, authenticated;

commit;
