
-- DOCUMENT_CENTER_PUBLIC_WRAPPERS_APPLY_AND_RUNTIME_RETEST
-- ROLLBACK ONLY
--
-- Drops only the public wrappers created for /admin/documents.
-- Does not delete owner data.
-- Does not mutate platform_services/media_center.
-- Does not touch storage.objects.
-- Does not change RLS.

begin;

drop view if exists public.v_document_center_service_attachments_v1;
drop view if exists public.v_document_center_media_assets_v1;

commit;

select
  'document_center_public_wrappers_rollback_result' as section,
  to_regclass('public.v_document_center_service_attachments_v1') is null as service_attachments_wrapper_absent,
  to_regclass('public.v_document_center_media_assets_v1') is null as media_assets_wrapper_absent,
  false as production_approved;
