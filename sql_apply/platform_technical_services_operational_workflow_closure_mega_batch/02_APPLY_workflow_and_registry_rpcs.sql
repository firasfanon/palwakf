begin;

create or replace function public.rpc_platform_technical_service_request_transition_v1(
  p_request_id uuid,
  p_transition text,
  p_note text default null,
  p_result jsonb default '{}'::jsonb
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = public, platform_technical, auth
as $$
declare
  v_before platform_technical.technical_service_requests%rowtype;
  v_new_status text;
  v_new_approval text;
begin
  perform platform_technical.assert_platform_technical_admin_v1();

  select * into v_before
  from platform_technical.technical_service_requests
  where id = p_request_id
  for update;

  if not found then
    raise exception 'PLATFORM_TECHNICAL_REQUEST_NOT_FOUND: %', p_request_id using errcode = 'P0002';
  end if;

  v_new_status := v_before.status;
  v_new_approval := v_before.approval_status;

  if p_transition = 'approve' then
    v_new_status := 'approved';
    v_new_approval := 'approved';
  elsif p_transition = 'reject' then
    v_new_status := 'rejected';
    v_new_approval := 'rejected';
  elsif p_transition = 'start' then
    if v_before.approval_status <> 'approved' and v_before.risk_level in ('high','critical') then
      raise exception 'PLATFORM_TECHNICAL_APPROVAL_REQUIRED_BEFORE_START' using errcode = '42501';
    end if;
    v_new_status := 'in_progress';
  elsif p_transition = 'complete' then
    v_new_status := 'completed';
  elsif p_transition = 'fail' then
    v_new_status := 'failed';
  elsif p_transition = 'cancel' then
    v_new_status := 'cancelled';
  else
    raise exception 'PLATFORM_TECHNICAL_INVALID_TRANSITION: %', p_transition using errcode = '22023';
  end if;

  update platform_technical.technical_service_requests
  set status = v_new_status,
      approval_status = v_new_approval,
      approved_by = case when p_transition = 'approve' then auth.uid() else approved_by end,
      approved_at = case when p_transition = 'approve' then now() else approved_at end,
      result = coalesce(p_result, '{}'::jsonb),
      updated_at = now()
  where id = p_request_id;

  insert into platform_technical.audit_events(event_type, actor_user_id, service_type, request_id, severity, message, payload)
  values (
    'technical_request_transition',
    auth.uid(),
    v_before.service_type,
    p_request_id,
    case when p_transition in ('fail','reject') then 'warning' else 'info' end,
    'Technical service request transition: ' || p_transition,
    jsonb_build_object('from_status', v_before.status, 'to_status', v_new_status, 'note', p_note)
  );

  return public.rpc_platform_technical_services_dashboard_v1();
end;
$$;

create or replace function public.rpc_platform_backup_registry_record_create_v1(
  p_request_id uuid,
  p_backup_kind text,
  p_provider text,
  p_backup_label text,
  p_object_ref text default null,
  p_status text default 'recorded',
  p_checksum text default null,
  p_size_bytes bigint default null,
  p_retention_until timestamptz default null,
  p_notes text default null
)
returns uuid
language plpgsql
volatile
security definer
set search_path = public, platform_technical, auth
as $$
declare
  v_id uuid;
begin
  perform platform_technical.assert_platform_technical_admin_v1();

  if p_backup_kind not in ('database','files','config','full','other') then
    raise exception 'PLATFORM_TECHNICAL_INVALID_BACKUP_KIND: %', p_backup_kind using errcode = '22023';
  end if;

  if p_status not in ('recorded','verified','failed','expired') then
    raise exception 'PLATFORM_TECHNICAL_INVALID_BACKUP_STATUS: %', p_status using errcode = '22023';
  end if;

  insert into platform_technical.backup_registry(
    request_id, backup_kind, provider, backup_label, object_ref, status,
    completed_at, size_bytes, checksum, retention_until, recorded_by, notes
  )
  values (
    p_request_id, p_backup_kind, coalesce(nullif(p_provider,''), 'manual'),
    p_backup_label, p_object_ref, p_status,
    case when p_status in ('recorded','verified') then now() else null end,
    p_size_bytes, p_checksum, p_retention_until, auth.uid(), p_notes
  )
  returning id into v_id;

  insert into platform_technical.audit_events(event_type, actor_user_id, service_type, request_id, severity, message, payload)
  values (
    'backup_registry_record_created', auth.uid(), 'backup', p_request_id, 'info',
    'Backup metadata record created',
    jsonb_build_object('backup_id', v_id, 'backup_kind', p_backup_kind, 'status', p_status)
  );

  return v_id;
end;
$$;

create or replace function public.rpc_platform_maintenance_window_transition_v1(
  p_window_id uuid,
  p_transition text,
  p_note text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = public, platform_technical, auth
as $$
declare
  v_before platform_technical.maintenance_windows%rowtype;
  v_new_status text;
begin
  perform platform_technical.assert_platform_technical_admin_v1();

  select * into v_before
  from platform_technical.maintenance_windows
  where id = p_window_id
  for update;

  if not found then
    raise exception 'PLATFORM_TECHNICAL_MAINTENANCE_WINDOW_NOT_FOUND: %', p_window_id using errcode = 'P0002';
  end if;

  if p_transition = 'approve' then
    v_new_status := 'approved';
  elsif p_transition = 'cancel' then
    v_new_status := 'cancelled';
  elsif p_transition = 'complete' then
    v_new_status := 'completed';
  else
    raise exception 'PLATFORM_TECHNICAL_INVALID_MAINTENANCE_TRANSITION: %', p_transition using errcode = '22023';
  end if;

  update platform_technical.maintenance_windows
  set status = v_new_status,
      approved_by = case when p_transition = 'approve' then auth.uid() else approved_by end,
      approved_at = case when p_transition = 'approve' then now() else approved_at end,
      updated_at = now()
  where id = p_window_id;

  insert into platform_technical.audit_events(event_type, actor_user_id, service_type, request_id, severity, message, payload)
  values (
    'maintenance_window_transition', auth.uid(), 'maintenance', v_before.request_id,
    case when p_transition = 'cancel' then 'warning' else 'info' end,
    'Maintenance window transition: ' || p_transition,
    jsonb_build_object('window_id', p_window_id, 'from_status', v_before.status, 'to_status', v_new_status, 'note', p_note)
  );

  return public.rpc_platform_technical_services_dashboard_v1();
end;
$$;

create or replace function public.rpc_platform_maintenance_status_v1()
returns jsonb
language sql
stable
security definer
set search_path = public, platform_technical
as $$
  select jsonb_build_object(
    'maintenance_active', exists (
      select 1
      from platform_technical.maintenance_windows w
      where w.status = 'active'
        and now() between w.starts_at and w.ends_at
    ),
    'planned_windows', coalesce((
      select jsonb_agg(to_jsonb(x) order by x.starts_at asc)
      from (
        select id, title, message_ar, starts_at, ends_at, affected_surfaces, status
        from platform_technical.maintenance_windows
        where status in ('planned','approved','active')
          and ends_at >= now()
        order by starts_at asc
        limit 5
      ) x
    ), '[]'::jsonb)
  );
$$;

create or replace function public.rpc_platform_technical_audit_events_v1(
  p_service_type text default null,
  p_severity text default null,
  p_limit integer default 50
)
returns jsonb
language plpgsql
stable
security definer
set search_path = public, platform_technical, auth
as $$
begin
  perform platform_technical.assert_platform_technical_admin_v1();

  return coalesce((
    select jsonb_agg(to_jsonb(x) order by x.created_at desc)
    from (
      select id, event_type, service_type, severity, message, payload, created_at
      from platform_technical.audit_events e
      where (p_service_type is null or e.service_type = p_service_type)
        and (p_severity is null or e.severity = p_severity)
      order by created_at desc
      limit greatest(1, least(coalesce(p_limit, 50), 200))
    ) x
  ), '[]'::jsonb);
end;
$$;

grant execute on function public.rpc_platform_technical_service_request_transition_v1(uuid,text,text,jsonb) to authenticated;
grant execute on function public.rpc_platform_backup_registry_record_create_v1(uuid,text,text,text,text,text,text,bigint,timestamptz,text) to authenticated;
grant execute on function public.rpc_platform_maintenance_window_transition_v1(uuid,text,text) to authenticated;
grant execute on function public.rpc_platform_maintenance_status_v1() to anon, authenticated;
grant execute on function public.rpc_platform_technical_audit_events_v1(text,text,integer) to authenticated;

commit;

select
  'platform_technical_workflow_rpcs_applied' as section,
  true as request_transition_rpc,
  true as backup_registry_record_rpc,
  true as maintenance_window_transition_rpc,
  true as maintenance_status_rpc,
  true as audit_events_filter_rpc,
  false as backup_restore_execution,
  false as maintenance_mode_global_activation,
  false as production_approved;
