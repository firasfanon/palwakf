
-- DRAFT ONLY - DO NOT APPLY WITHOUT EXPLICIT AUTHORIZATION
-- 03_DRAFT_public_read_wrapper_content_attachments.sql

create or replace view public.v_media_center_content_attachments_public_v1 as
select
  ca.id,
  ca.content_table,
  ca.content_id,
  ca.attachment_kind,
  ca.storage_bucket,
  ca.storage_path,
  ca.external_url,
  ca.title_ar,
  ca.title_en,
  ca.mime_type,
  ca.file_size_bytes,
  ca.display_order,
  ca.is_primary,
  ca.created_at,
  ca.updated_at
from media_center.content_attachments ca
where ca.status = 'published';

-- Grants must be reviewed and applied explicitly:
-- grant select on public.v_media_center_content_attachments_public_v1 to anon, authenticated;
