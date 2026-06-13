
-- DRAFT ONLY - DO NOT APPLY WITHOUT EXPLICIT AUTHORIZATION
-- Public wrapper views for /admin/documents.
--
-- Purpose:
-- Flutter must not query non-exposed owner schemas directly.
-- These wrappers provide safe PostgREST-accessible read surfaces.

create or replace view public.v_document_center_service_attachments_v1 as
select
  sra.id,
  coalesce(sra.file_name, sra.attachment_key) as title,
  sra.request_id,
  sra.attachment_key,
  sra.file_name,
  sra.mime_type,
  sra.file_size_bytes,
  sra.storage_bucket,
  sra.storage_path,
  sra.document_job_id,
  sra.review_status,
  sra.uploaded_by,
  sra.uploaded_at,
  coalesce(sra.retention_class, 'operational') as retention_class
from platform_services.service_request_attachments sra
where coalesce(sra.lifecycle_status, 'active') <> 'deleted';

create or replace view public.v_document_center_media_assets_v1 as
select
  ca.id,
  coalesce(ca.filename, ca.url, ca.asset_type, 'أصل إعلامي') as title,
  ca.content_item_id,
  ca.asset_type,
  ca.url,
  ca.storage_bucket,
  ca.storage_path,
  ca.filename,
  ca.mime_type,
  ca.file_size_bytes,
  'active'::text as status,
  'public_media'::text as retention_class,
  ca.created_at
from media_center.content_assets ca;

-- Grants are intentionally left as explicit apply decisions:
-- grant select on public.v_document_center_service_attachments_v1 to authenticated;
-- grant select on public.v_document_center_media_assets_v1 to authenticated;
