-- 03_APPLY_rpc_contracts.sql

begin;

create or replace function platform_technical.is_platform_technical_admin_v1()
returns boolean
language sql
stable
security definer
set search_path = public, platform_technical, auth
as $$
  select exists (
    select 1
    from public.admin_users au
    where au.id = auth.uid()
      and coalesce(nullif(to_jsonb(au)->>'is_active','')::boolean, true) = true
      and (
        coalesce(nullif(to_jsonb(au)->>'is_superuser','')::boolean, false) = true
        or lower(coalesce(to_jsonb(au)->>'role','')) in ('super_admin','admin','manager','platform_superuser')
      )
  );
$$;

create or replace function platform_technical.assert_platform_technical_admin_v1()
returns void
language plpgsql
stable
security definer
set search_path = public, platform_technical, auth
as $$
begin
  if auth.uid() is null then
    raise exception 'PLATFORM_TECHNICAL_AUTH_REQUIRED' using errcode = '42501';
  end if;

  if not platform_technical.is_platform_technical_admin_v1() then
    raise exception 'PLATFORM_TECHNICAL_FORBIDDEN' using errcode = '42501';
  end if;
end;
$$;

create or replace function public.rpc_platform_technical_services_dashboard_v1()
returns jsonb
language plpgsql
stable
security definer
set search_path = public, platform_technical, auth
as $$
declare
  v_result jsonb;
begin
  perform platform_technical.assert_platform_technical_admin_v1();

  select jsonb_build_object(
    'backend_applied', true,
    'backend_status', 'platform-technical-backend-contract-active',
    'metrics', jsonb_build_array(
      jsonb_build_object('key','requests','label','الطلبات التقنية','value',(select count(*)::text from platform_technical.technical_service_requests),'status','ready'),
      jsonb_build_object('key','maintenance','label','نوافذ الصيانة','value',(select count(*)::text from platform_technical.maintenance_windows),'status','ready'),
      jsonb_build_object('key','health','label','Health Checks','value',(select count(*)::text from platform_technical.health_checks),'status','ready'),
      jsonb_build_object('key','audit','label','Audit Events','value',(select count(*)::text from platform_technical.audit_events),'status','ready')
    ),
    'requests', coalesce((
      select jsonb_agg(to_jsonb(x) order by x.created_at desc)
      from (
        select id, service_type, action_type, title, description, status, approval_status,
               risk_level, requested_at as created_at, scheduled_for
        from platform_technical.technical_service_requests
        order by created_at desc
        limit 20
      ) x
    ), '[]'::jsonb),
    'maintenance_windows', coalesce((
      select jsonb_agg(to_jsonb(x) order by x.starts_at desc)
      from (
        select id, title, message_ar, starts_at, ends_at, affected_surfaces, status
        from platform_technical.maintenance_windows
        order by starts_at desc
        limit 20
      ) x
    ), '[]'::jsonb),
    'backups', coalesce((
      select jsonb_agg(to_jsonb(x) order by x.created_at desc)
      from (
        select id, backup_kind, provider, backup_label, status, completed_at, checksum
        from platform_technical.backup_registry
        order by created_at desc
        limit 20
      ) x
    ), '[]'::jsonb),
    'health_checks', coalesce((
      select jsonb_agg(to_jsonb(x) order by x.check_group, x.check_key)
      from (
        select check_key, check_group, label, status, details, last_checked_at
        from platform_technical.health_checks
        order by check_group, check_key
      ) x
    ), '[]'::jsonb),
    'releases', coalesce((
      select jsonb_agg(to_jsonb(x) order by x.created_at desc)
      from (
        select id, release_tag, git_commit_hash, deploy_url, status, created_at
        from platform_technical.release_records
        order by created_at desc
        limit 20
      ) x
    ), '[]'::jsonb),
    'audit_events', coalesce((
      select jsonb_agg(to_jsonb(x) order by x.created_at desc)
      from (
        select id, event_type, severity, message, created_at
        from platform_technical.audit_events
        order by created_at desc
        limit 40
      ) x
    ), '[]'::jsonb)
  ) into v_result;

  return v_result;
end;
$$;

create or replace function public.rpc_platform_technical_service_request_create_v1(
  p_service_type text,
  p_action_type text,
  p_title text,
  p_description text default null,
  p_risk_level text default 'medium',
  p_scheduled_for timestamptz default null,
  p_payload jsonb default '{}'::jsonb
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

  if p_service_type not in ('backup','restore','maintenance','health','deployment','audit','other') then
    raise exception 'PLATFORM_TECHNICAL_INVALID_SERVICE_TYPE: %', p_service_type using errcode = '22023';
  end if;

  if p_risk_level not in ('low','medium','high','critical') then
    raise exception 'PLATFORM_TECHNICAL_INVALID_RISK_LEVEL: %', p_risk_level using errcode = '22023';
  end if;

  insert into platform_technical.technical_service_requests (
    service_type, action_type, title, description, risk_level,
    requested_by, scheduled_for, payload
  )
  values (
    p_service_type, p_action_type, p_title, p_description, p_risk_level,
    auth.uid(), p_scheduled_for, coalesce(p_payload, '{}'::jsonb)
  )
  returning id into v_id;

  insert into platform_technical.audit_events (
    event_type, actor_user_id, service_type, request_id, severity, message, payload
  )
  values (
    'technical_request_created',
    auth.uid(),
    p_service_type,
    v_id,
    case when p_risk_level in ('high','critical') then 'warning' else 'info' end,
    'Technical service request created',
    jsonb_build_object('action_type', p_action_type, 'risk_level', p_risk_level)
  );

  return v_id;
end;
$$;

create or replace function public.rpc_platform_maintenance_window_create_v1(
  p_title text,
  p_message_ar text,
  p_starts_at timestamptz,
  p_ends_at timestamptz,
  p_affected_surfaces text[] default array[]::text[]
)
returns uuid
language plpgsql
volatile
security definer
set search_path = public, platform_technical, auth
as $$
declare
  v_request_id uuid;
  v_window_id uuid;
begin
  perform platform_technical.assert_platform_technical_admin_v1();

  if p_ends_at <= p_starts_at then
    raise exception 'PLATFORM_TECHNICAL_INVALID_MAINTENANCE_WINDOW' using errcode = '22023';
  end if;

  v_request_id := public.rpc_platform_technical_service_request_create_v1(
    'maintenance',
    'schedule_maintenance_window',
    p_title,
    p_message_ar,
    'high',
    p_starts_at,
    jsonb_build_object('affected_surfaces', p_affected_surfaces)
  );

  insert into platform_technical.maintenance_windows (
    request_id, title, message_ar, starts_at, ends_at, affected_surfaces, created_by
  )
  values (
    v_request_id, p_title, p_message_ar, p_starts_at, p_ends_at, coalesce(p_affected_surfaces, array[]::text[]), auth.uid()
  )
  returning id into v_window_id;

  insert into platform_technical.audit_events (
    event_type, actor_user_id, service_type, request_id, severity, message, payload
  )
  values (
    'maintenance_window_created',
    auth.uid(),
    'maintenance',
    v_request_id,
    'warning',
    'Maintenance window created in planned state',
    jsonb_build_object('window_id', v_window_id, 'starts_at', p_starts_at, 'ends_at', p_ends_at)
  );

  return v_window_id;
end;
$$;

create or replace function public.rpc_platform_technical_release_record_create_v1(
  p_release_tag text,
  p_git_commit_hash text default null,
  p_deploy_url text default null,
  p_status text default 'recorded'
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

  if p_status not in ('recorded','verified','failed','rolled_back') then
    raise exception 'PLATFORM_TECHNICAL_INVALID_RELEASE_STATUS: %', p_status using errcode = '22023';
  end if;

  insert into platform_technical.release_records (
    release_tag, git_commit_hash, flutter_version, dart_version,
    hosting_provider, deploy_url, status, created_by, notes
  )
  values (
    p_release_tag,
    p_git_commit_hash,
    'Flutter 3.44.1 stable',
    'Dart 3.12.1 stable',
    'vercel',
    p_deploy_url,
    p_status,
    auth.uid(),
    'Recorded through platform technical services dashboard.'
  )
  returning id into v_id;

  insert into platform_technical.audit_events (
    event_type, actor_user_id, service_type, severity, message, payload
  )
  values (
    'release_record_created',
    auth.uid(),
    'deployment',
    'info',
    'Release record created',
    jsonb_build_object('release_id', v_id, 'release_tag', p_release_tag, 'status', p_status)
  );

  return v_id;
end;
$$;

create or replace function public.rpc_platform_technical_health_snapshot_refresh_v1()
returns jsonb
language plpgsql
volatile
security definer
set search_path = public, platform_technical, auth
as $$
declare
  v_postgis_schema text;
  v_payload jsonb;
begin
  perform platform_technical.assert_platform_technical_admin_v1();

  select n.nspname into v_postgis_schema
  from pg_extension e
  join pg_namespace n on n.oid = e.extnamespace
  where e.extname = 'postgis';

  insert into platform_technical.health_checks (check_key, check_group, label, status, details, last_checked_at, updated_at)
  values
    ('postgis_extension_schema', 'database', 'PostGIS extension schema', case when v_postgis_schema = 'extensions' then 'healthy' else 'degraded' end, jsonb_build_object('schema', v_postgis_schema), now(), now()),
    ('waqf_asset_detail_rpc', 'rpc', 'Waqf asset detail RPC', case when to_regprocedure('public.rpc_waqf_asset_detail_v1(uuid)') is not null then 'healthy' else 'blocked' end, jsonb_build_object('rpc','public.rpc_waqf_asset_detail_v1(uuid)'), now(), now()),
    ('core_location_runtime_rpc', 'rpc', 'Core location runtime certification RPC', case when to_regprocedure('public.rpc_core_location_runtime_certification_v1()') is not null then 'healthy' else 'blocked' end, jsonb_build_object('rpc','public.rpc_core_location_runtime_certification_v1()'), now(), now()),
    ('platform_role_permission_map', 'rbac', 'Platform role permission map', case when to_regclass('platform_access.platform_role_permission_map') is not null then 'healthy' else 'blocked' end, jsonb_build_object('table','platform_access.platform_role_permission_map'), now(), now())
  on conflict (check_key) do update
  set status = excluded.status,
      details = excluded.details,
      last_checked_at = now(),
      updated_at = now();

  insert into platform_technical.audit_events (
    event_type, actor_user_id, service_type, severity, message, payload
  )
  values (
    'health_snapshot_refreshed',
    auth.uid(),
    'health',
    'info',
    'Health snapshot refreshed',
    jsonb_build_object('postgis_schema', v_postgis_schema)
  );

  select public.rpc_platform_technical_services_dashboard_v1() into v_payload;
  return v_payload;
end;
$$;

grant execute on function public.rpc_platform_technical_services_dashboard_v1() to authenticated;
grant execute on function public.rpc_platform_technical_service_request_create_v1(text,text,text,text,text,timestamptz,jsonb) to authenticated;
grant execute on function public.rpc_platform_maintenance_window_create_v1(text,text,timestamptz,timestamptz,text[]) to authenticated;
grant execute on function public.rpc_platform_technical_release_record_create_v1(text,text,text,text) to authenticated;
grant execute on function public.rpc_platform_technical_health_snapshot_refresh_v1() to authenticated;

commit;

select
  'platform_technical_rpc_contracts_applied' as section,
  true as dashboard_rpc_created,
  true as create_request_rpc_created,
  true as maintenance_window_rpc_created,
  true as release_record_rpc_created,
  true as health_refresh_rpc_created,
  false as backup_restore_execution,
  false as production_approved;
