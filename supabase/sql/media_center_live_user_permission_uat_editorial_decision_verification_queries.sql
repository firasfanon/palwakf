-- Media Center — Live User Permission UAT + Editorial Decision Event Intake Verification
-- Apply after: 20260507_media_center_live_user_permission_uat_editorial_decision_intake_v1.sql

select *
from public.rpc_media_center_live_permission_editorial_decision_diagnostics_v1();

select *
from public.rpc_media_center_live_permission_editorial_decision_readiness_v1();

select *
from public.rpc_media_center_live_user_permission_uat_v1();

select *
from public.rpc_media_center_editorial_decision_events_summary_v1();

select *
from public.rpc_media_center_readiness_v1();

-- Example: run from an authenticated session for each real test user.
-- SQL Editor / postgres registrations are intentionally shown as non-live evidence and do not close UAT.
-- select public.rpc_media_center_record_permission_uat_event_v1(
--   p_scenario_key := 'viewer_read_dashboard',
--   p_notes := 'نتيجة اختبار مستخدم فعلي لصلاحية القراءة.',
--   p_metadata := jsonb_build_object('tester_note', 'replace-with-real-user-context')
-- );

-- Example: first real editorial decision event for a content record when available.
-- select public.rpc_media_center_record_editorial_event_v1(
--   p_content_family := 'news',
--   p_record_id := '<NEWS_UUID>'::uuid,
--   p_unit_slug := null,
--   p_from_status := 'in_review',
--   p_to_status := 'approved',
--   p_action_key := 'approved',
--   p_decision_label_ar := 'اعتماد خبر للنشر',
--   p_source_route := '/admin/media-center/news',
--   p_notes := 'اعتماد تحريري فعلي بعد مراجعة الملكية والمحتوى.',
--   p_metadata := jsonb_build_object('uat_key', 'first_real_editorial_decision')
-- );
