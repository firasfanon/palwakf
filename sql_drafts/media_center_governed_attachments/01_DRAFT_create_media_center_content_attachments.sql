
-- DRAFT ONLY - DO NOT APPLY WITHOUT EXPLICIT AUTHORIZATION
-- PALWAKF_MEDIA_CENTER_GOVERNED_ATTACHMENTS_AND_CMS_CONTRACTS_MEGA_BATCH
-- 01_DRAFT_create_media_center_content_attachments.sql

create table if not exists media_center.content_attachments (
  id uuid primary key default gen_random_uuid(),

  content_table text not null,
  content_id uuid not null,

  attachment_kind text not null
    check (attachment_kind in ('image', 'file', 'document', 'video', 'link')),

  storage_bucket text null,
  storage_path text null,
  external_url text null,

  title_ar text null,
  title_en text null,
  mime_type text null,
  file_size_bytes bigint null check (file_size_bytes is null or file_size_bytes >= 0),

  display_order integer not null default 0,
  is_primary boolean not null default false,

  status text not null default 'draft'
    check (status in ('draft', 'published', 'archived', 'deleted')),

  created_by uuid null references platform_access.admin_users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint content_attachments_target_table_check
    check (content_table in ('news_articles', 'announcements', 'activities', 'media_items')),

  constraint content_attachments_location_check
    check (
      (storage_bucket is not null and storage_path is not null and external_url is null)
      or
      (storage_bucket is null and storage_path is null and external_url is not null)
    )
);

create index if not exists idx_content_attachments_target
  on media_center.content_attachments(content_table, content_id);

create index if not exists idx_content_attachments_status
  on media_center.content_attachments(status);

create index if not exists idx_content_attachments_primary
  on media_center.content_attachments(content_table, content_id, is_primary)
  where is_primary = true and status <> 'deleted';

-- Optional stricter unique primary rule:
-- create unique index if not exists uq_content_attachments_one_primary_published
--   on media_center.content_attachments(content_table, content_id)
--   where is_primary = true and status in ('draft', 'published');
