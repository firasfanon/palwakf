
-- PALWAKF_FILE_CENTER_HOME_NEWS_PUBLIC_API_EDGE_MEGA_BATCH
-- READ ONLY diagnostics.

select
  'public_schema_api_edge_policy' as section,
  true as public_schema_is_api_edge_only,
  false as public_base_table_creation_authorized,
  false as owner_truth_migration_to_public_authorized,
  true as public_views_rpc_allowed_as_transitional_api_facade,
  false as production_approved;

select
  'file_center_registry_current_status' as section,
  to_regclass('platform_documents.file_object_registry') is not null as file_object_registry_present,
  to_regclass('public.v_document_center_storage_objects_v1') is not null as storage_objects_wrapper_present,
  (select count(*)::bigint from platform_documents.file_object_registry) as registry_row_count,
  (select count(*)::bigint from platform_documents.file_object_registry where unit_assignment_status = 'unassigned') as unassigned_count,
  (select count(*)::bigint from platform_documents.file_object_registry where visibility_scope = 'restricted') as restricted_count;

select
  'file_center_explicit_mapping_integrity' as section,
  count(*) filter (where owner_unit_id is not null and unit_assignment_status <> 'explicitly_assigned')::bigint as unit_without_explicit_assignment_count,
  count(*) filter (where visibility_scope = 'public' and mapping_status <> 'mapped_to_owner_record')::bigint as public_without_owner_mapping_count,
  count(*) filter (where unit_assignment_status = 'unassigned' and visibility_scope <> 'restricted')::bigint as unassigned_not_restricted_count
from platform_documents.file_object_registry;

select
  'media_public_api_edge_facades' as section,
  to_regclass('public.v_media_news_compat_v1') is not null as news_api_edge_present,
  to_regclass('public.v_media_announcements_compat_v1') is not null as announcements_api_edge_present,
  to_regclass('public.v_media_activities_compat_v1') is not null as activities_api_edge_present,
  to_regclass('public.v_document_center_storage_objects_v1') is not null as storage_objects_api_edge_present;

select
  'public_base_table_inventory_warning' as section,
  c.relname as public_base_table,
  false as create_public_base_table_authorized,
  false as production_approved
from pg_class c
join pg_namespace n
  on n.oid = c.relnamespace
where n.nspname = 'public'
  and c.relkind = 'r'
order by c.relname;
