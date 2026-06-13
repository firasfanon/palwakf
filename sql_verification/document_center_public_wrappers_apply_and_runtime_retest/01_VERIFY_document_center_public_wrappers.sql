
-- DOCUMENT_CENTER_PUBLIC_WRAPPERS_APPLY_AND_RUNTIME_RETEST
-- READ ONLY verification after wrapper apply.

select
  'document_center_public_wrappers_presence' as section,
  to_regclass('public.v_document_center_service_attachments_v1') as service_attachments_wrapper,
  to_regclass('public.v_document_center_media_assets_v1') as media_assets_wrapper,
  has_table_privilege('authenticated', 'public.v_document_center_service_attachments_v1', 'select') as service_attachments_authenticated_select,
  has_table_privilege('authenticated', 'public.v_document_center_media_assets_v1', 'select') as media_assets_authenticated_select;

select
  'document_center_service_attachments_sample' as section,
  count(*)::bigint as row_count
from public.v_document_center_service_attachments_v1;

select
  'document_center_media_assets_sample' as section,
  count(*)::bigint as row_count
from public.v_document_center_media_assets_v1;

select
  'document_center_storage_counts' as section,
  bucket_id,
  count(*)::bigint as object_count
from storage.objects
where bucket_id in ('media-gallery', 'document-intelligence')
group by bucket_id
order by bucket_id;
