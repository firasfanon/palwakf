
-- FILE_CENTER_STORAGE_MAPPING_UNIT_AWARE_SCOPE_BEFORE_APPLY
-- ROLLBACK ONLY
--
-- Drops only the neutral storage registry wrapper/table.
-- Does not delete physical files.
-- Does not touch storage.objects.
-- Does not touch service attachments or media assets.
-- Does not change RLS.

begin;

drop view if exists public.v_document_center_storage_objects_v1;

drop table if exists platform_documents.file_object_registry;

commit;

select
  'file_center_unit_aware_storage_mapping_rollback_result' as section,
  to_regclass('platform_documents.file_object_registry') is null as file_object_registry_absent,
  to_regclass('public.v_document_center_storage_objects_v1') is null as storage_objects_wrapper_absent,
  false as production_approved;
