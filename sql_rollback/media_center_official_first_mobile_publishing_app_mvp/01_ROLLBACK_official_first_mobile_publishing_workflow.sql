
-- MEDIA_CENTER_OFFICIAL_FIRST_MOBILE_PUBLISHING_APP_MVP
-- ROLLBACK ONLY
--
-- Drops mobile publishing RPCs and audit table.
-- Does not delete content items created by the workflow.
-- Does not delete storage files.
-- Does not mutate storage.objects.
-- Does not remove public API-edge read views.

begin;

drop function if exists public.rpc_media_center_public_content_detail_v1(text, text);
drop function if exists public.rpc_media_center_mobile_publish_v1(uuid);
drop function if exists public.rpc_media_center_mobile_submit_for_review_v1(uuid);
drop function if exists public.rpc_media_center_mobile_create_draft_v1(
  text, text, text, text, uuid, text, text, text, text, bigint
);
drop function if exists public.rpc_media_center_official_path_v1(text, uuid);
drop function if exists public.rpc_media_center_mobile_actor_can_publish_v1();

drop table if exists media_center.mobile_publish_events;

commit;

select
  'media_center_official_first_mobile_publish_rollback_result' as section,
  to_regclass('media_center.mobile_publish_events') is null as mobile_publish_events_absent,
  to_regprocedure('public.rpc_media_center_mobile_create_draft_v1(text,text,text,text,uuid,text,text,text,text,bigint)') is null as create_draft_rpc_absent,
  false as production_approved;
