
-- PALWAKF_FILE_CENTER_HOME_NEWS_PUBLIC_API_EDGE_MEGA_BATCH
-- READ ONLY verification.

select
  'public_schema_api_edge_contract' as section,
  true as public_schema_is_api_edge_only,
  false as public_base_table_creation_authorized,
  true as owner_schemas_source_of_truth,
  false as production_approved;

select
  'file_center_workflow_presence' as section,
  to_regclass('platform_documents.file_object_mapping_events') as mapping_events_table,
  to_regprocedure('public.rpc_file_object_assign_unit_scope_v1(uuid,uuid,text,uuid,text,text)') as assign_unit_rpc,
  to_regprocedure('public.rpc_file_object_mark_owner_mapping_v1(uuid,text,text,uuid,text,text)') as mark_owner_mapping_rpc,
  has_function_privilege(
    'authenticated',
    'public.rpc_file_object_assign_unit_scope_v1(uuid,uuid,text,uuid,text,text)',
    'execute'
  ) as authenticated_can_execute_assign_unit,
  has_function_privilege(
    'authenticated',
    'public.rpc_file_object_mark_owner_mapping_v1(uuid,text,text,uuid,text,text)',
    'execute'
  ) as authenticated_can_execute_mark_owner_mapping;

select
  'file_center_registry_unit_scope_summary' as section,
  storage_bucket,
  visibility_scope,
  unit_assignment_status,
  mapping_status,
  count(*)::bigint as row_count
from platform_documents.file_object_registry
group by storage_bucket, visibility_scope, unit_assignment_status, mapping_status
order by storage_bucket, visibility_scope, unit_assignment_status, mapping_status;

select
  'file_center_unit_scope_integrity' as section,
  count(*) filter (where owner_unit_id is not null and unit_assignment_status <> 'explicitly_assigned')::bigint as unit_without_explicit_assignment_count,
  count(*) filter (where visibility_scope = 'public' and mapping_status <> 'mapped_to_owner_record')::bigint as public_without_owner_mapping_count,
  count(*) filter (where unit_assignment_status = 'unassigned' and visibility_scope <> 'restricted')::bigint as unassigned_not_restricted_count
from platform_documents.file_object_registry;

select
  'home_news_api_edge_facade_presence' as section,
  to_regclass('public.v_media_news_compat_v1') is not null as news_facade_present,
  to_regclass('public.v_media_announcements_compat_v1') is not null as announcements_facade_present,
  to_regclass('public.v_media_activities_compat_v1') is not null as activities_facade_present,
  to_regclass('public.v_document_center_storage_objects_v1') is not null as storage_objects_facade_present;
