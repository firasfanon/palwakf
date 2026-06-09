-- PalWakf N2.27
-- Draft only. Do NOT run in production without approval.
-- Purpose: prepare media_center schema ownership surfaces.

create schema if not exists media_center;

comment on schema media_center is
  'PalWakf media center bounded domain: news, announcements, activities, gallery, breaking news, editorial workflow, governance/audit. Draft N2.27.';

create table if not exists media_center.migration_shadow_registry (
  id uuid primary key default gen_random_uuid(),
  source_schema text not null default 'public',
  source_table text not null,
  target_schema text not null default 'media_center',
  target_table text not null,
  migration_status text not null default 'planned',
  rls_policy_count integer,
  rls_migration_required boolean not null default true,
  rpc_wrapper_required boolean not null default true,
  flutter_migration_required boolean not null default true,
  workflow_migration_required boolean not null default true,
  notes text,
  created_at timestamptz not null default now()
);

insert into media_center.migration_shadow_registry
  (source_table, target_table, rls_policy_count, notes)
values
  ('activities', 'activities', 2, 'Media candidate: institutional activities'),
  ('announcement_items', 'announcement_items', 0, 'Manual review before move'),
  ('announcements', 'announcements', 2, 'Media candidate: announcements'),
  ('breaking_news', 'breaking_news', 5, 'Media candidate: breaking news'),
  ('media_center_audit_events', 'audit_events', 3, 'Media audit/governance'),
  ('media_center_editorial_events', 'editorial_events', 2, 'Media editorial workflow'),
  ('media_center_editorial_roles', 'editorial_roles', 2, 'Media editorial RBAC'),
  ('media_center_permission_uat_events', 'permission_uat_events', 2, 'May belong to governance evidence archive'),
  ('media_center_publishing_governance_rules', 'publishing_governance_rules', 2, 'Publishing governance'),
  ('media_gallery_items', 'gallery_items', 2, 'Media gallery'),
  ('news', 'news_legacy', 0, 'Manual review before move'),
  ('news_articles', 'news_articles', 3, 'Media candidate: articles'),
  ('news_items', 'news_items_legacy', 0, 'Manual review before move')
on conflict do nothing;
