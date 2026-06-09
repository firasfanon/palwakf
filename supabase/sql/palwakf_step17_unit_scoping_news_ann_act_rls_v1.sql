-- PalWakf (Step 17) - Unified: add unit_id scoping + RLS for (news_articles, announcements, activities)
-- Run this AFTER palwakf_step4_org_units_v1.sql (org_units) and palwakf_step2_rbac_admin_users_v1.sql (RBAC funcs).
-- Safe to re-run (idempotent).

begin;

-- Ensure home unit exists (fallback for legacy rows)
do $$
declare
  v_home_id uuid;
begin
  select id into v_home_id from public.org_units where slug = 'home' limit 1;

  if v_home_id is null then
    insert into public.org_units (name_ar, name_en, slug, is_active)
    values ('الصفحة الرئيسية', 'Home', 'home', true)
    returning id into v_home_id;
  end if;
end
$$;

-- Add unit_id columns (nullable first, then backfill)
alter table public.news_articles add column if not exists unit_id uuid;
alter table public.announcements add column if not exists unit_id uuid;
alter table public.activities add column if not exists unit_id uuid;

-- Backfill any NULL unit_id to home
do $$
declare
  v_home_id uuid;
begin
  select id into v_home_id from public.org_units where slug = 'home' limit 1;

  update public.news_articles set unit_id = v_home_id where unit_id is null;
  update public.announcements set unit_id = v_home_id where unit_id is null;
  update public.activities set unit_id = v_home_id where unit_id is null;
end
$$;

-- Add FK constraints (only if missing)
do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'news_articles_unit_id_fkey'
  ) then
    alter table public.news_articles
      add constraint news_articles_unit_id_fkey
      foreign key (unit_id) references public.org_units(id) on delete restrict;
  end if;

  if not exists (
    select 1 from pg_constraint
    where conname = 'announcements_unit_id_fkey'
  ) then
    alter table public.announcements
      add constraint announcements_unit_id_fkey
      foreign key (unit_id) references public.org_units(id) on delete restrict;
  end if;

  if not exists (
    select 1 from pg_constraint
    where conname = 'activities_unit_id_fkey'
  ) then
    alter table public.activities
      add constraint activities_unit_id_fkey
      foreign key (unit_id) references public.org_units(id) on delete restrict;
  end if;
end
$$;

-- Optional: enforce NOT NULL only if safe
do $$
declare
  v_nulls int;
begin
  select count(*) into v_nulls from public.news_articles where unit_id is null;
  if v_nulls = 0 then
    alter table public.news_articles alter column unit_id set not null;
  end if;

  select count(*) into v_nulls from public.announcements where unit_id is null;
  if v_nulls = 0 then
    alter table public.announcements alter column unit_id set not null;
  end if;

  select count(*) into v_nulls from public.activities where unit_id is null;
  if v_nulls = 0 then
    alter table public.activities alter column unit_id set not null;
  end if;
end
$$;

-- Helpful indexes
create index if not exists idx_news_articles_unit_published
  on public.news_articles (unit_id, published_at desc nulls last);

create index if not exists idx_announcements_unit_created
  on public.announcements (unit_id, created_at desc nulls last);

create index if not exists idx_activities_unit_start
  on public.activities (unit_id, start_date asc nulls last);

-- RLS: public read, admin write (superuser OR manageHome on platformAdmin)
alter table public.news_articles enable row level security;
alter table public.announcements enable row level security;
alter table public.activities enable row level security;

-- News: public select published
drop policy if exists news_public_select_published on public.news_articles;
create policy news_public_select_published
on public.news_articles
for select
to public
using (status = 'published');

-- Announcements: public select active and not expired
drop policy if exists announcements_public_select_active on public.announcements;
create policy announcements_public_select_active
on public.announcements
for select
to public
using (
  is_active = true
  and (valid_until is null or valid_until > current_date)
);

-- Activities: public select non-cancelled
drop policy if exists activities_public_select_non_cancelled on public.activities;
create policy activities_public_select_non_cancelled
on public.activities
for select
to public
using (status <> 'cancelled');

-- Admin write policies (insert/update/delete)
drop policy if exists news_admin_write on public.news_articles;
create policy news_admin_write
on public.news_articles
for all
to authenticated
using (public.is_superuser() or public.has_permission('platformAdmin'::public.system_key, 'manageHome'))
with check (public.is_superuser() or public.has_permission('platformAdmin'::public.system_key, 'manageHome'));

drop policy if exists announcements_admin_write on public.announcements;
create policy announcements_admin_write
on public.announcements
for all
to authenticated
using (public.is_superuser() or public.has_permission('platformAdmin'::public.system_key, 'manageHome'))
with check (public.is_superuser() or public.has_permission('platformAdmin'::public.system_key, 'manageHome'));

drop policy if exists activities_admin_write on public.activities;
create policy activities_admin_write
on public.activities
for all
to authenticated
using (public.is_superuser() or public.has_permission('platformAdmin'::public.system_key, 'manageHome'))
with check (public.is_superuser() or public.has_permission('platformAdmin'::public.system_key, 'manageHome'));

commit;
