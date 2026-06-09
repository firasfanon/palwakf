-- Database Ownership Phase B — Media Center Mega Closure Pack
-- 02 — One-shot controlled apply. GUARDED.
-- This script intentionally preserves legacy public tables and does not perform any DROP/DELETE/ARCHIVE.
-- It may CREATE/ALTER media_center-owned contracts and public compatibility views only after explicit token.

begin;

-- 0) Explicit operator gate. This must be set in the same transaction/session before running:
-- set local request.palwakf_phase_b_media_mega_apply_token = 'PALWAKF_PHASE_B_MEDIA_MEGA_APPLY_APPROVED_2026_05_28';
do $$
begin
  if coalesce(current_setting('request.palwakf_phase_b_media_mega_apply_token', true), '')
     <> 'PALWAKF_PHASE_B_MEDIA_MEGA_APPLY_APPROVED_2026_05_28' then
    raise exception 'BLOCKED: Phase B Media Mega Apply requires explicit token, backup/restore point, master census review, and operator approval.';
  end if;
end $$;

-- 1) Owner schema and canonical contracts.
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

create unique index if not exists ux_media_content_items_legacy_source_id
  on media_center.content_items (legacy_source, legacy_source_id)
  where legacy_source is not null and legacy_source_id is not null;
create index if not exists idx_media_content_items_status on media_center.content_items(status);
create index if not exists idx_media_content_items_type_status on media_center.content_items(content_type, status);
create index if not exists idx_media_content_items_published_at on media_center.content_items(published_at desc);
create index if not exists idx_media_content_items_unit_slug on media_center.content_items(unit_slug);
create index if not exists idx_media_content_assets_item on media_center.content_assets(content_item_id);
create index if not exists idx_media_editorial_events_item_created on media_center.editorial_events(content_item_id, created_at desc);

alter table media_center.content_items enable row level security;
alter table media_center.content_assets enable row level security;
alter table media_center.editorial_events enable row level security;

do $$
begin
  if not exists (select 1 from pg_policies where schemaname='media_center' and tablename='content_items' and policyname='media_content_items_published_public_read') then
    create policy media_content_items_published_public_read
      on media_center.content_items
      for select
      to anon, authenticated
      using (status = 'published' and visibility_scope = 'public' and (published_at is null or published_at <= now()));
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
end $$;

-- 2) Owner-schema public view.
create or replace view media_center.v_content_items_public_v1 as
select
  ci.id,
  ci.legacy_source,
  ci.legacy_source_id,
  ci.content_key,
  ci.content_type,
  ci.title_ar,
  ci.title_en,
  ci.summary_ar,
  ci.summary_en,
  ci.body_ar,
  ci.body_en,
  ci.category_key,
  ci.unit_slug,
  ci.status,
  ci.visibility_scope,
  ci.published_at,
  ci.metadata,
  ci.created_at,
  ci.updated_at
from media_center.content_items ci
where ci.status = 'published'
  and ci.visibility_scope = 'public'
  and (ci.published_at is null or ci.published_at <= now());

-- 3) Idempotent legacy source seed. Legacy public tables are PRESERVED.
-- These statements are intentionally written as INSERT-only with conflict protection.
insert into media_center.content_items (
  legacy_source, legacy_source_id, content_key, content_type,
  title_ar, title_en, summary_ar, summary_en, body_ar, body_en,
  category_key, status, visibility_scope, unit_id, unit_slug, source_public_table, published_at, metadata
)
select
  'public.news_articles',
  coalesce(j->>'id', j->>'uuid', md5(j::text)),
  'legacy_news_articles_' || coalesce(j->>'id', j->>'uuid', md5(j::text)),
  'news',
  coalesce(nullif(j->>'title_ar',''), nullif(j->>'title',''), nullif(j->>'headline_ar',''), nullif(j->>'name_ar',''), 'بدون عنوان'),
  nullif(coalesce(j->>'title_en', j->>'headline_en', j->>'name_en'), ''),
  nullif(coalesce(j->>'summary_ar', j->>'excerpt_ar', j->>'description_ar', j->>'summary', j->>'excerpt'), ''),
  nullif(coalesce(j->>'summary_en', j->>'excerpt_en', j->>'description_en'), ''),
  nullif(coalesce(j->>'body_ar', j->>'content_ar', j->>'body', j->>'content', j->>'description'), ''),
  nullif(coalesce(j->>'body_en', j->>'content_en'), ''),
  nullif(coalesce(j->>'category_key', j->>'category', j->>'type'), ''),
  case when lower(coalesce(j->>'status', j->>'publish_status', '')) in ('published','active','approved')
      or lower(coalesce(j->>'is_published', j->>'published', j->>'is_active', j->>'active', '')) in ('true','t','1','yes')
    then 'published' else 'draft' end,
  'public',
  nullif(j->>'unit_id','')::uuid,
  lower(nullif(j->>'unit_slug','')),
  'public.news_articles',
  case when nullif(coalesce(j->>'published_at', j->>'publish_date', j->>'created_at'), '') ~ '^\d{4}-\d{2}-\d{2}'
    then nullif(coalesce(j->>'published_at', j->>'publish_date', j->>'created_at'), '')::timestamptz else null end,
  jsonb_build_object('legacy_payload', j, 'controlled_seed_batch', 'phase_b_media_mega_closure', 'seed_scope', 'news_articles')
from (select to_jsonb(s) as j from public.news_articles s) q
where to_regclass('public.news_articles') is not null
on conflict (legacy_source, legacy_source_id) where legacy_source is not null and legacy_source_id is not null do nothing;

insert into media_center.content_items (
  legacy_source, legacy_source_id, content_key, content_type,
  title_ar, title_en, summary_ar, summary_en, body_ar, body_en,
  category_key, status, visibility_scope, unit_id, unit_slug, source_public_table, published_at, metadata
)
select
  'public.announcements',
  coalesce(j->>'id', j->>'uuid', md5(j::text)),
  'legacy_announcements_' || coalesce(j->>'id', j->>'uuid', md5(j::text)),
  'announcement',
  coalesce(nullif(j->>'title_ar',''), nullif(j->>'title',''), nullif(j->>'name_ar',''), 'بدون عنوان'),
  nullif(coalesce(j->>'title_en', j->>'name_en'), ''),
  nullif(coalesce(j->>'summary_ar', j->>'description_ar', j->>'summary', j->>'description'), ''),
  nullif(coalesce(j->>'summary_en', j->>'description_en'), ''),
  nullif(coalesce(j->>'body_ar', j->>'content_ar', j->>'body', j->>'content', j->>'description'), ''),
  nullif(coalesce(j->>'body_en', j->>'content_en'), ''),
  coalesce(nullif(j->>'category_key',''), nullif(j->>'category',''), 'announcement'),
  case when lower(coalesce(j->>'status', j->>'publish_status', '')) in ('published','active','approved')
      or lower(coalesce(j->>'is_published', j->>'published', j->>'is_active', j->>'active', '')) in ('true','t','1','yes')
    then 'published' else 'draft' end,
  'public',
  nullif(j->>'unit_id','')::uuid,
  lower(nullif(j->>'unit_slug','')),
  'public.announcements',
  case when nullif(coalesce(j->>'published_at', j->>'publish_date', j->>'created_at'), '') ~ '^\d{4}-\d{2}-\d{2}'
    then nullif(coalesce(j->>'published_at', j->>'publish_date', j->>'created_at'), '')::timestamptz else null end,
  jsonb_build_object('legacy_payload', j, 'controlled_seed_batch', 'phase_b_media_mega_closure', 'seed_scope', 'announcements')
from (select to_jsonb(s) as j from public.announcements s) q
where to_regclass('public.announcements') is not null
on conflict (legacy_source, legacy_source_id) where legacy_source is not null and legacy_source_id is not null do nothing;

insert into media_center.content_items (
  legacy_source, legacy_source_id, content_key, content_type,
  title_ar, title_en, summary_ar, summary_en, body_ar, body_en,
  category_key, status, visibility_scope, unit_id, unit_slug, source_public_table, published_at, metadata
)
select
  'public.activities',
  coalesce(j->>'id', j->>'uuid', md5(j::text)),
  'legacy_activities_' || coalesce(j->>'id', j->>'uuid', md5(j::text)),
  'activity',
  coalesce(nullif(j->>'title_ar',''), nullif(j->>'title',''), nullif(j->>'name_ar',''), 'بدون عنوان'),
  nullif(coalesce(j->>'title_en', j->>'name_en'), ''),
  nullif(coalesce(j->>'summary_ar', j->>'description_ar', j->>'summary', j->>'description'), ''),
  nullif(coalesce(j->>'summary_en', j->>'description_en'), ''),
  nullif(coalesce(j->>'body_ar', j->>'content_ar', j->>'body', j->>'content', j->>'description'), ''),
  nullif(coalesce(j->>'body_en', j->>'content_en'), ''),
  coalesce(nullif(j->>'category_key',''), nullif(j->>'category',''), 'activity'),
  case when lower(coalesce(j->>'status', j->>'publish_status', '')) in ('published','active','approved')
      or lower(coalesce(j->>'is_published', j->>'published', j->>'is_active', j->>'active', '')) in ('true','t','1','yes')
    then 'published' else 'draft' end,
  'public',
  nullif(j->>'unit_id','')::uuid,
  lower(nullif(j->>'unit_slug','')),
  'public.activities',
  case when nullif(coalesce(j->>'published_at', j->>'event_date', j->>'created_at'), '') ~ '^\d{4}-\d{2}-\d{2}'
    then nullif(coalesce(j->>'published_at', j->>'event_date', j->>'created_at'), '')::timestamptz else null end,
  jsonb_build_object('legacy_payload', j, 'controlled_seed_batch', 'phase_b_media_mega_closure', 'seed_scope', 'activities')
from (select to_jsonb(s) as j from public.activities s) q
where to_regclass('public.activities') is not null
on conflict (legacy_source, legacy_source_id) where legacy_source is not null and legacy_source_id is not null do nothing;

-- 4) Editorial trace for seeded rows.
insert into media_center.editorial_events (content_item_id, from_state, to_state, action_key, actor_scope, note_ar, metadata)
select
  ci.id,
  null,
  ci.status,
  'controlled_legacy_seed_phase_b_media_mega',
  'system_seed',
  'تهيئة محكومة من جداول الإعلام العامة القديمة بدون حذف المصدر.',
  jsonb_build_object('legacy_source', ci.legacy_source, 'legacy_source_id', ci.legacy_source_id, 'controlled_seed_batch', 'phase_b_media_mega_closure')
from media_center.content_items ci
where ci.legacy_source in ('public.news_articles','public.activities','public.announcements')
  and not exists (
    select 1 from media_center.editorial_events ee
    where ee.content_item_id = ci.id
      and ee.action_key = 'controlled_legacy_seed_phase_b_media_mega'
  );

-- 5) Public compatibility views. Public remains an API surface; no legacy table is replaced or dropped.
create or replace view public.v_media_content_compat_v1 as
select
  ci.id,
  ci.legacy_source,
  ci.legacy_source_id,
  ci.content_key,
  ci.content_type,
  ci.title_ar,
  ci.title_en,
  ci.summary_ar,
  ci.summary_en,
  ci.body_ar,
  ci.body_en,
  ci.category_key,
  ci.unit_slug,
  ci.published_at,
  ci.metadata,
  ci.created_at,
  ci.updated_at
from media_center.v_content_items_public_v1 ci;

create or replace view public.v_media_news_compat_v1 as
select * from public.v_media_content_compat_v1 where content_type = 'news';

create or replace view public.v_media_announcements_compat_v1 as
select * from public.v_media_content_compat_v1 where content_type = 'announcement';

create or replace view public.v_media_activities_compat_v1 as
select * from public.v_media_content_compat_v1 where content_type = 'activity';

comment on view public.v_media_content_compat_v1 is 'Phase B Media Mega Closure: public compatibility facade backed by media_center; legacy public media tables preserved.';
comment on view public.v_media_news_compat_v1 is 'Phase B Media Mega Closure: news public compatibility facade backed by media_center.content_items.';
comment on view public.v_media_announcements_compat_v1 is 'Phase B Media Mega Closure: announcements public compatibility facade backed by media_center.content_items.';
comment on view public.v_media_activities_compat_v1 is 'Phase B Media Mega Closure: activities public compatibility facade backed by media_center.content_items.';

commit;
