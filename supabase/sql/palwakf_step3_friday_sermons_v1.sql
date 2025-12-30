-- PalWakf | Step 3 (Friday Sermons) v1
-- Creates: public.friday_sermons
-- RLS:
--   - Public can READ published items
--   - Admin write requires: superuser OR permission manageSite on system platformAdmin

create extension if not exists pgcrypto;

create table if not exists public.friday_sermons (
  id uuid not null default gen_random_uuid(),
  title_ar text not null,
  title_en text null,
  sermon_date date not null,
  speaker_name text null,
  mosque_name text null,
  summary_ar text null,
  summary_en text null,
  content_ar text null,
  content_en text null,
  audio_url text null,
  pdf_url text null,
  is_published boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint friday_sermons_pkey primary key (id)
);

create index if not exists idx_friday_sermons_date on public.friday_sermons(sermon_date desc);
create index if not exists idx_friday_sermons_published on public.friday_sermons(is_published);

alter table public.friday_sermons enable row level security;

-- Clean old policies if re-running
drop policy if exists friday_sermons_read on public.friday_sermons;
drop policy if exists friday_sermons_admin_write on public.friday_sermons;

-- Public read (published) + admin read all
create policy friday_sermons_read
on public.friday_sermons
for select
using (
  is_published = true
  or public.is_superuser()
  or public.has_permission('platformAdmin'::public.system_key, 'manageSite')
);

-- Admin write (insert/update/delete)
create policy friday_sermons_admin_write
on public.friday_sermons
for all
using (
  public.is_superuser()
  or public.has_permission('platformAdmin'::public.system_key, 'manageSite')
)
with check (
  public.is_superuser()
  or public.has_permission('platformAdmin'::public.system_key, 'manageSite')
);
