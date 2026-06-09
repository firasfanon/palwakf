-- PalWakf Platform — Mega Batch M
-- Optional transient workflow verification. Creates a temporary UAT request and cleans it up.
-- Run only after 01_platform_services_schema_rpc_workflow_production_readiness.sql.

do $$
declare
  v_submit jsonb;
  v_tracking text;
  v_t1 jsonb;
  v_t2 jsonb;
  v_t3 jsonb;
  v_request_id uuid;
begin
  v_submit := public.rpc_services_submit_request_v1(jsonb_build_object(
    'requester_type', 'citizen',
    'requester_name', 'UAT Mega M',
    'requester_contact', 'uat@example.test',
    'service_key', 'general_service',
    'form_key', 'general_service_request_v1',
    'request_summary', 'UAT transient request for Mega Batch M workflow verification.',
    'unit_slug', 'home'
  ));
  v_tracking := v_submit->>'tracking_code';

  if v_tracking is null then
    raise exception 'submit failed: %', v_submit;
  end if;

  v_t1 := public.rpc_services_admin_transition_request_v1(v_tracking, 'start_triage', 'تم نقل الطلب إلى الفرز.', 'UAT transition');
  v_t2 := public.rpc_services_admin_transition_request_v1(v_tracking, 'start_review', 'تم نقل الطلب إلى المراجعة.', 'UAT transition');
  v_t3 := public.rpc_services_admin_transition_request_v1(v_tracking, 'close', 'تم إغلاق طلب UAT.', 'UAT transition');

  if coalesce((v_t1->>'success')::boolean, false) is not true
     or coalesce((v_t2->>'success')::boolean, false) is not true
     or coalesce((v_t3->>'success')::boolean, false) is not true then
    raise exception 'workflow transition failed: %, %, %', v_t1, v_t2, v_t3;
  end if;

  select id into v_request_id from platform_services.service_requests where tracking_code = v_tracking;
  delete from platform_services.service_request_status_events where request_id = v_request_id;
  delete from platform_services.service_requests where id = v_request_id;
end $$;

select 'workflow_transient_uat' as check_key, true as passed,
       'submit -> triage -> review -> close executed and cleaned up' as note;
