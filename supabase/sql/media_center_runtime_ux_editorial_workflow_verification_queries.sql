-- Media Center Runtime UX + Editorial Workflow Verification

select * from public.rpc_media_center_editorial_workflow_v1();
select * from public.rpc_media_center_runtime_ux_checks_v1();
select * from public.rpc_media_center_family_registry_v1();
select * from public.rpc_media_center_readiness_v1();

select
  count(*) filter (where is_closed) as closed_runtime_checks,
  count(*) filter (where not is_closed) as open_runtime_checks,
  jsonb_agg(check_key order by check_key) filter (where not is_closed) as open_check_keys
from public.rpc_media_center_runtime_ux_checks_v1();

select public.rpc_media_center_record_editorial_event_v1(
  p_content_family := 'media_center',
  p_record_id := null,
  p_unit_slug := null,
  p_from_status := 'approved',
  p_to_status := 'published',
  p_action_key := 'workflow_hardening_verified',
  p_decision_label_ar := 'تحقق من سير التحرير',
  p_source_route := '/admin/media-center',
  p_notes := 'اختبار دالة تسجيل القرار التحريري بعد دفعة Runtime UX Polishing + Editorial Workflow Hardening.',
  p_metadata := jsonb_build_object(
    'verification_key', 'media_center_editorial_workflow_hardening_2026_05_07',
    'result', 'passed',
    'verified_at', now()
  )
) as editorial_event_id;

select
  id,
  content_family,
  action_key,
  from_status,
  to_status,
  decision_label_ar,
  created_at
from public.media_center_editorial_events
order by created_at desc
limit 20;
