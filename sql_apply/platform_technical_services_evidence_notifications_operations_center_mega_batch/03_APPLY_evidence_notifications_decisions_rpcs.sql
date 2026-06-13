begin;

create or replace function public.rpc_platform_technical_evidence_add_v1(
  p_request_id uuid,
  p_evidence_type text,
  p_title text,
  p_description text default null,
  p_url text default null,
  p_storage_bucket text default null,
  p_storage_path text default null,
  p_checksum text default null,
  p_captured_at timestamptz default null,
  p_payload jsonb default '{}'::jsonb
)
returns uuid language plpgsql volatile security definer
set search_path = public, platform_technical, auth
as $$
declare v_id uuid; v_service_type text;
begin
  perform platform_technical.assert_platform_technical_admin_v1();

  if p_evidence_type not in ('screenshot','network','console','sql_result','document','link','other') then
    raise exception 'PLATFORM_TECHNICAL_INVALID_EVIDENCE_TYPE: %', p_evidence_type using errcode = '22023';
  end if;

  select service_type into v_service_type
  from platform_technical.technical_service_requests
  where id = p_request_id;

  if not found then
    raise exception 'PLATFORM_TECHNICAL_REQUEST_NOT_FOUND: %', p_request_id using errcode = 'P0002';
  end if;

  insert into platform_technical.technical_service_evidence (
    request_id, evidence_type, title, description, url, storage_bucket,
    storage_path, checksum, captured_at, uploaded_by, payload
  )
  values (
    p_request_id, p_evidence_type, p_title, p_description, p_url, p_storage_bucket,
    p_storage_path, p_checksum, coalesce(p_captured_at, now()), auth.uid(), coalesce(p_payload, '{}'::jsonb)
  )
  returning id into v_id;

  insert into platform_technical.audit_events(event_type, actor_user_id, service_type, request_id, severity, message, payload)
  values ('technical_evidence_added', auth.uid(), v_service_type, p_request_id, 'info',
          'Technical service evidence added',
          jsonb_build_object('evidence_id', v_id, 'evidence_type', p_evidence_type, 'title', p_title));

  return v_id;
end;
$$;

create or replace function public.rpc_platform_technical_operation_decision_record_v1(
  p_request_id uuid,
  p_decision_type text,
  p_decision_label text,
  p_decision_reason text default null,
  p_payload jsonb default '{}'::jsonb
)
returns uuid language plpgsql volatile security definer
set search_path = public, platform_technical, auth
as $$
declare v_id uuid; v_service_type text;
begin
  perform platform_technical.assert_platform_technical_admin_v1();

  if p_decision_type not in ('approve','reject','defer','escalate','close','rollback_required','uat_required') then
    raise exception 'PLATFORM_TECHNICAL_INVALID_DECISION_TYPE: %', p_decision_type using errcode = '22023';
  end if;

  select service_type into v_service_type from platform_technical.technical_service_requests where id = p_request_id;

  insert into platform_technical.technical_operation_decisions (
    request_id, decision_type, decision_label, decision_reason, decided_by, payload
  )
  values (p_request_id, p_decision_type, p_decision_label, p_decision_reason, auth.uid(), coalesce(p_payload, '{}'::jsonb))
  returning id into v_id;

  insert into platform_technical.audit_events(event_type, actor_user_id, service_type, request_id, severity, message, payload)
  values ('technical_operation_decision_recorded', auth.uid(), coalesce(v_service_type, 'system'), p_request_id,
          case when p_decision_type in ('reject','rollback_required','escalate') then 'warning' else 'info' end,
          'Technical operation decision recorded: ' || p_decision_type,
          jsonb_build_object('decision_id', v_id, 'decision_type', p_decision_type, 'label', p_decision_label));

  return v_id;
end;
$$;

create or replace function public.rpc_platform_technical_notification_mark_read_v1(p_notification_id uuid)
returns boolean language plpgsql volatile security definer
set search_path = public, platform_technical, auth
as $$
begin
  perform platform_technical.assert_platform_technical_admin_v1();

  update platform_technical.technical_notifications
  set is_read = true, read_at = now()
  where id = p_notification_id
    and (target_user_id is null or target_user_id = auth.uid());

  return found;
end;
$$;

create or replace function public.rpc_platform_technical_notification_create_v1(
  p_target_user_id uuid,
  p_notification_type text,
  p_severity text,
  p_title text,
  p_message text,
  p_related_request_id uuid default null
)
returns uuid language plpgsql volatile security definer
set search_path = public, platform_technical, auth
as $$
declare v_id uuid;
begin
  perform platform_technical.assert_platform_technical_admin_v1();

  if p_notification_type not in ('request','approval','maintenance','backup','deployment','health','audit','system') then
    raise exception 'PLATFORM_TECHNICAL_INVALID_NOTIFICATION_TYPE: %', p_notification_type using errcode = '22023';
  end if;

  if p_severity not in ('info','warning','error','critical') then
    raise exception 'PLATFORM_TECHNICAL_INVALID_NOTIFICATION_SEVERITY: %', p_severity using errcode = '22023';
  end if;

  insert into platform_technical.technical_notifications (
    target_user_id, notification_type, severity, title, message, related_request_id
  )
  values (p_target_user_id, p_notification_type, p_severity, p_title, p_message, p_related_request_id)
  returning id into v_id;

  insert into platform_technical.audit_events(event_type, actor_user_id, service_type, request_id, severity, message, payload)
  values ('technical_notification_created', auth.uid(), p_notification_type, p_related_request_id, p_severity,
          'Technical notification created',
          jsonb_build_object('notification_id', v_id, 'target_user_id', p_target_user_id));

  return v_id;
end;
$$;

grant execute on function public.rpc_platform_technical_evidence_add_v1(uuid,text,text,text,text,text,text,text,timestamptz,jsonb) to authenticated;
grant execute on function public.rpc_platform_technical_operation_decision_record_v1(uuid,text,text,text,jsonb) to authenticated;
grant execute on function public.rpc_platform_technical_notification_mark_read_v1(uuid) to authenticated;
grant execute on function public.rpc_platform_technical_notification_create_v1(uuid,text,text,text,text,uuid) to authenticated;

commit;

select
  'platform_technical_evidence_notifications_rpcs_applied' as section,
  true as evidence_add_rpc,
  true as decision_record_rpc,
  true as notification_mark_read_rpc,
  true as notification_create_rpc,
  false as production_approved;
