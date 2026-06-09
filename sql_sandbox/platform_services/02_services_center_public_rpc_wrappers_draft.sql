-- PalWakf Platform Services Center
-- Public RPC Wrappers Draft
-- Date: 2026-05-08
-- Status: NON-PRODUCTION / SANDBOX ONLY
-- Public schema should expose controlled wrappers only, not internal tables.

create or replace function platform_services.generate_tracking_code_v1()
returns text
language sql
as $$
  select 'PWF-' || to_char(now(), 'YYYYMMDD') || '-' || upper(substr(replace(gen_random_uuid()::text, '-', ''), 1, 8));
$$;

comment on function platform_services.generate_tracking_code_v1() is
  'Draft generator for public-safe service request tracking codes.';

create or replace function public.rpc_services_submit_request_draft_v1(payload jsonb)
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
    coalesce(payload - 'requester_name' - 'requester_contact' - 'requester_reference', '{}'::jsonb),
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
    'message_ar', 'تم استلام الطلب مبدئيًا. احتفظ برقم المتابعة.'
  );
end;
$$;

comment on function public.rpc_services_submit_request_draft_v1(jsonb) is
  'Draft public RPC for service request submission. Non-production until abuse protection, captcha/rate-limit, storage, and RBAC review.';

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
  'Public-safe tracking RPC. Must not expose requester_name, contact, internal notes, attachments, or assignee data.';

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
  'Draft public RPC for approved public service forms registry.';
