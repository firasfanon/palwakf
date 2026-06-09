-- PalWakf Platform Services Center
-- Production Data Layer Readiness Pack
-- 02 - Production RPC Migration Draft
-- Date: 2026-05-08
-- Status: PRODUCTION-READINESS DRAFT / DO NOT RUN UNTIL APPROVED
-- Notes:
--   Public RPC wrappers expose controlled fields only.
--   Draft aliases are kept for current Flutter adapter compatibility.

create or replace function platform_services.generate_tracking_code_v1()
returns text
language sql
as $$
  select 'PWF-' || to_char(now(), 'YYYYMMDD') || '-' || upper(substr(replace(gen_random_uuid()::text, '-', ''), 1, 8));
$$;

comment on function platform_services.generate_tracking_code_v1() is
  'Generates public-safe service request tracking codes.';

create or replace function public.rpc_services_submit_request_v1(payload jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public, platform_services
as $$
declare
  v_tracking_code text;
  v_request_id uuid;
  v_service_key text;
  v_form_key text;
  v_requester_type text;
  v_request_summary text;
begin
  if payload is null or jsonb_typeof(payload) <> 'object' then
    raise exception 'payload must be a JSON object';
  end if;

  v_service_key := nullif(payload->>'service_key', '');
  v_form_key := nullif(payload->>'form_key', '');
  v_requester_type := coalesce(nullif(payload->>'requester_type', ''), 'citizen');
  v_request_summary := nullif(payload->>'request_summary', '');

  if v_service_key is null then
    raise exception 'service_key is required';
  end if;

  if v_requester_type not in ('citizen', 'entity', 'unit', 'staff') then
    raise exception 'invalid requester_type';
  end if;

  v_tracking_code := platform_services.generate_tracking_code_v1();

  insert into platform_services.service_requests (
    tracking_code,
    requester_type,
    requester_name,
    requester_contact,
    requester_reference,
    service_key,
    form_key,
    request_summary,
    payload,
    source_channel,
    status,
    public_note
  ) values (
    v_tracking_code,
    v_requester_type,
    nullif(payload->>'requester_name', ''),
    nullif(payload->>'requester_contact', ''),
    nullif(payload->>'requester_reference', ''),
    v_service_key,
    v_form_key,
    v_request_summary,
    coalesce(payload - 'requester_name' - 'requester_contact' - 'requester_reference' - 'requester_identity_hint', '{}'::jsonb),
    'public_portal',
    'received',
    'تم استلام الطلب مبدئيًا وهو بانتظار الفرز.'
  ) returning id into v_request_id;

  insert into platform_services.service_request_status_events (
    request_id,
    from_status,
    to_status,
    public_note,
    actor_label
  ) values (
    v_request_id,
    null,
    'received',
    'تم استلام الطلب مبدئيًا.',
    'public_portal'
  );

  return jsonb_build_object(
    'ok', true,
    'tracking_code', v_tracking_code,
    'status', 'received',
    'source', 'rpc',
    'message_ar', 'تم استلام الطلب مبدئيًا. احتفظ برقم المتابعة.'
  );
end;
$$;

comment on function public.rpc_services_submit_request_v1(jsonb) is
  'Public service request submission RPC. Requires production review for abuse protection, captcha/rate-limit, and privacy policy before enabling broadly.';

create or replace function public.rpc_services_submit_request_draft_v1(payload jsonb)
returns jsonb
language sql
security definer
set search_path = public, platform_services
as $$
  select public.rpc_services_submit_request_v1(payload);
$$;

comment on function public.rpc_services_submit_request_draft_v1(jsonb) is
  'Compatibility alias for current Flutter adapter. Prefer rpc_services_submit_request_v1 after adapter promotion.';

create or replace function public.rpc_services_track_request_public_v1(p_tracking_code text)
returns table (
  tracking_code text,
  status text,
  public_note text,
  submitted_at timestamptz,
  last_status_at timestamptz
)
language sql
security definer
set search_path = public, platform_services
as $$
  select
    r.tracking_code,
    r.status,
    coalesce(r.public_note, 'الطلب قيد المتابعة.') as public_note,
    r.submitted_at,
    r.last_status_at
  from platform_services.service_requests r
  where r.tracking_code = p_tracking_code
  limit 1;
$$;

comment on function public.rpc_services_track_request_public_v1(text) is
  'Public-safe tracking RPC. It must not expose personal data, raw payload, internal notes, assignee, attachments, or internal event notes.';

create or replace function public.rpc_services_forms_public_v1()
returns table (
  form_key text,
  title_ar text,
  service_key text,
  audience text,
  required_attachments jsonb,
  version_no text,
  source_reference text
)
language sql
security definer
set search_path = public, platform_services
as $$
  select
    f.form_key,
    f.title_ar,
    f.service_key,
    f.audience,
    f.required_attachments,
    f.version_no,
    f.source_reference
  from platform_services.service_forms_registry f
  where f.public_visibility = true
    and f.review_status = 'approved'
  order by f.service_key, f.title_ar;
$$;

comment on function public.rpc_services_forms_public_v1() is
  'Public RPC for approved service forms registry.';

-- Temporary readiness gate. Replace with real platform RBAC helper before production enablement.
create or replace function platform_services.can_admin_read_requests_v1()
returns boolean
language sql
stable
security definer
set search_path = public, platform_services
as $$
  select auth.uid() is not null;
$$;

comment on function platform_services.can_admin_read_requests_v1() is
  'Temporary production-readiness gate. Must be replaced or wrapped by platform RBAC before full production rollout.';

create or replace function public.rpc_services_admin_request_queue_v1(
  p_status text default null,
  p_limit integer default 100
)
returns table (
  id uuid,
  tracking_code text,
  service_key text,
  form_key text,
  requester_type text,
  request_summary text,
  status text,
  priority text,
  assigned_unit_id uuid,
  submitted_at timestamptz,
  last_status_at timestamptz,
  source_channel text
)
language sql
security definer
set search_path = public, platform_services
as $$
  select
    r.id,
    r.tracking_code,
    r.service_key,
    r.form_key,
    r.requester_type,
    r.request_summary,
    r.status,
    r.priority,
    r.assigned_unit_id,
    r.submitted_at,
    r.last_status_at,
    r.source_channel
  from platform_services.service_requests r
  where platform_services.can_admin_read_requests_v1()
    and (p_status is null or r.status = p_status)
  order by r.submitted_at desc
  limit greatest(1, least(coalesce(p_limit, 100), 200));
$$;

comment on function public.rpc_services_admin_request_queue_v1(text, integer) is
  'Admin queue RPC. Production rollout requires replacing the temporary gate with system+service+action+scope RBAC.';

create or replace function public.rpc_services_admin_request_queue_draft_v1()
returns table (
  id uuid,
  tracking_code text,
  service_key text,
  form_key text,
  requester_type text,
  request_summary text,
  status text,
  priority text,
  assigned_unit_id uuid,
  submitted_at timestamptz,
  last_status_at timestamptz,
  source_channel text
)
language sql
security definer
set search_path = public, platform_services
as $$
  select * from public.rpc_services_admin_request_queue_v1(null, 100);
$$;

comment on function public.rpc_services_admin_request_queue_draft_v1() is
  'Compatibility alias for current Flutter admin queue adapter.';

-- Execution grants should be reviewed with API exposure policy before production.
grant execute on function public.rpc_services_forms_public_v1() to anon, authenticated;
grant execute on function public.rpc_services_track_request_public_v1(text) to anon, authenticated;
grant execute on function public.rpc_services_submit_request_v1(jsonb) to anon, authenticated;
grant execute on function public.rpc_services_submit_request_draft_v1(jsonb) to anon, authenticated;
grant execute on function public.rpc_services_admin_request_queue_v1(text, integer) to authenticated;
grant execute on function public.rpc_services_admin_request_queue_draft_v1() to authenticated;

