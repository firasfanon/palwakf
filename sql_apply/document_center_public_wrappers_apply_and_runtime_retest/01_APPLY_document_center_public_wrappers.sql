
-- DOCUMENT_CENTER_PUBLIC_WRAPPERS_APPLY_AND_RUNTIME_RETEST
-- AUTHORIZED APPLY CANDIDATE
--
-- Purpose:
-- Expose safe public wrapper views for /admin/documents without exposing owner schemas.
--
-- Owner schemas stay private:
-- - platform_services
-- - media_center
--
-- Public wrappers:
-- - public.v_document_center_service_attachments_v1
-- - public.v_document_center_media_assets_v1
--
-- No RLS mutation.
-- No data mutation.
-- No service_role usage.
-- No production approval.

begin;

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
  'operational'::text as retention_class
from platform_services.service_request_attachments sra;

comment on view public.v_document_center_service_attachments_v1 is
  'PalWakf Document Center safe wrapper for service request attachments. Owner schema platform_services remains private.';

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

comment on view public.v_document_center_media_assets_v1 is
  'PalWakf Document Center safe wrapper for media center content assets. Owner schema media_center remains private.';

grant select on public.v_document_center_service_attachments_v1 to authenticated;
grant select on public.v_document_center_media_assets_v1 to authenticated;

commit;

select
  'document_center_public_wrappers_apply_result' as section,
  to_regclass('public.v_document_center_service_attachments_v1') is not null as service_attachments_wrapper_present,
  to_regclass('public.v_document_center_media_assets_v1') is not null as media_assets_wrapper_present,
  has_table_privilege('authenticated', 'public.v_document_center_service_attachments_v1', 'select') as service_attachments_authenticated_select,
  has_table_privilege('authenticated', 'public.v_document_center_media_assets_v1', 'select') as media_assets_authenticated_select,
  false as production_approved;
