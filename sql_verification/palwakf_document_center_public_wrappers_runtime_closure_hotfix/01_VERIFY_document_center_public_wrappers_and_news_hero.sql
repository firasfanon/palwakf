
-- READ ONLY
-- Verify document center public wrapper readiness.

select
  'document_center_public_wrappers' as section,
  to_regclass('public.v_document_center_service_attachments_v1') as service_attachments_wrapper,
  to_regclass('public.v_document_center_media_assets_v1') as media_assets_wrapper;

select
  'storage_object_counts_by_bucket' as section,
  bucket_id,
  count(*)::bigint as object_count
from storage.objects
where bucket_id in ('media-gallery', 'document-intelligence')
group by bucket_id
order by bucket_id;
