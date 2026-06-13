begin;

create or replace function public.rpc_platform_technical_services_dashboard_v1()
returns jsonb
language plpgsql
stable
security definer
set search_path = public, platform_technical, auth
as $$
declare v_result jsonb;
begin
  perform platform_technical.assert_platform_technical_admin_v1();

  select jsonb_build_object(
    'backend_applied', true,
    'backend_status', 'platform-technical-backend-contract-active',
    'metrics', jsonb_build_array(
      jsonb_build_object('key','requests','label','الطلبات التقنية','value',(select count(*)::text from platform_technical.technical_service_requests),'status','ready'),
      jsonb_build_object('key','maintenance','label','نوافذ الصيانة','value',(select count(*)::text from platform_technical.maintenance_windows),'status','ready'),
      jsonb_build_object('key','health','label','Health Checks','value',(select count(*)::text from platform_technical.health_checks),'status','ready'),
      jsonb_build_object('key','audit','label','Audit Events','value',(select count(*)::text from platform_technical.audit_events),'status','ready'),
      jsonb_build_object('key','evidence','label','Evidence','value',(select count(*)::text from platform_technical.technical_service_evidence),'status','ready'),
      jsonb_build_object('key','notifications','label','Notifications','value',(select count(*)::text from platform_technical.technical_notifications where is_read = false and (target_user_id is null or target_user_id = auth.uid())),'status','ready')
    ),
    'requests', coalesce((select jsonb_agg(to_jsonb(x) order by x.created_at desc) from (
      select id, service_type, action_type, title, description, status, approval_status, risk_level, requested_at as created_at, scheduled_for
      from platform_technical.technical_service_requests order by requested_at desc limit 20
    ) x), '[]'::jsonb),
    'maintenance_windows', coalesce((select jsonb_agg(to_jsonb(x) order by x.starts_at desc) from (
      select id, title, message_ar, starts_at, ends_at, affected_surfaces, status, created_at
      from platform_technical.maintenance_windows order by starts_at desc limit 20
    ) x), '[]'::jsonb),
    'backups', coalesce((select jsonb_agg(to_jsonb(x) order by x.created_at desc) from (
      select id, backup_kind, provider, backup_label, status, completed_at, checksum, created_at
      from platform_technical.backup_registry order by created_at desc limit 20
    ) x), '[]'::jsonb),
    'health_checks', coalesce((select jsonb_agg(to_jsonb(x) order by x.check_group, x.check_key) from (
      select check_key, check_group, label, status, details, last_checked_at, created_at
      from platform_technical.health_checks order by check_group, check_key
    ) x), '[]'::jsonb),
    'releases', coalesce((select jsonb_agg(to_jsonb(x) order by x.created_at desc) from (
      select id, release_tag, git_commit_hash, deploy_url, status, created_at
      from platform_technical.release_records order by created_at desc limit 20
    ) x), '[]'::jsonb),
    'audit_events', coalesce((select jsonb_agg(to_jsonb(x) order by x.created_at desc) from (
      select id, event_type, severity, message, created_at
      from platform_technical.audit_events order by created_at desc limit 40
    ) x), '[]'::jsonb),
    'evidence', coalesce((select jsonb_agg(to_jsonb(x) order by x.created_at desc) from (
      select id, request_id, evidence_type, title, description, url, checksum, captured_at, created_at
      from platform_technical.technical_service_evidence order by created_at desc limit 30
    ) x), '[]'::jsonb),
    'notifications', coalesce((select jsonb_agg(to_jsonb(x) order by x.created_at desc) from (
      select id, notification_type, severity, title, message, related_request_id, is_read, created_at
      from platform_technical.technical_notifications
      where target_user_id is null or target_user_id = auth.uid()
      order by created_at desc limit 30
    ) x), '[]'::jsonb),
    'operation_decisions', coalesce((select jsonb_agg(to_jsonb(x) order by x.decided_at desc) from (
      select id, request_id, decision_type, decision_label, decision_reason, decided_at
      from platform_technical.technical_operation_decisions order by decided_at desc limit 30
    ) x), '[]'::jsonb)
  ) into v_result;

  return v_result;
end;
$$;

grant execute on function public.rpc_platform_technical_services_dashboard_v1() to authenticated;

commit;

select
  'platform_technical_dashboard_enrichment_applied' as section,
  true as dashboard_rpc_replaced,
  true as evidence_included,
  true as notifications_included,
  true as operation_decisions_included,
  false as production_approved;
