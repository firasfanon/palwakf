
-- READ ONLY
-- Existing document/file center inventory.

select
  'document_center_route_target_surfaces' as section,
  table_schema,
  table_name
from information_schema.tables
where (table_schema, table_name) in (
  ('platform_services', 'service_request_attachments'),
  ('media_center', 'content_assets'),
  ('media_center', 'content_items')
)
or table_schema in ('document_intelligence', 'documents')
order by table_schema, table_name;

select
  'service_request_attachments_columns' as section,
  column_name,
  data_type,
  is_nullable
from information_schema.columns
where table_schema = 'platform_services'
  and table_name = 'service_request_attachments'
order by ordinal_position;

select
  'media_center_content_assets_columns' as section,
  column_name,
  data_type,
  is_nullable
from information_schema.columns
where table_schema = 'media_center'
  and table_name = 'content_assets'
order by ordinal_position;

select
  'storage_object_counts_by_bucket' as section,
  bucket_id,
  count(*)::bigint as object_count
from storage.objects
where bucket_id in (
  'media-gallery',
  'document-intelligence',
  'services-requests',
  'service-requests',
  'complaint-attachments'
)
group by bucket_id
order by bucket_id;
