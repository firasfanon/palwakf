-- Database Wave B-1A Media Bootstrap Draft Pack
-- 05_media_center_bootstrap_schema_DRAFT_NOT_RUN.sql
-- DO NOT RUN. This file is a guarded design draft, not an apply script.

DO $$
BEGIN
  RAISE EXCEPTION 'DRAFT_NOT_RUN: review and approve media_center bootstrap contract before converting this file into an apply migration.';
END $$;

/*
-- DRAFT ONLY — not executable in this pack.

create schema if not exists media_center;

create table media_center.content_items (
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
  publication_channel text default 'public_site',
  published_at timestamptz,
  scheduled_at timestamptz,
  metadata jsonb not null default '{}'::jsonb,
  created_by uuid,
  updated_by uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table media_center.content_assets (
  id uuid primary key default gen_random_uuid(),
  content_item_id uuid references media_center.content_items(id) on delete cascade,
  asset_type text not null,
  title_ar text,
  storage_path text,
  public_url text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table media_center.editorial_events (
  id uuid primary key default gen_random_uuid(),
  content_item_id uuid references media_center.content_items(id) on delete cascade,
  from_status text,
  action_key text not null,
  to_status text,
  actor_id uuid,
  note_ar text,
  created_at timestamptz not null default now()
);

-- RLS, policies, RPC wrappers, and compatibility views require a separate approved apply batch.
*/
