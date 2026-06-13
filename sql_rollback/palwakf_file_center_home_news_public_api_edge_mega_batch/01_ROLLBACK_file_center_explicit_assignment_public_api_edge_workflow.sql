
-- PALWAKF_FILE_CENTER_HOME_NEWS_PUBLIC_API_EDGE_MEGA_BATCH
-- ROLLBACK ONLY
--
-- Drops only workflow RPCs and mapping event table.
-- Does not delete file registry records.
-- Does not delete physical storage files.
-- Does not mutate storage.objects.
-- Does not touch media_center or platform_services owner rows.

begin;

drop function if exists public.rpc_file_object_assign_unit_scope_v1(
  uuid, uuid, text, uuid, text, text
);

drop function if exists public.rpc_file_object_mark_owner_mapping_v1(
  uuid, text, text, uuid, text, text
);

drop table if exists platform_documents.file_object_mapping_events;

commit;

select
  'file_center_explicit_unit_assignment_workflow_rollback_result' as section,
  to_regclass('platform_documents.file_object_mapping_events') is null as mapping_events_table_absent,
  to_regprocedure('public.rpc_file_object_assign_unit_scope_v1(uuid,uuid,text,uuid,text,text)') is null as assign_unit_rpc_absent,
  to_regprocedure('public.rpc_file_object_mark_owner_mapping_v1(uuid,text,text,uuid,text,text)') is null as mark_owner_mapping_rpc_absent,
  false as production_approved;
