-- GUARD: This script is a reviewed draft only. Do not run unless the operator explicitly approves Platform Navigation Owner Bootstrap apply.
-- It performs non-destructive CREATE SCHEMA / CREATE TABLE IF NOT EXISTS only. It does not touch public legacy rows.

create schema if not exists platform_navigation;

create table if not exists platform_navigation.route_entries (
  id uuid primary key default gen_random_uuid(),
  route_key text not null unique,
  route_path text not null,
  route_owner_schema text not null,
  route_owner_system text not null,
  route_family text not null,
  title_ar text not null,
  title_en text,
  description_ar text,
  icon_key text,
  is_active boolean not null default true,
  display_order integer,
  legacy_source text,
  legacy_id text,
  migration_batch text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists platform_navigation.service_entries (
  id uuid primary key default gen_random_uuid(),
  service_entry_key text not null unique,
  title_ar text not null,
  title_en text,
  description_ar text,
  description_en text,
  route_path text not null,
  icon_key text,
  category_key text,
  route_owner_class text not null default 'service_center_entry_route',
  is_active boolean not null default true,
  display_order integer,
  legacy_source text,
  legacy_id text,
  migration_batch text,
  raw_payload jsonb not null default '{}'::jsonb,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists platform_navigation.home_entries (
  id uuid primary key default gen_random_uuid(),
  home_entry_key text not null unique,
  title_ar text not null,
  title_en text,
  description_ar text,
  route_path text not null,
  icon_key text,
  section_key text,
  is_active boolean not null default true,
  display_order integer,
  legacy_source text,
  legacy_id text,
  migration_batch text,
  raw_payload jsonb not null default '{}'::jsonb,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists platform_navigation.navigation_events (
  id uuid primary key default gen_random_uuid(),
  event_key text not null,
  source_name text,
  target_name text,
  actor_label text,
  notes text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

select
  'platform_navigation_schema_bootstrap_guarded_not_run'::text as section,
  'DRAFT_ONLY_EXECUTE_ONLY_AFTER_EXPLICIT_OPERATOR_APPROVAL'::text as decision,
  false as destructive_sql_authorized,
  false as delete_authorized_by_this_script,
  false as public_legacy_mutation_authorized,
  false as production_approved;
