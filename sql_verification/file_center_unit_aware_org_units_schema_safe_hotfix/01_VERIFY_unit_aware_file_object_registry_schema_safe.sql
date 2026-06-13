
-- FILE_CENTER_UNIT_AWARE_ORG_UNITS_SCHEMA_SAFE_HOTFIX
-- READ ONLY verification.

select
  'file_center_unit_aware_registry_presence' as section,
  to_regclass('platform_documents.file_object_registry') as file_object_registry,
  to_regclass('public.v_document_center_storage_objects_v1') as storage_objects_wrapper,
  has_table_privilege('authenticated', 'public.v_document_center_storage_objects_v1', 'select') as authenticated_select;

select
  'file_center_unit_assignment_summary' as section,
  storage_bucket,
  source_system,
  retention_class,
  confidentiality_level,
  visibility_scope,
  unit_assignment_status,
  mapping_status,
  count(*)::bigint as row_count
from platform_documents.file_object_registry
group by
  storage_bucket,
  source_system,
  retention_class,
  confidentiality_level,
  visibility_scope,
  unit_assignment_status,
  mapping_status
order by storage_bucket, source_system, unit_assignment_status, visibility_scope;

select
  'file_center_unit_scope_integrity' as section,
  count(*) filter (where owner_unit_id is not null and unit_assignment_status <> 'explicitly_assigned')::bigint as unit_without_explicit_assignment_count,
  count(*) filter (where visibility_scope = 'public' and mapping_status <> 'mapped_to_owner_record')::bigint as public_without_owner_mapping_count,
  count(*) filter (where unit_assignment_status = 'unassigned' and visibility_scope <> 'restricted')::bigint as unassigned_not_restricted_count,
  count(*) filter (where scope_type in ('unit','service_request','media_content','waqf_asset','case','document_job') and scope_id is null and owner_unit_id is null)::bigint as scoped_without_scope_or_unit_count
from platform_documents.file_object_registry;

select
  'file_center_storage_vs_registry_match' as section,
  o.bucket_id,
  count(o.id)::bigint as storage_object_count,
  count(r.id)::bigint as registry_match_count
from storage.objects o
left join platform_documents.file_object_registry r
  on r.storage_bucket = o.bucket_id
 and r.storage_path = o.name
where o.bucket_id in ('media-gallery', 'document-intelligence')
group by o.bucket_id
order by o.bucket_id;

select
  'document_center_storage_objects_wrapper_sample' as section,
  id,
  storage_bucket,
  storage_path,
  source_system,
  retention_class,
  confidentiality_level,
  visibility_scope,
  unit_assignment_status,
  owner_unit_id,
  owner_unit_name_ar,
  owner_unit_slug,
  owner_unit_type,
  scope_type,
  mapping_status,
  created_at
from public.v_document_center_storage_objects_v1
order by storage_bucket, created_at
limit 25;
