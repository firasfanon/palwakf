
-- DOCUMENT_LIFECYCLE_VIEW_REPLACE_ORDER_HOTFIX
-- READ ONLY verification.

select
  'document_lifecycle_view_replace_presence' as section,
  to_regclass('platform_documents.document_types') as document_types_table,
  to_regclass('public.v_document_center_service_attachments_v1') as service_wrapper,
  to_regclass('public.v_document_center_media_assets_v1') as media_wrapper;

select
  'document_lifecycle_view_columns_service' as section,
  column_name,
  data_type,
  ordinal_position
from information_schema.columns
where table_schema = 'public'
  and table_name = 'v_document_center_service_attachments_v1'
order by ordinal_position;

select
  'document_lifecycle_view_columns_media' as section,
  column_name,
  data_type,
  ordinal_position
from information_schema.columns
where table_schema = 'public'
  and table_name = 'v_document_center_media_assets_v1'
order by ordinal_position;

select
  'document_lifecycle_classification_summary' as section,
  coalesce(dt.document_code, 'UNCLASSIFIED') as document_code,
  coalesce(sra.retention_class, 'UNCLASSIFIED') as retention_class,
  count(*)::bigint as row_count
from platform_services.service_request_attachments sra
left join platform_documents.document_types dt
  on dt.id = sra.document_type_id
group by coalesce(dt.document_code, 'UNCLASSIFIED'), coalesce(sra.retention_class, 'UNCLASSIFIED')
order by document_code, retention_class;

select
  'document_center_wrappers_counts' as section,
  'service_attachments' as wrapper,
  count(*)::bigint as row_count
from public.v_document_center_service_attachments_v1
union all
select
  'document_center_wrappers_counts',
  'media_assets',
  count(*)::bigint
from public.v_document_center_media_assets_v1;
