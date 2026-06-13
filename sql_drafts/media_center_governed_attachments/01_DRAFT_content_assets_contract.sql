
-- DRAFT ONLY - DO NOT APPLY
-- Proposed governed attachment registry under media_center.
-- This draft intentionally avoids modifying public legacy tables.

create table if not exists media_center.content_assets (
  id uuid primary key default gen_random_uuid(),
  content_type text not null check (content_type in ('news', 'announcement', 'activity', 'event')),
  content_id text not null,
  unit_id uuid null,
  storage_bucket text not null default 'media-center',
  storage_path text not null,
  file_name text not null,
  mime_type text null,
  file_size_bytes bigint null check (file_size_bytes is null or file_size_bytes >= 0),
  checksum_sha256 text null,
  status text not null default 'active' check (status in ('active', 'archived', 'deleted')),
  uploaded_by uuid null references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_content_assets_content
  on media_center.content_assets (content_type, content_id);

create index if not exists idx_content_assets_unit
  on media_center.content_assets (unit_id);

create index if not exists idx_content_assets_status
  on media_center.content_assets (status);
