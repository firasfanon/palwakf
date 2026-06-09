-- Database Wave B-1A Media Bootstrap Contract Approval
-- 05_media_center_bootstrap_schema_APPLY_CANDIDATE_NOT_RUN.sql
-- DO NOT RUN in this pack. This is an apply candidate for the next controlled schema apply pack.

DO $$
BEGIN
  RAISE EXCEPTION 'APPLY_CANDIDATE_NOT_RUN: convert this draft into an approved migration only in Database Wave B-1A Media Center Bootstrap Controlled Schema Apply Pack.';
END $$;

/*
-- APPLY CANDIDATE — NEXT PACK ONLY
-- Scope: empty media_center bootstrap contracts only. No import from public.*.

create schema if not exists media_center;

create table if not exists media_center.content_items (
  id uuid primary key default gen_random_uuid(),
  legacy_source_schema text,
  legacy_source_table text,
  legacy_source_id text,
  content_type text not null,
  title_ar text not null,
  title_en text,
  summary_ar text,
  summary_en text,
  body_ar text,
  body_en text,
  status text not null default 'draft',
  publication_channel text not null default 'public_site',
  published_at timestamptz,
  scheduled_at timestamptz,
  metadata jsonb not null default '{}'::jsonb,
  created_by uuid,
  updated_by uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint content_items_status_check check (status in ('draft','in_review','approved','scheduled','published','archived','rejected'))
);

create table if not exists media_center.content_assets (
  id uuid primary key default gen_random_uuid(),
  content_item_id uuid references media_center.content_items(id) on delete cascade,
  asset_type text not null,
  title_ar text,
  storage_path text,
  public_url text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists media_center.editorial_events (
  id uuid primary key default gen_random_uuid(),
  content_item_id uuid references media_center.content_items(id) on delete cascade,
  from_status text,
  action_key text not null,
  to_status text,
  actor_id uuid,
  note_ar text,
  created_at timestamptz not null default now()
);

create table if not exists media_center.content_publication_channels (
  channel_key text primary key,
  title_ar text not null,
  is_public boolean not null default true,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists media_center.content_category_map (
  id uuid primary key default gen_random_uuid(),
  source_table text,
  source_category text,
  target_content_type text not null,
  target_channel_key text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create or replace view media_center.v_content_items_public_v1 as
select
  id,
  content_type,
  title_ar,
  title_en,
  summary_ar,
  summary_en,
  body_ar,
  body_en,
  publication_channel,
  published_at,
  metadata
from media_center.content_items
where status = 'published'
  and published_at is not null
  and published_at <= now();

create or replace view media_center.v_content_items_admin_v1 as
select * from media_center.content_items;

alter table media_center.content_items enable row level security;
alter table media_center.content_assets enable row level security;
alter table media_center.editorial_events enable row level security;
alter table media_center.content_publication_channels enable row level security;
alter table media_center.content_category_map enable row level security;

-- Policies and grants must be reviewed against platform RBAC before apply.
*/
