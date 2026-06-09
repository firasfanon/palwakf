-- PalWakf | Complaints Feature (pwf_complaints) - Supabase/Postgres
-- Date: 2026-02-11
-- Notes:
-- - Creates minimal tables + triggers + RLS + RPCs for public submit/track + public suggestions.
-- - admin_users is identity source: admin access is granted only if auth.uid() exists in public.admin_users.

begin;

-- Extensions (Supabase عادةً مفعّلة، لكن هذا آمن)
create extension if not exists pgcrypto;

-- 1) Complaints main table
create table if not exists public.pwf_complaints (
  reference_code text primary key,
  type text not null,
  department text not null,
  subject text not null,
  description text not null,
  name text null,
  email text not null,
  phone text null,
  attachments_count integer not null default 0,
  status text not null default 'pending',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint pwf_complaints_type_chk check (type in ('complaint','suggestion','inquiry','praise','report')),
  constraint pwf_complaints_dept_chk check (department in ('mosques','education','waqf','hajj','fatwa','general')),
  constraint pwf_complaints_status_chk check (status in ('pending','processing','resolved','rejected')),
  constraint pwf_complaints_subject_chk check (length(trim(subject)) > 0),
  constraint pwf_complaints_desc_chk check (length(trim(description)) > 0),
  constraint pwf_complaints_email_chk check (length(trim(email)) > 0),
  constraint pwf_complaints_attachments_chk check (attachments_count >= 0)
);

create index if not exists pwf_complaints_created_at_idx on public.pwf_complaints (created_at desc);
create index if not exists pwf_complaints_type_idx on public.pwf_complaints (type);
create index if not exists pwf_complaints_status_idx on public.pwf_complaints (status);

-- 2) Complaint updates (timeline)
create table if not exists public.pwf_complaint_updates (
  id uuid primary key default gen_random_uuid(),
  complaint_reference_code text not null references public.pwf_complaints(reference_code) on delete cascade,
  status text not null,
  message_key text not null,
  created_at timestamptz not null default now(),
  created_by uuid null, -- auth.users.id (اختياري)
  constraint pwf_updates_status_chk check (status in ('pending','processing','resolved','rejected'))
);

create index if not exists pwf_updates_ref_idx on public.pwf_complaint_updates (complaint_reference_code);
create index if not exists pwf_updates_created_at_idx on public.pwf_complaint_updates (created_at asc);

-- 3) Complaint attachments metadata (اختياري - جاهز للـ Storage)
create table if not exists public.pwf_complaint_attachments (
  id uuid primary key default gen_random_uuid(),
  complaint_reference_code text not null references public.pwf_complaints(reference_code) on delete cascade,
  file_name text not null,
  storage_path text not null,
  mime_type text null,
  size_bytes integer not null default 0,
  created_at timestamptz not null default now(),
  created_by uuid null,
  constraint pwf_attach_size_chk check (size_bytes >= 0)
);

create index if not exists pwf_attach_ref_idx on public.pwf_complaint_attachments (complaint_reference_code);
create index if not exists pwf_attach_created_at_idx on public.pwf_complaint_attachments (created_at asc);

-- 4) Helpers: updated_at
create or replace function public.pwf_set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

drop trigger if exists pwf_complaints_set_updated_at on public.pwf_complaints;
create trigger pwf_complaints_set_updated_at
before update on public.pwf_complaints
for each row execute function public.pwf_set_updated_at();

-- 5) Reference code generator (REF########)
create or replace function public.pwf_generate_reference_code()
returns text
language plpgsql
as $$
declare
  candidate text;
  attempt int := 0;
begin
  -- محاولة بسيطة لتفادي التصادم
  loop
    attempt := attempt + 1;
    candidate := 'REF' || lpad(((extract(epoch from now()) * 1000)::bigint % 100000000)::text, 8, '0');

    -- إذا حدث تصادم (نادر جداً) أضف مزيداً من العشوائية
    if exists (select 1 from public.pwf_complaints where reference_code = candidate) then
      candidate := 'REF' || lpad(((abs(('x' || substr(encode(gen_random_bytes(8), 'hex'), 1, 8))::bit(32)::int)) % 100000000))::text, 8, '0');
    end if;

    if not exists (select 1 from public.pwf_complaints where reference_code = candidate) then
      return candidate;
    end if;

    exit when attempt >= 5;
  end loop;

  -- fallback
  return 'REF' || lpad(((abs(('x' || substr(encode(gen_random_bytes(8), 'hex'), 1, 8))::bit(32)::int)) % 100000000))::text, 8, '0');
end;
$$;

-- ensure reference_code default
alter table public.pwf_complaints
  alter column reference_code set default public.pwf_generate_reference_code();

-- normalize reference_code + email to lower/upper where needed
create or replace function public.pwf_complaints_normalize()
returns trigger
language plpgsql
as $$
begin
  new.reference_code := upper(trim(new.reference_code));
  new.email := lower(trim(new.email));
  new.subject := trim(new.subject);
  new.description := trim(new.description);
  if new.name is not null then new.name := nullif(trim(new.name), ''); end if;
  if new.phone is not null then new.phone := nullif(trim(new.phone), ''); end if;
  return new;
end;
$$;

drop trigger if exists pwf_complaints_normalize_trg on public.pwf_complaints;
create trigger pwf_complaints_normalize_trg
before insert or update on public.pwf_complaints
for each row execute function public.pwf_complaints_normalize();

-- 6) After insert: create first update row
create or replace function public.pwf_complaints_after_insert()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.pwf_complaint_updates (
    complaint_reference_code,
    status,
    message_key,
    created_by
  ) values (
    new.reference_code,
    new.status,
    'complaints.update.received',
    auth.uid()
  );
  return new;
end;
$$;

drop trigger if exists pwf_complaints_after_insert_trg on public.pwf_complaints;
create trigger pwf_complaints_after_insert_trg
after insert on public.pwf_complaints
for each row execute function public.pwf_complaints_after_insert();

-- 7) RLS
alter table public.pwf_complaints enable row level security;
alter table public.pwf_complaint_updates enable row level security;
alter table public.pwf_complaint_attachments enable row level security;

-- Helper predicate: is admin user (identity source)
create or replace function public.pwf_is_admin_user()
returns boolean
language sql
stable
as $$
  select exists (
    select 1
    from public.admin_users au
    where au.id = auth.uid()
  );
$$;

-- Complaints policies
drop policy if exists pwf_complaints_insert_public on public.pwf_complaints;
create policy pwf_complaints_insert_public
on public.pwf_complaints
for insert
to anon, authenticated
with check (
  -- لا نقيّد الهوية (مسموح عامةً)
  type in ('complaint','suggestion','inquiry','praise','report')
  and department in ('mosques','education','waqf','hajj','fatwa','general')
  and length(trim(subject)) > 0
  and length(trim(description)) > 0
  and length(trim(email)) > 0
);

drop policy if exists pwf_complaints_admin_select on public.pwf_complaints;
create policy pwf_complaints_admin_select
on public.pwf_complaints
for select
to authenticated
using (public.pwf_is_admin_user());

drop policy if exists pwf_complaints_admin_update on public.pwf_complaints;
create policy pwf_complaints_admin_update
on public.pwf_complaints
for update
to authenticated
using (public.pwf_is_admin_user())
with check (public.pwf_is_admin_user());

-- Updates policies
drop policy if exists pwf_updates_admin_select on public.pwf_complaint_updates;
create policy pwf_updates_admin_select
on public.pwf_complaint_updates
for select
to authenticated
using (public.pwf_is_admin_user());

drop policy if exists pwf_updates_admin_insert on public.pwf_complaint_updates;
create policy pwf_updates_admin_insert
on public.pwf_complaint_updates
for insert
to authenticated
with check (public.pwf_is_admin_user());

-- Attachments policies (metadata)
drop policy if exists pwf_attach_admin_select on public.pwf_complaint_attachments;
create policy pwf_attach_admin_select
on public.pwf_complaint_attachments
for select
to authenticated
using (public.pwf_is_admin_user());

drop policy if exists pwf_attach_admin_insert on public.pwf_complaint_attachments;
create policy pwf_attach_admin_insert
on public.pwf_complaint_attachments
for insert
to authenticated
with check (public.pwf_is_admin_user());

-- 8) Public RPCs (track + list suggestions) - bypass RLS safely
-- IMPORTANT: These functions are SECURITY DEFINER. Keep them minimal and read-only.

create or replace function public.pwf_track_complaint(p_reference_code text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  ref_code text := upper(trim(p_reference_code));
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
  limit 1;

  return result;
end;
$$;

-- Suggestions listing (public)
create or replace function public.pwf_list_public_suggestions(p_limit int default 50)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  lim int := greatest(1, least(coalesce(p_limit, 50), 200));
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
    ),
    '[]'::jsonb
  );
end;
$$;


-- Grants for public RPCs
grant execute on function public.pwf_track_complaint(text) to anon, authenticated;
grant execute on function public.pwf_list_public_suggestions(int) to anon, authenticated;

commit;
