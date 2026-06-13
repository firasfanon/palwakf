
-- READ ONLY
-- Verify document center unification surfaces.

select
  'document_center_feature_expected_tables' as section,
  to_regclass('platform_services.service_request_attachments') as service_request_attachments,
  to_regclass('media_center.content_assets') as media_center_content_assets,
  to_regclass('platform_documents.document_types') as document_types,
  to_regclass('platform_documents.v_document_center_unified_v1') as unified_view;

select
  'document_center_storage_counts' as section,
  bucket_id,
  count(*)::bigint as object_count
from storage.objects
where bucket_id in ('media-gallery', 'document-intelligence')
group by bucket_id
order by bucket_id;
