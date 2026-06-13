
-- DRAFT ONLY - DO NOT APPLY WITHOUT EXPLICIT AUTHORIZATION
-- Unified read view candidate.
--
-- Hotfix note:
-- The previous draft referenced ca.status, but the current
-- media_center.content_assets contract does not expose a status column.
-- This version is schema-safe for the known content_assets surface:
-- content_item_id, asset_type, url, storage_bucket, storage_path,
-- filename, mime_type, file_size_bytes, created_at.

create or replace view platform_documents.v_document_center_unified_v1 as
select
  'platform_services.service_request_attachments'::text as source_surface,
  sra.id,
  coalesce(sra.file_name, sra.attachment_key) as title,
  sra.mime_type,
  sra.file_size_bytes,
  sra.storage_bucket,
  sra.storage_path,
  sra.review_status as status,
  'platform_services'::text as source_system,
  sra.request_id::text as source_record_id,
  coalesce(sra.retention_class, 'operational') as retention_class,
  sra.uploaded_at as created_at
from platform_services.service_request_attachments sra

union all

select
  'media_center.content_assets'::text as source_surface,
  ca.id,
  coalesce(ca.filename, ca.url, ca.asset_type, 'أصل إعلامي') as title,
  ca.mime_type,
  ca.file_size_bytes,
  ca.storage_bucket,
  ca.storage_path,
  'active'::text as status,
  'media_center'::text as source_system,
  ca.content_item_id::text as source_record_id,
  'public_media'::text as retention_class,
  ca.created_at
from media_center.content_assets ca;
