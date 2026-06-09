-- PalWakf — Media Center readiness verification
select * from public.rpc_media_center_family_registry_v1();
select * from public.rpc_media_center_readiness_v1();

select public.rpc_media_center_record_audit_event_v1(
  p_content_family := 'media_center',
  p_action_key := 'uat_navigation_verified',
  p_record_id := null,
  p_unit_slug := 'home',
  p_source_route := '/admin/media-center',
  p_notes := 'UAT navigation verification event',
  p_metadata := jsonb_build_object('uat', true, 'date', current_date)
);

select * from public.media_center_audit_events
order by created_at desc
limit 10;
