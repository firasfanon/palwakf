-- palwakf_step7_media_gallery_items_v1.sql
-- Media galleries (Photos/Videos) scoped by org unit

-- 1) Enum
do $$
begin
  if not exists (select 1 from pg_type where typname = 'media_type') then
    create type public.media_type as enum ('photo', 'video');
  end if;
end $$;

-- 2) Table
create table if not exists public.media_gallery_items (
  id uuid not null default gen_random_uuid (),
  unit_id uuid not null references public.org_units (id) on delete cascade,
  media_type public.media_type not null default 'photo',
  title text not null default ''::text,
  description text not null default ''::text,
  media_url text not null,
  thumbnail_url text null,
  external_url text null,
  is_active boolean not null default true,
  display_order integer not null default 0,
  created_by uuid null references auth.users (id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint media_gallery_items_pkey primary key (id)
);

-- 3) Indexes
create index if not exists idx_media_gallery_items_unit_type_active
  on public.media_gallery_items (unit_id, media_type, is_active);

create index if not exists idx_media_gallery_items_unit_order
  on public.media_gallery_items (unit_id, display_order);

-- 4) RLS
alter table public.media_gallery_items enable row level security;

drop policy if exists media_gallery_public_read on public.media_gallery_items;
create policy media_gallery_public_read
  on public.media_gallery_items
  for select
  to anon, authenticated
  using (is_active = true);

drop policy if exists media_gallery_admin_write on public.media_gallery_items;
create policy media_gallery_admin_write
  on public.media_gallery_items
  for all
  to authenticated
  using (
    public.is_superuser()
    or public.has_permission('platformAdmin', 'manageHome')
  )
  with check (
    public.is_superuser()
    or public.has_permission('platformAdmin', 'manageHome')
  );

-- Note: updated_at can be maintained by application or by an existing trigger if you have one.
