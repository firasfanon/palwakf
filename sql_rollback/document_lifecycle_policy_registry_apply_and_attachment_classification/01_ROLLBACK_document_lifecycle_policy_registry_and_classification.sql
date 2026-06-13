
-- DOCUMENT_LIFECYCLE_POLICY_REGISTRY_APPLY_AND_ATTACHMENT_CLASSIFICATION
-- ROLLBACK ONLY
--
-- Conservative rollback:
-- - Reverts public wrappers to pre-lifecycle simple projection.
-- - Removes lifecycle metadata columns from platform_services.service_request_attachments.
-- - Drops platform_documents.document_types and platform_documents schema if empty.
--
-- Does not delete uploaded files.
-- Does not touch storage.objects.
-- Does not mutate media_center.content_assets.

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

alter table platform_services.service_request_attachments
  drop column if exists deleted_at,
  drop column if exists archived_at,
  drop column if exists derived_from_attachment_id,
  drop column if exists is_original,
  drop column if exists checksum_sha256,
  drop column if exists confidentiality_level,
  drop column if exists lifecycle_status,
  drop column if exists legal_hold,
  drop column if exists retention_until,
  drop column if exists retention_class,
  drop column if exists document_type_id;

drop table if exists platform_documents.document_types;

drop schema if exists platform_documents;

commit;

select
  'document_lifecycle_rollback_result' as section,
  to_regclass('platform_documents.document_types') is null as document_types_table_absent,
  to_regclass('public.v_document_center_service_attachments_v1') is not null as service_wrapper_preserved,
  to_regclass('public.v_document_center_media_assets_v1') is not null as media_wrapper_preserved,
  false as production_approved;
