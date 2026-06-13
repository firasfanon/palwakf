
-- DOCUMENT_LIFECYCLE_POLICY_REGISTRY_APPLY_AND_ATTACHMENT_CLASSIFICATION
-- READ ONLY verification.

select
  'document_lifecycle_registry_presence' as section,
  to_regclass('platform_documents.document_types') as document_types_table,
  count(*)::bigint as document_type_count
from platform_documents.document_types;

select
  'document_lifecycle_document_types' as section,
  system_key,
  document_code,
  name_ar,
  retention_class,
  confidentiality_level,
  retention_months,
  allow_delete,
  requires_review,
  requires_ocr,
  requires_signature,
  requires_versioning,
  is_legal_evidence,
  is_public_publishable,
  active
from platform_documents.document_types
order by system_key, document_code;

select
  'service_attachment_lifecycle_columns' as section,
  column_name,
  data_type,
  is_nullable
from information_schema.columns
where table_schema = 'platform_services'
  and table_name = 'service_request_attachments'
  and column_name in (
    'document_type_id',
    'retention_class',
    'retention_until',
    'legal_hold',
    'lifecycle_status',
    'confidentiality_level',
    'checksum_sha256',
    'is_original',
    'derived_from_attachment_id',
    'archived_at',
    'deleted_at'
  )
order by ordinal_position;

select
  'service_attachment_classification_summary' as section,
  coalesce(dt.document_code, 'UNCLASSIFIED') as document_code,
  coalesce(sra.retention_class, 'UNCLASSIFIED') as retention_class,
  count(*)::bigint as row_count
from platform_services.service_request_attachments sra
left join platform_documents.document_types dt
  on dt.id = sra.document_type_id
group by coalesce(dt.document_code, 'UNCLASSIFIED'), coalesce(sra.retention_class, 'UNCLASSIFIED')
order by document_code, retention_class;

select
  'document_center_wrappers_lifecycle_counts' as section,
  'service_attachments' as wrapper,
  count(*)::bigint as row_count
from public.v_document_center_service_attachments_v1
union all
select
  'document_center_wrappers_lifecycle_counts',
  'media_assets',
  count(*)::bigint
from public.v_document_center_media_assets_v1;

select
  'document_center_storage_counts' as section,
  bucket_id,
  count(*)::bigint as object_count
from storage.objects
where bucket_id in ('media-gallery', 'document-intelligence')
group by bucket_id
order by bucket_id;
