-- Database Wave B-1A — Media Center Bootstrap Controlled Schema Apply
-- APPLY SCRIPT: creates empty sovereign media_center contracts only.
-- Scope: media_center.* tables/views/RLS. No public media extraction, no public wrapper activation, no waqf mutation.
-- Safe principles: IF NOT EXISTS, no DROP, no data import, no mutation to public.news/public.news_articles/public.activities/public.announcements.

begin;

create schema if not exists media_center;

create table if not exists media_center.content_items (
  id uuid primary key default gen_random_uuid(),
  legacy_source text,
  legacy_source_id text,
  content_key text,
  content_type text not null default 'news_article',
  title_ar text not null default '',
  title_en text,
  summary_ar text,
  summary_en text,
  body_ar text,
  body_en text,
  category_key text,
  status text not null default 'draft' check (status in ('draft','in_review','approved','scheduled','published','archived','rejected')),
  visibility_scope text not null default 'public' check (visibility_scope in ('public','internal','unit','system')),
  unit_id uuid,
  unit_slug text,
  author_user_id uuid,
  owner_system text not null default 'media_center',
  source_public_table text,
  published_at timestamptz,
  scheduled_at timestamptz,
  archived_at timestamptz,
  metadata jsonb not null default '{}'::jsonb,
  created_by uuid,
  updated_by uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists media_center.content_assets (
  id uuid primary key default gen_random_uuid(),
  content_item_id uuid references media_center.content_items(id) on delete cascade,
  asset_type text not null default 'image',
  title_ar text,
  title_en text,
  alt_text_ar text,
  alt_text_en text,
  url text,
  storage_bucket text,
  storage_path text,
  filename text,
  mime_type text,
  file_size_bytes bigint,
  is_primary boolean not null default false,
  display_order integer not null default 0,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists media_center.editorial_events (
  id uuid primary key default gen_random_uuid(),
  content_item_id uuid references media_center.content_items(id) on delete cascade,
  from_state text,
  to_state text not null,
  action_key text not null,
  actor_user_id uuid,
  actor_scope text,
  note_ar text,
  note_en text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists media_center.content_publication_channels (
  id uuid primary key default gen_random_uuid(),
  content_item_id uuid references media_center.content_items(id) on delete cascade,
  channel_key text not null,
  is_enabled boolean not null default true,
  display_order integer not null default 0,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (content_item_id, channel_key)
);

create table if not exists media_center.content_category_map (
  id uuid primary key default gen_random_uuid(),
  legacy_source text,
  legacy_category_key text,
  media_category_key text not null,
  content_type text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  unique (legacy_source, legacy_category_key, media_category_key)
);

create index if not exists idx_media_content_items_status on media_center.content_items(status);
create index if not exists idx_media_content_items_type_status on media_center.content_items(content_type, status);
create index if not exists idx_media_content_items_published_at on media_center.content_items(published_at desc);
create index if not exists idx_media_content_items_unit_slug on media_center.content_items(unit_slug);
create index if not exists idx_media_content_items_category on media_center.content_items(category_key);
create index if not exists idx_media_content_assets_item on media_center.content_assets(content_item_id);
create index if not exists idx_media_editorial_events_item_created on media_center.editorial_events(content_item_id, created_at desc);
create index if not exists idx_media_publication_channels_item on media_center.content_publication_channels(content_item_id);

alter table media_center.content_items enable row level security;
alter table media_center.content_assets enable row level security;
alter table media_center.editorial_events enable row level security;
alter table media_center.content_publication_channels enable row level security;
alter table media_center.content_category_map enable row level security;

do $$
begin
  if not exists (select 1 from pg_policies where schemaname='media_center' and tablename='content_items' and policyname='media_content_items_published_public_read') then
    create policy media_content_items_published_public_read
      on media_center.content_items
      for select
      to anon, authenticated
      using (status = 'published' and visibility_scope = 'public' and (published_at is null or published_at <= now()));
  end if;

  if not exists (select 1 from pg_policies where schemaname='media_center' and tablename='content_items' and policyname='media_content_items_service_role_all') then
    create policy media_content_items_service_role_all
      on media_center.content_items
      for all
      to service_role
      using (true)
      with check (true);
  end if;

  if not exists (select 1 from pg_policies where schemaname='media_center' and tablename='content_assets' and policyname='media_content_assets_published_public_read') then
    create policy media_content_assets_published_public_read
      on media_center.content_assets
      for select
      to anon, authenticated
      using (
        exists (
          select 1 from media_center.content_items ci
          where ci.id = content_assets.content_item_id
            and ci.status = 'published'
            and ci.visibility_scope = 'public'
            and (ci.published_at is null or ci.published_at <= now())
        )
      );
  end if;

  if not exists (select 1 from pg_policies where schemaname='media_center' and tablename='content_assets' and policyname='media_content_assets_service_role_all') then
    create policy media_content_assets_service_role_all
      on media_center.content_assets
      for all
      to service_role
      using (true)
      with check (true);
  end if;

  if not exists (select 1 from pg_policies where schemaname='media_center' and tablename='editorial_events' and policyname='media_editorial_events_service_role_all') then
    create policy media_editorial_events_service_role_all
      on media_center.editorial_events
      for all
      to service_role
      using (true)
      with check (true);
  end if;

  if not exists (select 1 from pg_policies where schemaname='media_center' and tablename='content_publication_channels' and policyname='media_publication_channels_service_role_all') then
    create policy media_publication_channels_service_role_all
      on media_center.content_publication_channels
      for all
      to service_role
      using (true)
      with check (true);
  end if;

  if not exists (select 1 from pg_policies where schemaname='media_center' and tablename='content_category_map' and policyname='media_category_map_service_role_all') then
    create policy media_category_map_service_role_all
      on media_center.content_category_map
      for all
      to service_role
      using (true)
      with check (true);
  end if;
end $$;

create or replace view media_center.v_content_items_public_v1 as
select
  ci.id,
  ci.content_key,
  ci.content_type,
  ci.title_ar,
  ci.title_en,
  ci.summary_ar,
  ci.summary_en,
  ci.category_key,
  ci.unit_slug,
  ci.published_at,
  ci.metadata,
  ci.created_at,
  ci.updated_at
from media_center.content_items ci
where ci.status = 'published'
  and ci.visibility_scope = 'public'
  and (ci.published_at is null or ci.published_at <= now());

create or replace view media_center.v_content_items_admin_v1 as
select
  ci.*,
  (select count(*) from media_center.content_assets ca where ca.content_item_id = ci.id) as assets_count,
  (select max(ee.created_at) from media_center.editorial_events ee where ee.content_item_id = ci.id) as last_editorial_event_at
from media_center.content_items ci;

revoke all on schema media_center from public;
revoke all on all tables in schema media_center from public;
revoke all on all sequences in schema media_center from public;
revoke all on all functions in schema media_center from public;

grant usage on schema media_center to anon, authenticated;
grant select on media_center.v_content_items_public_v1 to anon, authenticated;
grant select on media_center.v_content_items_admin_v1 to authenticated;

comment on schema media_center is 'Sovereign media center schema for PalWakf. Bootstrap controlled apply created empty contracts only; no legacy public media extraction.';
comment on table media_center.content_items is 'Sovereign media content storage contract. Empty at bootstrap. Legacy public media tables remain unchanged.';
comment on view media_center.v_content_items_public_v1 is 'Published-only media_center read facade inside media_center schema. This is not a public.* compatibility wrapper activation.';
comment on view media_center.v_content_items_admin_v1 is 'Admin read facade for future media_center runtime certification.';

commit;
