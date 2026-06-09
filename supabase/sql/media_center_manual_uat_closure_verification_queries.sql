-- PalWakf — Media Center Manual Admin/Public UAT Closure Verification
-- Apply 20260507_media_center_manual_admin_public_uat_closure_v1.sql first.

select * from public.rpc_media_center_manual_uat_status_v1();

select * from public.rpc_media_center_readiness_v1();

select
  count(*) filter (where is_closed) as closed_stages,
  count(*) filter (where not is_closed) as open_stages,
  jsonb_agg(stage_key order by stage_key) filter (where not is_closed) as open_stage_keys
from public.rpc_media_center_readiness_v1();

select
  id,
  content_family,
  action_key,
  source_route,
  notes,
  metadata,
  created_at
from public.media_center_audit_events
where content_family = 'media_center'
  and action_key = 'manual_uat_closed'
order by created_at desc
limit 5;

select * from public.rpc_media_center_family_registry_v1();
